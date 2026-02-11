# Alphacode GameBoost - Smart Game Detector
# 100% local, zero external dependencies, privacy-first

Add-Type -AssemblyName System.Windows.Forms

# ===== GAME DATABASE =====
$script:GameDatabase = @{}
$script:DetectionInterval = 3000  # ms
$script:CurrentGame = $null
$script:DetectorRunning = $false

function Initialize-GameDetector {
    <#
    .SYNOPSIS
        Initializes smart game detection with local database
    
    .DESCRIPTION
        Monitors running processes and auto-applies optimal profiles
        100% local - no external API calls
    #>
    
    Write-EnhancedLog "Initializing Smart Game Detector..." "INFO" "DETECTOR"
    
    # Load game database
    $dbPath = "$PSScriptRoot\..\data\games.json"
    if (Test-Path $dbPath) {
        try {
            $gamesJson = Get-Content $dbPath -Raw | ConvertFrom-Json
            foreach ($game in $gamesJson) {
                $script:GameDatabase[$game.ProcessName.ToLower()] = $game
            }
            Write-EnhancedLog "Loaded $($script:GameDatabase.Count) games from database" "SUCCESS" "DETECTOR"
        }
        catch {
            Write-EnhancedLog "Failed to load game database: $($_.Exception.Message)" "ERROR" "DETECTOR"
            Initialize-DefaultGameDatabase
        }
    }
    else {
        Write-EnhancedLog "Game database not found, creating default..." "WARN" "DETECTOR"
        Initialize-DefaultGameDatabase
    }
    
    # Start detection loop
    Start-GameDetectionLoop
}

function Initialize-DefaultGameDatabase {
    <#
    .SYNOPSIS
        Creates default game database with popular titles
    #>
    
    $defaultGames = @(
        @{
            Name           = "Counter-Strike 2"
            ProcessName    = "cs2.exe"
            Category       = "Competitive_FPS"
            OptimalProfile = "LowLatency"
            Priority       = "High"
        },
        @{
            Name           = "Valorant"
            ProcessName    = "VALORANT-Win64-Shipping.exe"
            Category       = "Competitive_FPS"
            OptimalProfile = "LowLatency"
            Priority       = "High"
        },
        @{
            Name           = "League of Legends"
            ProcessName    = "League of Legends.exe"
            Category       = "MOBA"
            OptimalProfile = "Balanced"
            Priority       = "Normal"
        },
        @{
            Name           = "Cyberpunk 2077"
            ProcessName    = "Cyberpunk2077.exe"
            Category       = "AAA_OpenWorld"
            OptimalProfile = "Maximum"
            Priority       = "Normal"
        },
        @{
            Name           = "Elden Ring"
            ProcessName    = "eldenring.exe"
            Category       = "AAA_Action"
            OptimalProfile = "Aggressive"
            Priority       = "Normal"
        },
        @{
            Name           = "Fortnite"
            ProcessName    = "FortniteClient-Win64-Shipping.exe"
            Category       = "Battle_Royale"
            OptimalProfile = "Balanced"
            Priority       = "Normal"
        },
        @{
            Name           = "Apex Legends"
            ProcessName    = "r5apex.exe"
            Category       = "Battle_Royale"
            OptimalProfile = "Aggressive"
            Priority       = "High"
        },
        @{
            Name           = "Call of Duty"
            ProcessName    = "cod.exe"
            Category       = "Competitive_FPS"
            OptimalProfile = "LowLatency"
            Priority       = "High"
        },
        @{
            Name           = "Minecraft"
            ProcessName    = "javaw.exe"
            Category       = "Sandbox"
            OptimalProfile = "Conservative"
            Priority       = "Normal"
        },
        @{
            Name           = "GTA V"
            ProcessName    = "GTA5.exe"
            Category       = "AAA_OpenWorld"
            OptimalProfile = "Maximum"
            Priority       = "Normal"
        }
    )
    
    foreach ($game in $defaultGames) {
        $script:GameDatabase[$game.ProcessName.ToLower()] = $game
    }
    
    # Save to file
    $dbPath = "$PSScriptRoot\..\data"
    if (-not (Test-Path $dbPath)) {
        New-Item -ItemType Directory -Path $dbPath -Force | Out-Null
    }
    
    $defaultGames | ConvertTo-Json -Depth 10 | Set-Content "$dbPath\games.json" -Encoding UTF8
    Write-EnhancedLog "Created default game database with $($defaultGames.Count) games" "SUCCESS" "DETECTOR"
}

function Start-GameDetectionLoop {
    <#
    .SYNOPSIS
        Starts background game detection loop
    #>
    
    $script:DetectorRunning = $true
    
    # Run in background job for non-blocking
    $script:DetectorJob = Start-Job -ScriptBlock {
        param($Database, $Interval)
        
        while ($true) {
            # Get all processes with main window (games usually have windows)
            $processes = Get-Process | Where-Object { 
                $_.MainWindowTitle -ne "" -and 
                $_.ProcessName -ne "explorer" -and
                $_.ProcessName -ne "powershell"
            }
            
            foreach ($proc in $processes) {
                $processName = $proc.ProcessName.ToLower() + ".exe"
                
                if ($Database.ContainsKey($processName)) {
                    # Game detected!
                    $game = $Database[$processName]
                    
                    [PSCustomObject]@{
                        Event          = "GameDetected"
                        GameName       = $game.Name
                        ProcessName    = $proc.ProcessName
                        ProcessId      = $proc.Id
                        OptimalProfile = $game.OptimalProfile
                        Priority       = $game.Priority
                        Category       = $game.Category
                        Timestamp      = Get-Date
                    }
                }
            }
            
            Start-Sleep -Milliseconds $Interval
        }
    } -ArgumentList $script:GameDatabase, $script:DetectionInterval
    
    Write-EnhancedLog "Game detection loop started (interval: $script:DetectionInterval ms)" "SUCCESS" "DETECTOR"
    
    # Monitor detection events
    Register-ObjectEvent -InputObject $script:DetectorJob -EventName "StateChanged" -Action {
        # Handle job state changes
    }
}

function Get-DetectedGame {
    <#
    .SYNOPSIS
        Gets currently detected game (if any)
    
    .OUTPUTS
        Game object or $null
    #>
    
    if ($script:DetectorJob) {
        $events = Receive-Job $script:DetectorJob -Keep | Where-Object { $_.Event -eq "GameDetected" }
        
        if ($events) {
            # Return most recent detection
            return $events | Sort-Object Timestamp -Descending | Select-Object -First 1
        }
    }
    
    return $null
}

function Stop-GameDetector {
    <#
    .SYNOPSIS
        Stops game detection
    #>
    
    if ($script:DetectorJob) {
        Stop-Job $script:DetectorJob
        Remove-Job $script:DetectorJob
        $script:DetectorRunning = $false
        Write-EnhancedLog "Game detector stopped" "INFO" "DETECTOR"
    }
}

function Invoke-GameBasedOptimization {
    <#
    .SYNOPSIS
        Automatically applies optimal profile when game is detected
    
    .PARAMETER AutoApply
        If true, applies profile without user confirmation
    #>
    
    param([bool]$AutoApply = $false)
    
    while ($script:DetectorRunning) {
        $detectedGame = Get-DetectedGame
        
        if ($detectedGame -and ($script:CurrentGame -ne $detectedGame.ProcessName)) {
            # New game detected
            $script:CurrentGame = $detectedGame.ProcessName
            
            Write-EnhancedLog "🎮 Game detected: $($detectedGame.GameName)" "SUCCESS" "DETECTOR"
            Write-EnhancedLog "Recommended profile: $($detectedGame.OptimalProfile)" "INFO" "DETECTOR"
            
            if ($AutoApply) {
                # Apply profile automatically
                Write-EnhancedLog "Auto-applying $($detectedGame.OptimalProfile) profile..." "INFO" "AUTO_OPTIMIZE"
                Apply-IntelligentOptimizations -Profile $detectedGame.OptimalProfile
                
                # Show notification
                Show-TrayNotification -Title "GameBoost Active" `
                    -Message "Optimized for $($detectedGame.GameName) ($($detectedGame.OptimalProfile) profile)" `
                    -Icon "Info"
            }
            else {
                # Ask user for confirmation
                $result = [System.Windows.Forms.MessageBox]::Show(
                    "Detected: $($detectedGame.GameName)`n`nApply $($detectedGame.OptimalProfile) profile?",
                    "Alphacode GameBoost",
                    [System.Windows.Forms.MessageBoxButtons]::YesNo,
                    [System.Windows.Forms.MessageBoxIcon]::Question
                )
                
                if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                    Apply-IntelligentOptimizations -Profile $detectedGame.OptimalProfile
                }
            }
        }
        
        # Check if game closed
        if ($script:CurrentGame) {
            $stillRunning = Get-Process -Name ($script:CurrentGame -replace "\.exe$", "") -ErrorAction SilentlyContinue
            
            if (-not $stillRunning) {
                Write-EnhancedLog "Game closed: $script:CurrentGame" "INFO" "DETECTOR"
                $script:CurrentGame = $null
                
                # Optional: Revert optimizations
                if ((Get-Configuration).RevertOnGameExit) {
                    Write-EnhancedLog "Reverting to default profile..." "INFO" "AUTO_OPTIMIZE"
                    Apply-IntelligentOptimizations -Profile "Conservative"
                }
            }
        }
        
        Start-Sleep -Seconds 2
    }
}

function Add-CustomGame {
    <#
    .SYNOPSIS
        Adds custom game to detection database
    
    .EXAMPLE
        Add-CustomGame -Name "My Game" -ProcessName "mygame.exe" -OptimalProfile "Maximum"
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $true)]
        [string]$ProcessName,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("Conservative", "Balanced", "Aggressive", "Maximum", "LowLatency")]
        [string]$OptimalProfile,
        
        [string]$Category = "Custom",
        
        [ValidateSet("Low", "Normal", "High")]
        [string]$Priority = "Normal"
    )
    
    $game = @{
        Name           = $Name
        ProcessName    = $ProcessName
        Category       = $Category
        OptimalProfile = $OptimalProfile
        Priority       = $Priority
        Custom         = $true
    }
    
    $script:GameDatabase[$ProcessName.ToLower()] = $game
    
    # Save to database
    $dbPath = "$PSScriptRoot\..\data\games.json"
    $allGames = $script:GameDatabase.Values | ConvertTo-Json -Depth 10
    Set-Content -Path $dbPath -Value $allGames -Encoding UTF8
    
    Write-EnhancedLog "Added custom game: $Name ($ProcessName)" "SUCCESS" "DETECTOR"
}

# Export functions
Export-ModuleMember -Function Initialize-GameDetector, Start-GameDetectionLoop, Get-DetectedGame, `
    Stop-GameDetector, Invoke-GameBasedOptimization, Add-CustomGame
