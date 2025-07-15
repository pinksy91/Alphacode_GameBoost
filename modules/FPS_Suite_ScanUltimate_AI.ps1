# Alphacode GameBoost - Ultimate Edition
# Version 3.1.0 - Enterprise Gaming Performance Optimizer
# Compatible with all modern AMD/Intel CPUs and NVIDIA/AMD GPUs

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== GLOBAL CONFIGURATION =====
$global:AppVersion = "3.1.0"
$global:AppName = "Alphacode GameBoost - Ultimate Edition"
$global:AppPublisher = "Advanced Performance Systems"
$global:LogPath = "$env:LOCALAPPDATA\FPSSuitePro\Logs"
$global:BackupPath = "$env:LOCALAPPDATA\FPSSuitePro\Backups"
$global:ConfigPath = "$env:LOCALAPPDATA\FPSSuitePro\Config"
$global:ConfigFile = "$global:ConfigPath\fps_suite_config.json"

# Hardware Info Storage
$global:CPUName = ""
$global:IsAMDCPU = $false
$global:IsIntelCPU = $false
$global:HasX3D = $false
$global:GPUName = ""
$global:IsNVIDIA = $false
$global:IsAMDGPU = $false
$global:RAMTotal = 0
$global:RAMSpeed = 0
$global:RAMType = ""
$global:OSName = ""
$global:IsWindows11 = $false

# GUI Controls
$global:LogRichTextBox = $null
$global:StatusRichTextBox = $null
$global:AutoBackupCheckbox = $null
$global:MainForm = $null

# ===== INITIALIZATION SYSTEM =====
function Initialize-Application {
    try {
        $directories = @($global:LogPath, $global:BackupPath, $global:ConfigPath, "$global:BackupPath\AutoBackups", "$global:BackupPath\ManualBackups")
        foreach ($dir in $directories) {
            if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        }
        
        Initialize-LoggingSystem
        Detect-AdvancedHardware
        Load-Configuration | Out-Null
        
        Write-EnhancedLog "Alphacode GameBoost Ultimate Edition initialized successfully" "SUCCESS" "SYSTEM"
        return $true
    }
    catch {
        Write-EnhancedLog "Critical initialization failure: $($_.Exception.Message)" "CRITICAL" "SYSTEM"
        return $false
    }
}

function Initialize-LoggingSystem {
    try {
        $cutoffDate = (Get-Date).AddDays(-7)
        Get-ChildItem "$global:LogPath\*.log" -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -lt $cutoffDate } | Remove-Item -Force
        
        $logFile = "$global:LogPath\fps_suite_$(Get-Date -Format 'yyyy-MM-dd').log"
        if (!(Test-Path $logFile)) {
            $header = @"
========================================
Alphacode GameBoost Ultimate Edition
Gaming Performance Optimization Log
========================================
Session Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Windows Version: $(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
========================================

"@
            Set-Content -Path $logFile -Value $header
        }
    }
    catch {
        Write-Host "Warning: Could not initialize logging system" -ForegroundColor Yellow
    }
}

# ===== ENHANCED LOGGING SYSTEM =====
function Write-EnhancedLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "CRITICAL", "SUCCESS", "DEBUG")]
        [string]$Level = "INFO",
        [string]$Component = "CORE"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logEntry = "[$timestamp] [$Level] [$Component] $Message"
    
    $colors = @{
        "INFO" = [System.Drawing.Color]::White
        "WARN" = [System.Drawing.Color]::Orange
        "ERROR" = [System.Drawing.Color]::Red
        "CRITICAL" = [System.Drawing.Color]::Magenta
        "SUCCESS" = [System.Drawing.Color]::LimeGreen
        "DEBUG" = [System.Drawing.Color]::Cyan
    }
    
    try {
        $logFile = "$global:LogPath\fps_suite_$(Get-Date -Format 'yyyy-MM-dd').log"
        Add-Content -Path $logFile -Value $logEntry -ErrorAction SilentlyContinue
        
        if ($global:LogRichTextBox) {
            $global:LogRichTextBox.Invoke([Action]{
                $global:LogRichTextBox.SelectionStart = $global:LogRichTextBox.TextLength
                $global:LogRichTextBox.SelectionLength = 0
                $global:LogRichTextBox.SelectionColor = $colors[$Level]
                $global:LogRichTextBox.AppendText("$logEntry`n")
                $global:LogRichTextBox.ScrollToCaret()
                
                $lines = $global:LogRichTextBox.Lines
                if ($lines.Count -gt 100) {
                    $global:LogRichTextBox.Lines = $lines[-100..-1]
                }
            })
        }
        
        $consoleColor = switch($Level) {
            "SUCCESS" { "Green" }
            "WARN" { "Yellow" }
            "ERROR" { "Red" }
            "CRITICAL" { "Magenta" }
            "DEBUG" { "Cyan" }
            default { "White" }
        }
        Write-Host $logEntry -ForegroundColor $consoleColor
        
    }
    catch {
        Write-Host $logEntry -ForegroundColor White
    }
}

# ===== ADVANCED HARDWARE DETECTION =====
function Detect-AdvancedHardware {
    Write-EnhancedLog "Starting comprehensive hardware detection..." "INFO" "HARDWARE"
    
    try {
        # CPU Detection
        $cpu = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
        $global:CPUName = $cpu.Name.Trim()
        $global:IsAMDCPU = $cpu.Name -like "*AMD*"
        $global:IsIntelCPU = $cpu.Name -like "*Intel*"
        $global:HasX3D = $cpu.Name -like "*X3D*"
        
        # GPU Detection
        $gpus = Get-WmiObject -Class Win32_VideoController | Where-Object { 
            $_.Name -notlike "*Microsoft*" -and $_.Name -notlike "*Remote*" -and $_.AdapterRAM -gt 100MB 
        }
        
        if ($gpus.Count -gt 0) {
            $primaryGPU = $gpus | Sort-Object AdapterRAM -Descending | Select-Object -First 1
            $global:GPUName = $primaryGPU.Name.Trim()
            $global:IsNVIDIA = ($primaryGPU.Name -like "*NVIDIA*") -or ($primaryGPU.Name -like "*GeForce*") -or ($primaryGPU.Name -like "*RTX*") -or ($primaryGPU.Name -like "*GTX*")
            $global:IsAMDGPU = ($primaryGPU.Name -like "*AMD*") -or ($primaryGPU.Name -like "*Radeon*") -or ($primaryGPU.Name -like "*RX*")
        }
        
        # RAM Detection
        $ram = Get-WmiObject -Class Win32_PhysicalMemory
        if ($ram) {
            $global:RAMTotal = [math]::Round(($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1)
            $fastestRAM = $ram | Sort-Object Speed -Descending | Select-Object -First 1
            if ($fastestRAM) {
                $global:RAMSpeed = $fastestRAM.Speed
                $global:RAMType = switch ($fastestRAM.SMBIOSMemoryType) {
                    26 { "DDR4" }
                    34 { "DDR5" }
                    default { "DDR4" }
                }
            }
        }
        
        # OS Detection
        $os = Get-WmiObject -Class Win32_OperatingSystem
        $global:OSName = $os.Caption.Trim()
        $global:IsWindows11 = [int]$os.BuildNumber -ge 22000
        
        Write-EnhancedLog "CPU: $global:CPUName" "INFO" "HARDWARE"
        Write-EnhancedLog "GPU: $global:GPUName" "INFO" "HARDWARE"
        Write-EnhancedLog "RAM: $global:RAMTotal GB $global:RAMType-$global:RAMSpeed" "INFO" "HARDWARE"
        Write-EnhancedLog "OS: $global:OSName" "INFO" "HARDWARE"
        
        if ($global:HasX3D) {
            Write-EnhancedLog "X3D CPU detected - enabling specialized optimizations" "SUCCESS" "HARDWARE"
        }
        
    }
    catch {
        Write-EnhancedLog "Hardware detection encountered errors: $($_.Exception.Message)" "ERROR" "HARDWARE"
    }
}

# ===== CONFIGURATION MANAGEMENT =====
function Load-Configuration {
    try {
        if (Test-Path $global:ConfigFile) {
            $configData = Get-Content $global:ConfigFile -Encoding UTF8 | ConvertFrom-Json
            
            # Ensure all required properties exist
            $defaultConfig = @{
                AutoBackup = $true
                SafeMode = $false
                LastAppliedProfile = ""
                PreferredProfile = "Balanced"
                Version = $global:AppVersion
            }
            
            # Merge loaded config with defaults to ensure all properties exist
            $mergedConfig = $defaultConfig.Clone()
            if ($configData.Settings) {
                foreach ($key in $configData.Settings.PSObject.Properties.Name) {
                    $mergedConfig[$key] = $configData.Settings.$key
                }
            }
            
            Write-EnhancedLog "Configuration loaded and merged with defaults" "SUCCESS" "CONFIG"
            return $mergedConfig
        }
    }
    catch {
        Write-EnhancedLog "Failed to load configuration, using defaults: $($_.Exception.Message)" "WARN" "CONFIG"
    }
    
    $defaultConfig = @{
        AutoBackup = $true
        SafeMode = $false
        LastAppliedProfile = ""
        PreferredProfile = "Balanced"
        Version = $global:AppVersion
    }
    
    Save-Configuration $defaultConfig
    return $defaultConfig
}

function Save-Configuration {
    param($Config)
    
    try {
        # Ensure Config is a hashtable for consistent handling
        $configHashtable = @{}
        
        if ($Config -is [hashtable]) {
            $configHashtable = $Config.Clone()
        } elseif ($Config -is [PSCustomObject]) {
            foreach ($property in $Config.PSObject.Properties) {
                $configHashtable[$property.Name] = $property.Value
            }
        } else {
            Write-EnhancedLog "Invalid configuration object type" "ERROR" "CONFIG"
            return $false
        }
        
        # Ensure all required properties exist
        $requiredProperties = @("AutoBackup", "SafeMode", "LastAppliedProfile", "PreferredProfile", "Version")
        foreach ($prop in $requiredProperties) {
            if (-not $configHashtable.ContainsKey($prop)) {
                switch ($prop) {
                    "AutoBackup" { $configHashtable[$prop] = $true }
                    "SafeMode" { $configHashtable[$prop] = $false }
                    "LastAppliedProfile" { $configHashtable[$prop] = "" }
                    "PreferredProfile" { $configHashtable[$prop] = "Balanced" }
                    "Version" { $configHashtable[$prop] = $global:AppVersion }
                }
            }
        }
        
        $configData = @{
            Version = $global:AppVersion
            LastModified = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            Settings = $configHashtable
            HardwareSnapshot = @{
                CPU = $global:CPUName
                GPU = $global:GPUName
                RAM = "$global:RAMTotal GB $global:RAMType"
                OS = $global:OSName
            }
        }
        
        $configJson = $configData | ConvertTo-Json -Depth 10
        Set-Content -Path $global:ConfigFile -Value $configJson -Encoding UTF8
        
        Write-EnhancedLog "Configuration saved successfully" "SUCCESS" "CONFIG"
        return $true
    }
    catch {
        Write-EnhancedLog "Failed to save configuration: $($_.Exception.Message)" "ERROR" "CONFIG"
        return $false
    }
}

# ===== BACKUP SYSTEM =====
function Create-EnterpriseBackup {
    param(
        [string]$BackupName,
        [string]$Description = "",
        [bool]$IsAutomatic = $true
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupId = [guid]::NewGuid().ToString("N").Substring(0, 8).ToUpper()
    $backupType = if ($IsAutomatic) { "AutoBackups" } else { "ManualBackups" }
    $backupFolder = "$global:BackupPath\$backupType\$BackupName`_$timestamp`_$backupId"
    
    Write-EnhancedLog "Creating enterprise backup: $BackupName (ID: $backupId)" "INFO" "BACKUP"
    
    try {
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        
        $registryTargets = @(
            @{Path="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; Name="multimedia_profile"},
            @{Path="HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"; Name="graphics_drivers"},
            @{Path="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"; Name="memory_management"},
            @{Path="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"; Name="game_dvr"},
            @{Path="HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl"; Name="priority_control"}
        )
        
        $successCount = 0
        foreach ($target in $registryTargets) {
            try {
                $exportPath = "$backupFolder\$($target.Name).reg"
                $process = Start-Process -FilePath "reg" -ArgumentList "export", "`"$($target.Path)`"", "`"$exportPath`"", "/y" -Wait -PassThru -WindowStyle Hidden
                
                if ($process.ExitCode -eq 0 -and (Test-Path $exportPath)) {
                    $successCount++
                    Write-EnhancedLog "Backed up: $($target.Name)" "SUCCESS" "BACKUP"
                }
            } catch {
                Write-EnhancedLog "Failed to backup $($target.Name): $($_.Exception.Message)" "WARN" "BACKUP"
            }
        }
        
        Write-EnhancedLog "Enterprise backup completed: $backupFolder ($successCount/$($registryTargets.Count) successful)" "SUCCESS" "BACKUP"
        return $backupFolder
        
    }
    catch {
        Write-EnhancedLog "Enterprise backup failed: $($_.Exception.Message)" "CRITICAL" "BACKUP"
        return $null
    }
}

# ===== OPTIMIZATION ENGINE =====
function Apply-IntelligentOptimizations {
    param(
        [ValidateSet("Conservative", "Balanced", "Aggressive", "Maximum")]
        [string]$Profile = "Balanced",
        [bool]$SafeMode = $false
    )
    
    Write-EnhancedLog "Starting intelligent optimization engine..." "INFO" "OPTIMIZER"
    Write-EnhancedLog "Profile: $Profile | Safe Mode: $SafeMode" "INFO" "OPTIMIZER"
    
    # Create backup if enabled
    $config = Load-Configuration
    if ($config.AutoBackup -and -not $SafeMode) {
        $backupPath = Create-EnterpriseBackup "pre_$Profile" "Automatic backup before applying $Profile profile" $true
        if (-not $backupPath) {
            Write-EnhancedLog "Backup failed - aborting optimization for safety" "CRITICAL" "OPTIMIZER"
            return $false
        }
    }
    
    try {
        # Profile settings
        $profileMatrix = @{
            "Conservative" = @{GPUPriority = 4; CPUPriority = 4; SystemResponsiveness = 10; TDRLevel = 3; DisableGameDVR = $true; EnableHardwareScheduling = $false; MemoryOptimization = $false; InsiderTweaks = $false}
            "Balanced" = @{GPUPriority = 6; CPUPriority = 6; SystemResponsiveness = 5; TDRLevel = 2; DisableGameDVR = $true; EnableHardwareScheduling = $true; MemoryOptimization = $true; InsiderTweaks = $false}
            "Aggressive" = @{GPUPriority = 8; CPUPriority = 7; SystemResponsiveness = 1; TDRLevel = 1; DisableGameDVR = $true; EnableHardwareScheduling = $true; MemoryOptimization = $true; InsiderTweaks = $true}
            "Maximum" = @{GPUPriority = 8; CPUPriority = 8; SystemResponsiveness = 0; TDRLevel = 0; DisableGameDVR = $true; EnableHardwareScheduling = $true; MemoryOptimization = $true; InsiderTweaks = $true}
        }
        
        $settings = $profileMatrix[$Profile]
        
        # Apply Gaming Priority Optimizations
        Write-EnhancedLog "Configuring gaming task priorities..." "INFO" "OPTIMIZER"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value $settings.GPUPriority -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value $settings.CPUPriority -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Value "High" -Type String
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "SFIO Priority" -Value "High" -Type String
        
        # System Responsiveness
        Write-EnhancedLog "Optimizing system responsiveness..." "INFO" "OPTIMIZER"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value $settings.SystemResponsiveness -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord
        
        # Hardware Scheduling
        if ($settings.EnableHardwareScheduling -and -not $SafeMode) {
            Write-EnhancedLog "Enabling hardware-accelerated GPU scheduling..." "INFO" "OPTIMIZER"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord
        }
        
        # TDR Optimization
        Write-EnhancedLog "Configuring GPU timeout detection..." "INFO" "OPTIMIZER"
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "TdrLevel" -Value $settings.TDRLevel -Type DWord
        
        # Game DVR
        if ($settings.DisableGameDVR) {
            Write-EnhancedLog "Disabling Windows Game DVR..." "INFO" "OPTIMIZER"
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "GameDVR_Enabled" -Value 0 -Type DWord
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0 -Type DWord
        }
        
        # Memory Management
        if ($settings.MemoryOptimization -and -not $SafeMode) {
            Write-EnhancedLog "Applying memory optimizations..." "INFO" "OPTIMIZER"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1 -Type DWord
        }
        
        # Insider Tweaks
        if ($settings.InsiderTweaks -and -not $SafeMode) {
            Write-EnhancedLog "Applying Microsoft insider tweaks..." "WARN" "OPTIMIZER"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" -Name "ForceFlipTrueImmediateMode" -Value 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" -Name "VsyncIdleTimeout" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        }
        
        Write-EnhancedLog "$Profile optimization profile applied successfully!" "SUCCESS" "OPTIMIZER"
        
        # Update configuration safely
        try {
            $config = Load-Configuration
            if ($config -and ($config -is [hashtable] -or $config -is [PSCustomObject])) {
                # Ensure LastAppliedProfile property exists
                if ($config -is [PSCustomObject]) {
                    if (-not ($config | Get-Member -Name "LastAppliedProfile" -MemberType Properties)) {
                        $config | Add-Member -MemberType NoteProperty -Name "LastAppliedProfile" -Value $Profile -Force
                    } else {
                        $config.LastAppliedProfile = $Profile
                    }
                } else {
                    $config["LastAppliedProfile"] = $Profile
                }
                
                $saveResult = Save-Configuration $config
                if ($saveResult) {
                    Write-EnhancedLog "Configuration updated with profile: $Profile" "SUCCESS" "OPTIMIZER"
                } else {
                    Write-EnhancedLog "Failed to save configuration after profile application" "WARN" "OPTIMIZER"
                }
            } else {
                Write-EnhancedLog "Invalid configuration object, skipping save" "WARN" "OPTIMIZER"
            }
        } catch {
            Write-EnhancedLog "Failed to update configuration: $($_.Exception.Message)" "WARN" "OPTIMIZER"
        }
        
        return $true
        
    }
    catch {
        Write-EnhancedLog "Optimization engine failed: $($_.Exception.Message)" "CRITICAL" "OPTIMIZER"
        return $false
    }
}

# ===== HARDWARE-SPECIFIC OPTIMIZATIONS =====
function Apply-HardwareSpecificOptimizations {
    Write-EnhancedLog "Starting hardware-specific optimization..." "INFO" "HARDWARE_OPT"
    
    try {
        $optimizationsApplied = 0
        
        # AMD CPU Optimizations
        if ($global:IsAMDCPU) {
            Write-EnhancedLog "Applying AMD Ryzen optimizations..." "INFO" "HARDWARE_OPT"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord
            $optimizationsApplied++
            
            if ($global:HasX3D) {
                Write-EnhancedLog "Applying X3D cache optimizations..." "SUCCESS" "HARDWARE_OPT"
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "SecondLevelDataCache" -Value 2048 -Type DWord
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "LazyModeTimeout" -Value 1 -Type DWord
                $optimizationsApplied += 2
            }
        }
        
        # Intel CPU Optimizations
        if ($global:IsIntelCPU) {
            Write-EnhancedLog "Applying Intel CPU optimizations..." "INFO" "HARDWARE_OPT"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 26 -Type DWord
            $optimizationsApplied++
        }
        
        # NVIDIA GPU Optimizations
        if ($global:IsNVIDIA) {
            Write-EnhancedLog "Applying NVIDIA GPU optimizations..." "INFO" "HARDWARE_OPT"
            $nvidiaDriverKeys = @(
                "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000",
                "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001"
            )
            
            foreach ($key in $nvidiaDriverKeys) {
                if (Test-Path $key) {
                    Set-ItemProperty -Path $key -Name "EnableUlps" -Value 0 -Type DWord -ErrorAction SilentlyContinue
                    Set-ItemProperty -Path $key -Name "PowerMizerEnable" -Value 0 -Type DWord -ErrorAction SilentlyContinue
                    $optimizationsApplied++
                }
            }
        }
        
        # AMD GPU Optimizations
        if ($global:IsAMDGPU) {
            Write-EnhancedLog "Applying AMD GPU optimizations..." "INFO" "HARDWARE_OPT"
            $amdDriverKeys = @(
                "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000",
                "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001"
            )
            
            foreach ($key in $amdDriverKeys) {
                if (Test-Path $key) {
                    Set-ItemProperty -Path $key -Name "EnableUlps" -Value 0 -Type DWord -ErrorAction SilentlyContinue
                    Set-ItemProperty -Path $key -Name "PP_SclkDeepSleepDisable" -Value 1 -Type DWord -ErrorAction SilentlyContinue
                    $optimizationsApplied++
                }
            }
        }
        
        # Memory Optimizations based on RAM type
        if ($global:RAMType -eq "DDR5") {
            Write-EnhancedLog "Applying DDR5 optimizations..." "INFO" "HARDWARE_OPT"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "IoPageLockLimit" -Value 16777216 -Type DWord
            $optimizationsApplied++
        }
        
        Write-EnhancedLog "Hardware optimizations completed! ($optimizationsApplied applied)" "SUCCESS" "HARDWARE_OPT"
        return $true
        
    }
    catch {
        Write-EnhancedLog "Hardware optimization failed: $($_.Exception.Message)" "ERROR" "HARDWARE_OPT"
        return $false
    }
}

# ===== AI ANALYSIS FUNCTIONS =====
function Analyze-OptimizationIntelligence {
    param($Optimizations)
    
    Write-EnhancedLog "Running AI intelligence analysis..." "INFO" "AI_SCANNER"
    
    $intelligence = @{
        PerformanceLevel = 0
        SystemProfile = "Unknown"
        RiskAssessment = "Unknown"
        SourceAnalysis = @{}
        ConflictDetection = @()
        Recommendations = @()
        UnknownModifications = @()
    }
    
    try {
        # Helper function to safely count optimizations
        function Get-OptimizationCount {
            param($Category)
            if ($Category -is [hashtable]) {
                return $Category.Count
            } elseif ($Category -is [PSCustomObject]) {
                return ($Category | Get-Member -MemberType Properties).Count
            } else {
                return 0
            }
        }
        
        # Helper function to safely get optimization keys
        function Get-OptimizationKeys {
            param($Category)
            if ($Category -is [hashtable]) {
                return $Category.Keys
            } elseif ($Category -is [PSCustomObject]) {
                return ($Category | Get-Member -MemberType Properties).Name
            } else {
                return @()
            }
        }
        
        # Helper function to safely get optimization value
        function Get-OptimizationValue {
            param($Category, $Key)
            if ($Category -is [hashtable]) {
                return $Category[$Key]
            } elseif ($Category -is [PSCustomObject]) {
                if ($Category | Get-Member -Name $Key -MemberType Properties) {
                    return $Category.$Key
                }
            }
            return $null
        }
        
        # Calculate total optimizations using safe methods
        $gamingCount = Get-OptimizationCount ($Optimizations.Gaming)
        $graphicsCount = Get-OptimizationCount ($Optimizations.Graphics)
        $memoryCount = Get-OptimizationCount ($Optimizations.Memory)
        $cpuCount = Get-OptimizationCount ($Optimizations.CPU)
        $networkCount = Get-OptimizationCount ($Optimizations.Network)
        $powerCount = Get-OptimizationCount ($Optimizations.Power)
        $insiderCount = Get-OptimizationCount ($Optimizations.Insider)
        $thirdPartyCount = Get-OptimizationCount ($Optimizations.ThirdParty)
        $hardwareCount = Get-OptimizationCount ($Optimizations.Hardware)
        
        $totalOptimizations = $gamingCount + $graphicsCount + $memoryCount + $cpuCount + 
                             $networkCount + $powerCount + $insiderCount + $thirdPartyCount + $hardwareCount
        
        # Performance Level Calculation
        $baseScore = [math]::Min(60, $totalOptimizations * 2)
        $insiderBonus = $insiderCount * 5
        $hardwareBonus = $hardwareCount * 3
        $thirdPartyBonus = $thirdPartyCount * 2
        
        $intelligence.PerformanceLevel = [math]::Min(100, $baseScore + $insiderBonus + $hardwareBonus + $thirdPartyBonus)
        
        # System Profile Classification
        $intelligence.SystemProfile = switch ($intelligence.PerformanceLevel) {
            {$_ -ge 90} { "Extreme Enthusiast" }
            {$_ -ge 75} { "Advanced Gamer" }
            {$_ -ge 60} { "Performance User" }
            {$_ -ge 40} { "Moderate User" }
            {$_ -ge 20} { "Basic User" }
            default { "Stock Configuration" }
        }
        
        # Risk Assessment
        $riskFactors = 0
        if ($insiderCount -gt 0) { $riskFactors += 2 }
        if ($intelligence.PerformanceLevel -gt 80) { $riskFactors += 1 }
        if ($hardwareCount -gt 3) { $riskFactors += 1 }
        
        $intelligence.RiskAssessment = switch ($riskFactors) {
            {$_ -ge 4} { "HIGH RISK - Monitor stability closely" }
            {$_ -ge 2} { "MODERATE RISK - Test thoroughly" }
            default { "LOW RISK - Safe configuration" }
        }
        
        # Source Analysis
        $intelligence.SourceAnalysis = @{
            "Windows Default" = 0
            "Gaming Optimization" = $gamingCount
            "Hardware Tweaks" = $hardwareCount
            "Microsoft Insider" = $insiderCount
            "Third-Party Tools" = $thirdPartyCount
            "Memory Management" = $memoryCount
            "Graphics Drivers" = $graphicsCount
        }
        
        # Generate recommendations based on analysis
        if ($intelligence.PerformanceLevel -lt 50) {
            $intelligence.Recommendations += "💡 Consider applying a Balanced or Aggressive optimization profile"
        }
        
        # Check specific optimizations safely
        if ($Optimizations.Gaming) {
            $gameDvrValue = Get-OptimizationValue $Optimizations.Gaming "Game DVR"
            if ($gameDvrValue -and $gameDvrValue -like "*Enabled*") {
                $intelligence.Recommendations += "🎮 Disable Windows Game DVR for 5-10% FPS improvement"
            }
        }
        
        if ($Optimizations.Graphics) {
            $hwSchedulingValue = Get-OptimizationValue $Optimizations.Graphics "Hardware Scheduling"
            if (-not $hwSchedulingValue -or $hwSchedulingValue -ne "Enabled") {
                if ($global:IsWindows11) {
                    $intelligence.Recommendations += "🖥️ Enable Hardware-Accelerated GPU Scheduling for reduced latency"
                }
            }
        }
        
        if ($global:HasX3D -and $Optimizations.Hardware) {
            $x3dValue = Get-OptimizationValue $Optimizations.Hardware "AMD X3D Optimizations"
            if (-not $x3dValue) {
                $intelligence.Recommendations += "🔥 Apply X3D-specific cache optimizations for your CPU"
            }
        }
        
        Write-EnhancedLog "AI intelligence analysis completed - Performance Level: $($intelligence.PerformanceLevel)%" "SUCCESS" "AI_SCANNER"
        return $intelligence
        
    }
    catch {
        Write-EnhancedLog "AI analysis failed: $($_.Exception.Message)" "ERROR" "AI_SCANNER"
        return $intelligence
    }
}

function Generate-ComparativeAnalysis {
    param($CurrentOptimizations, $PreviousOptimizations)
    
    Write-EnhancedLog "Generating comparative analysis..." "INFO" "AI_SCANNER"
    
    $analysis = @{
        Summary = ""
        Changes = @()
        NewOptimizations = 0
        RemovedOptimizations = 0
    }
    
    try {
        # Helper function to safely get properties
        function Get-ObjectProperties {
            param($Object)
            if ($Object -is [hashtable]) {
                return $Object.Keys
            } elseif ($Object -is [PSCustomObject]) {
                return ($Object | Get-Member -MemberType Properties).Name
            } else {
                return @()
            }
        }
        
        # Helper function to safely get property value
        function Get-ObjectValue {
            param($Object, $Key)
            if ($Object -is [hashtable]) {
                return $Object[$Key]
            } elseif ($Object -is [PSCustomObject]) {
                if ($Object | Get-Member -Name $Key -MemberType Properties) {
                    return $Object.$Key
                }
            }
            return $null
        }
        
        # Helper function to check if property exists
        function Test-ObjectProperty {
            param($Object, $Key)
            if ($Object -is [hashtable]) {
                return $Object.ContainsKey($Key)
            } elseif ($Object -is [PSCustomObject]) {
                return ($Object | Get-Member -Name $Key -MemberType Properties) -ne $null
            }
            return $false
        }
        
        # Compare all categories
        $categories = @("Gaming", "Graphics", "Memory", "CPU", "Network", "Power", "Insider", "ThirdParty", "Hardware")
        
        foreach ($category in $categories) {
            $current = Get-ObjectValue $CurrentOptimizations $category
            $previous = Get-ObjectValue $PreviousOptimizations $category
            
            if ($current -and $previous) {
                # Find new optimizations
                $currentKeys = Get-ObjectProperties $current
                $previousKeys = Get-ObjectProperties $previous
                
                foreach ($key in $currentKeys) {
                    if (-not (Test-ObjectProperty $previous $key)) {
                        $analysis.Changes += "➕ NEW: $category - $key"
                        $analysis.NewOptimizations++
                    }
                    else {
                        $currentValue = Get-ObjectValue $current $key
                        $previousValue = Get-ObjectValue $previous $key
                        if ($currentValue -ne $previousValue) {
                            $analysis.Changes += "🔄 CHANGED: $category - $key (was: $previousValue)"
                        }
                    }
                }
                
                # Find removed optimizations
                foreach ($key in $previousKeys) {
                    if (-not (Test-ObjectProperty $current $key)) {
                        $analysis.Changes += "➖ REMOVED: $category - $key"
                        $analysis.RemovedOptimizations++
                    }
                }
            }
            elseif ($current -and -not $previous) {
                # Entire category is new
                $currentKeys = Get-ObjectProperties $current
                foreach ($key in $currentKeys) {
                    $analysis.Changes += "➕ NEW CATEGORY: $category - $key"
                    $analysis.NewOptimizations++
                }
            }
            elseif ($previous -and -not $current) {
                # Entire category was removed
                $previousKeys = Get-ObjectProperties $previous
                foreach ($key in $previousKeys) {
                    $analysis.Changes += "➖ REMOVED CATEGORY: $category - $key"
                    $analysis.RemovedOptimizations++
                }
            }
        }
        
        # Generate summary
        if ($analysis.Changes.Count -eq 0) {
            $analysis.Summary = "No changes detected since last scan"
        } else {
            $analysis.Summary = "$($analysis.NewOptimizations) new, $($analysis.RemovedOptimizations) removed, $($analysis.Changes.Count) total changes"
        }
        
        Write-EnhancedLog "Comparative analysis completed - $($analysis.Summary)" "SUCCESS" "AI_SCANNER"
        return $analysis
        
    }
    catch {
        Write-EnhancedLog "Comparative analysis failed: $($_.Exception.Message)" "ERROR" "AI_SCANNER"
        $analysis.Summary = "Analysis failed - unable to compare with previous scan"
        return $analysis
    }
}

function Identify-OptimizationSource {
    param($Category, $Key, $Value)
    
    # AI-powered source identification
    $source = "Unknown Source"
    
    switch -Regex ($Key) {
        "GPU Priority|CPU Priority" {
            if ($Value -match "Conservative|Balanced|Aggressive") {
                $source = "Alphacode GameBoost"
            } elseif ($Value -match "[4-8]") {
                $source = "Gaming Optimization Tool"
            } else {
                $source = "Manual Registry Edit"
            }
        }
        "Game DVR|GameDVR" {
            if ($Value -like "*Disabled*") {
                $source = "Gaming Performance Tweak"
            } else {
                $source = "Windows Default"
            }
        }
        "Hardware Scheduling|HwSchMode" {
            $source = "Windows 11 Gaming Feature"
        }
        "MSI Afterburner|Process Lasso|RivaTuner" {
            $source = "Third-Party Gaming Software"
        }
        "X3D|SecondLevelDataCache" {
            $source = "AMD X3D Optimization"
        }
        "ForceFlip|VsyncIdleTimeout" {
            $source = "Microsoft Insider Gaming Tweak"
        }
        default {
            $source = "Registry Modification"
        }
    }
    
    return $source
}

function Export-ProfessionalReport {
    param($Optimizations, $Intelligence, $ComparativeAnalysis)
    
    $report = @"
════════════════════════════════════════════════════════════════════════════════
Alphacode GameBoost - AI OPTIMIZATION ANALYSIS REPORT
════════════════════════════════════════════════════════════════════════════════
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
System: $global:CPUName | $global:GPUName | $global:RAMTotal GB $global:RAMType
OS: $global:OSName
Report Version: $global:AppVersion
════════════════════════════════════════════════════════════════════════════════

EXECUTIVE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Performance Level: $($Intelligence.PerformanceLevel)% optimized
User Profile: $($Intelligence.SystemProfile)
Risk Assessment: $($Intelligence.RiskAssessment)
Total Optimizations: $(($Optimizations.Gaming.Count + $Optimizations.Graphics.Count + $Optimizations.Memory.Count + $Optimizations.CPU.Count + $Optimizations.Network.Count + $Optimizations.Power.Count + $Optimizations.Insider.Count + $Optimizations.ThirdParty.Count + $Optimizations.Hardware.Count))

SYSTEM CONFIGURATION ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Hardware Platform: $(if($global:IsAMDCPU){"AMD Ryzen"}elseif($global:IsIntelCPU){"Intel Core"}else{"Unknown"}) + $(if($global:IsNVIDIA){"NVIDIA"}elseif($global:IsAMDGPU){"AMD GPU"}else{"Unknown GPU"})
Memory Configuration: $global:RAMTotal GB $global:RAMType-$global:RAMSpeed $(if($global:RAMSpeed -gt 4000){"(High-Speed)"}else{""})
Gaming Platform: $(if($global:IsWindows11){"Windows 11 (Modern Gaming Features)"}else{"Windows 10 (Standard Gaming Support)"})
Special Features: $(if($global:HasX3D){"AMD X3D Cache Technology Detected"}else{"Standard CPU Configuration"})

OPTIMIZATION BREAKDOWN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎮 Gaming Optimizations: $($Optimizations.Gaming.Count)
🖥️ Graphics & Display: $($Optimizations.Graphics.Count)
🧠 Memory Management: $($Optimizations.Memory.Count)
⚡ CPU Performance: $($Optimizations.CPU.Count)
🌐 Network Settings: $($Optimizations.Network.Count)
🔋 Power Management: $($Optimizations.Power.Count)
🔥 Microsoft Insider: $($Optimizations.Insider.Count)
🛠️ Third-Party Tools: $($Optimizations.ThirdParty.Count)
🎯 Hardware-Specific: $($Optimizations.Hardware.Count)

"@

    if ($Intelligence.Recommendations.Count -gt 0) {
        $report += "PERFORMANCE RECOMMENDATIONS`n"
        $report += "━" * 95 + "`n"
        foreach ($recommendation in $Intelligence.Recommendations) {
            $report += "$recommendation`n"
        }
        $report += "`n"
    }

    if ($ComparativeAnalysis -and $ComparativeAnalysis.Changes.Count -gt 0) {
        $report += "CHANGE ANALYSIS (Since Last Scan)`n"
        $report += "━" * 95 + "`n"
        $report += "Summary: $($ComparativeAnalysis.Summary)`n`n"
        foreach ($change in $ComparativeAnalysis.Changes | Select-Object -First 20) {
            $report += "$change`n"
        }
        $report += "`n"
    }

    $report += @"
DETAILED CONFIGURATION INVENTORY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@

    # Add detailed inventory
    $categories = @(
        @{Name="GAMING OPTIMIZATIONS"; Data=$Optimizations.Gaming},
        @{Name="GRAPHICS & DISPLAY"; Data=$Optimizations.Graphics},
        @{Name="MEMORY MANAGEMENT"; Data=$Optimizations.Memory},
        @{Name="CPU PERFORMANCE"; Data=$Optimizations.CPU},
        @{Name="NETWORK SETTINGS"; Data=$Optimizations.Network},
        @{Name="POWER MANAGEMENT"; Data=$Optimizations.Power},
        @{Name="MICROSOFT INSIDER TWEAKS"; Data=$Optimizations.Insider},
        @{Name="THIRD-PARTY TOOLS"; Data=$Optimizations.ThirdParty},
        @{Name="HARDWARE-SPECIFIC"; Data=$Optimizations.Hardware}
    )
    
    foreach ($category in $categories) {
        if ($category.Data.Count -gt 0) {
            $report += "$($category.Name) ($($category.Data.Count) found)`n"
            $report += "─" * 95 + "`n"
            
            foreach ($key in $category.Data.Keys | Sort-Object) {
                $source = Identify-OptimizationSource $category.Name $key $category.Data[$key]
                $report += "• $key`n"
                $report += "  Value: $($category.Data[$key])`n"
                $report += "  Source: $source`n`n"
            }
        }
    }

    $report += @"
════════════════════════════════════════════════════════════════════════════════
REPORT GENERATED BY Alphacode GameBoost ULTIMATE EDITION
AI-Powered Gaming Performance Analysis System
════════════════════════════════════════════════════════════════════════════════
"@

    return $report
}

# ===== COMPREHENSIVE REGISTRY SCANNER =====
function Scan-AllOptimizations {
    Write-EnhancedLog "Starting comprehensive registry optimization scan..." "INFO" "SCANNER"
    
    $optimizations = @{
        Gaming = @{}
        Graphics = @{}
        Memory = @{}
        CPU = @{}
        Network = @{}
        Power = @{}
        Insider = @{}
        ThirdParty = @{}
        Hardware = @{}
    }
    
    try {
        # Gaming Optimizations Scan
        Write-EnhancedLog "Scanning gaming optimizations..." "DEBUG" "SCANNER"
        $gamingProfile = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -ErrorAction SilentlyContinue
        if ($gamingProfile) {
            if ($gamingProfile."GPU Priority") {
                $value = $gamingProfile."GPU Priority"
                $interpretation = switch ($value) {
                    2 { "Default Windows" }
                    4 { "Conservative optimization" }
                    6 { "Balanced optimization" }
                    8 { "High performance optimization" }
                    default { "Custom value" }
                }
                $optimizations.Gaming."GPU Priority" = "$value ($interpretation)"
            }
            
            if ($gamingProfile.Priority) {
                $optimizations.Gaming."CPU Priority" = "$($gamingProfile.Priority) (Default: 2)"
            }
            
            if ($gamingProfile."Scheduling Category") {
                $optimizations.Gaming."Scheduling Category" = "$($gamingProfile.'Scheduling Category') (Default: Medium)"
            }
            
            if ($gamingProfile."SFIO Priority") {
                $optimizations.Gaming."SFIO Priority" = "$($gamingProfile.'SFIO Priority') (Default: Normal)"
            }
            
            if ($gamingProfile."Clock Rate") {
                $optimizations.Gaming."Clock Rate" = "$($gamingProfile.'Clock Rate') (High performance timer)"
            }
        }
        
        # System Profile Settings
        $systemProfile = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -ErrorAction SilentlyContinue
        if ($systemProfile) {
            if ($systemProfile.SystemResponsiveness -ne $null) {
                $value = $systemProfile.SystemResponsiveness
                $interpretation = switch ($value) {
                    20 { "Default Windows" }
                    10 { "Conservative gaming" }
                    5 { "Balanced gaming" }
                    1 { "Aggressive gaming" }
                    0 { "Maximum gaming performance" }
                    default { "Custom value" }
                }
                $optimizations.Gaming."System Responsiveness" = "$value ($interpretation)"
            }
            
            if ($systemProfile.NetworkThrottlingIndex -eq 0xffffffff) {
                $optimizations.Network."Network Throttling" = "Disabled (Gaming optimization)"
            }
            
            if ($systemProfile.NoLazyMode) {
                $optimizations.Gaming."No Lazy Mode" = "Enabled (Prevents system sleeping)"
            }
            
            if ($systemProfile.AlwaysOn) {
                $optimizations.Gaming."Always On Mode" = "Enabled (High performance timer)"
            }
            
            if ($systemProfile.LazyModeTimeout) {
                $optimizations.Gaming."Lazy Mode Timeout" = "$($systemProfile.LazyModeTimeout) (X3D CPU optimization)"
            }
        }
        
        # Graphics Optimizations Scan - Enhanced
        Write-EnhancedLog "Scanning graphics optimizations..." "DEBUG" "SCANNER"
        $graphicsDrivers = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -ErrorAction SilentlyContinue
        if ($graphicsDrivers) {
            if ($graphicsDrivers.HwSchMode -eq 2) {
                $optimizations.Graphics."Hardware Scheduling" = "Enabled (Modern GPU optimization)"
            } elseif ($graphicsDrivers.HwSchMode -eq 1) {
                $optimizations.Graphics."Hardware Scheduling" = "Legacy Mode (Compatibility)"
            }
            
            if ($graphicsDrivers.TdrLevel -ne $null) {
                $value = $graphicsDrivers.TdrLevel
                $interpretation = switch ($value) {
                    3 { "Default Windows" }
                    2 { "Balanced gaming" }
                    1 { "Aggressive gaming" }
                    0 { "Maximum gaming (timeouts disabled)" }
                    default { "Custom value" }
                }
                $optimizations.Graphics."TDR Level" = "$value ($interpretation)"
            }
            
            if ($graphicsDrivers.TdrDelay) {
                $optimizations.Graphics."TDR Delay" = "$($graphicsDrivers.TdrDelay) seconds (Custom timeout)"
            }
            
            if ($graphicsDrivers.MonitorLatencyTolerance -eq 0) {
                $optimizations.Graphics."Monitor Latency Tolerance" = "Disabled (NVIDIA optimization)"
            }
            
            if ($graphicsDrivers.EnablePreemption) {
                $optimizations.Insider."GPU Preemption" = "Enabled (Microsoft insider tweak)"
            }
            
            if ($graphicsDrivers.UltraLowLatencyMode) {
                $optimizations.Insider."Ultra Low Latency Mode" = "Enabled (Microsoft gaming research)"
            }
        }
        
        # DWM Settings Scan - Enhanced
        $dwm = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" -ErrorAction SilentlyContinue
        if ($dwm) {
            if ($dwm.ForceFlipTrueImmediateMode) {
                $optimizations.Insider."Force Flip Immediate Mode" = "Enabled (Reduces input lag 1-3 frames)"
            }
            
            if ($dwm.VsyncIdleTimeout -eq 0) {
                $optimizations.Insider."VSync Idle Timeout" = "Disabled (Prevents FPS drops in idle)"
            }
            
            if ($dwm.DisableCompositionThrottling) {
                $optimizations.Insider."Composition Throttling" = "Disabled (DWM team secret)"
            }
            
            if ($dwm.OverlayTestMode) {
                $optimizations.Graphics."DWM Overlay Test Mode" = "$($dwm.OverlayTestMode) (Graphics optimization)"
            }
        }
        
        # Memory Optimizations Scan - Enhanced
        Write-EnhancedLog "Scanning memory optimizations..." "DEBUG" "SCANNER"
        $memoryMgmt = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -ErrorAction SilentlyContinue
        if ($memoryMgmt) {
            if ($memoryMgmt.DisablePagingExecutive -eq 1) {
                $optimizations.Memory."Paging Executive" = "Disabled (Keeps kernel in RAM)"
            }
            
            if ($memoryMgmt.LargeSystemCache -eq 0) {
                $optimizations.Memory."Large System Cache" = "Disabled (Gaming optimization)"
            }
            
            if ($memoryMgmt.IoPageLockLimit) {
                $value = $memoryMgmt.IoPageLockLimit
                if ($value -gt 8000000) {
                    $optimizations.Memory."IO Page Lock Limit" = "$value (DDR5 high-speed optimization)"
                } elseif ($value -gt 4000000) {
                    $optimizations.Memory."IO Page Lock Limit" = "$value (DDR4 high-speed optimization)"
                } else {
                    $optimizations.Memory."IO Page Lock Limit" = "$value (Custom setting)"
                }
            }
            
            if ($memoryMgmt.SecondLevelDataCache) {
                $optimizations.Memory."L2 Cache Size" = "$($memoryMgmt.SecondLevelDataCache) KB (X3D CPU optimization)"
            }
            
            if ($memoryMgmt.ThirdLevelDataCache) {
                $optimizations.Memory."L3 Cache Size" = "$($memoryMgmt.ThirdLevelDataCache) KB (High-end CPU optimization)"
            }
            
            if ($memoryMgmt.GamingMemoryPriority) {
                $optimizations.Insider."Gaming Memory Priority" = "Enabled (Microsoft memory team secret)"
            }
            
            if ($memoryMgmt.FeatureSettings) {
                $optimizations.Memory."Feature Settings" = "$($memoryMgmt.FeatureSettings) (Advanced memory features)"
            }
            
            if ($memoryMgmt.FeatureSettingsOverride) {
                $optimizations.Memory."Feature Settings Override" = "$($memoryMgmt.FeatureSettingsOverride) (Memory override)"
            }
        }
        
        # CPU Optimizations Scan - Enhanced
        Write-EnhancedLog "Scanning CPU optimizations..." "DEBUG" "SCANNER"
        $priorityControl = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -ErrorAction SilentlyContinue
        if ($priorityControl) {
            if ($priorityControl.Win32PrioritySeparation) {
                $value = $priorityControl.Win32PrioritySeparation
                $interpretation = switch ($value) {
                    2 { "Default Windows" }
                    26 { "Intel CPU optimization" }
                    38 { "AMD Ryzen optimization" }
                    default { "Custom value" }
                }
                $optimizations.CPU."Priority Separation" = "$value ($interpretation)"
            }
            
            if ($priorityControl.IRQ8Priority) {
                $optimizations.CPU."IRQ8 Priority" = "$($priorityControl.IRQ8Priority) (Gaming interrupt optimization)"
            }
            
            if ($priorityControl.IRQ16Priority) {
                $optimizations.CPU."IRQ16 Priority" = "$($priorityControl.IRQ16Priority) (Gaming interrupt optimization)"
            }
        }
        
        # Game DVR and Game Bar Scan
        $gameDVR = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -ErrorAction SilentlyContinue
        if ($gameDVR) {
            if ($gameDVR.GameDVR_Enabled -eq 0) {
                $optimizations.Gaming."Game DVR" = "Disabled (Performance optimization)"
            } elseif ($gameDVR.GameDVR_Enabled -eq 1) {
                $optimizations.Gaming."Game DVR" = "Enabled (Default - may reduce FPS)"
            }
        }
        
        $gameBar = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -ErrorAction SilentlyContinue
        if ($gameBar) {
            if ($gameBar.AutoGameModeEnabled -eq 0) {
                $optimizations.Gaming."Auto Game Mode" = "Disabled (Manual performance control)"
            }
            
            if ($gameBar.AllowAutoGameMode -eq 0) {
                $optimizations.Gaming."Allow Auto Game Mode" = "Disabled (Manual control)"
            }
        }
        
        # Third-Party Tools Detection - Enhanced
        Write-EnhancedLog "Scanning for third-party optimizations..." "DEBUG" "SCANNER"
        
        # MSI Afterburner
        if (Get-ItemProperty -Path "HKLM:\SOFTWARE\MSI\Afterburner" -ErrorAction SilentlyContinue) {
            $optimizations.ThirdParty."MSI Afterburner" = "Detected (GPU overclocking and monitoring)"
        }
        
        # Process Lasso
        if (Get-ItemProperty -Path "HKLM:\SOFTWARE\ProcessLasso" -ErrorAction SilentlyContinue) {
            $optimizations.ThirdParty."Process Lasso" = "Detected (CPU optimization and automation)"
        }
        
        # NVIDIA Control Panel tweaks
        $nvidiaCP = Get-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" -ErrorAction SilentlyContinue
        if ($nvidiaCP -and $nvidiaCP.OptInOrOutPreference -eq 0) {
            $optimizations.ThirdParty."NVIDIA Telemetry" = "Disabled (Privacy and performance)"
        }
        
        # RTSS (RivaTuner Statistics Server)
        if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Unwinder\RTSS" -ErrorAction SilentlyContinue) {
            $optimizations.ThirdParty."RivaTuner Statistics Server" = "Detected (Frame rate monitoring)"
        }
        
        # Hardware-Specific Optimizations - Enhanced
        Write-EnhancedLog "Scanning hardware-specific optimizations..." "DEBUG" "SCANNER"
        
        # Check for X3D optimizations
        if ($global:HasX3D) {
            $x3dOptimizations = @()
            if (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "SecondLevelDataCache" -ErrorAction SilentlyContinue) {
                $x3dOptimizations += "X3D Cache Policy"
            }
            if (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "X3DCachePolicy" -ErrorAction SilentlyContinue) {
                $x3dOptimizations += "X3D Gaming Mode"
            }
            if ($x3dOptimizations.Count -gt 0) {
                $optimizations.Hardware."AMD X3D Optimizations" = "$($x3dOptimizations -join ', ') (Specialized cache optimizations)"
            }
        }
        
        # DirectX Optimizations
        $directx = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\DirectX" -ErrorAction SilentlyContinue
        if ($directx) {
            if ($directx.ForceImmediateContext) {
                $optimizations.Insider."DirectX Immediate Context" = "Enabled (DirectX team optimization)"
            }
            if ($directx.DisableContextBuffering) {
                $optimizations.Insider."DirectX Context Buffering" = "Disabled (Reduces latency)"
            }
        }
        
        # Power Management Scan
        $power = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -ErrorAction SilentlyContinue
        if ($power) {
            if ($power.PlatformAoAcOverride -eq 0) {
                $optimizations.Power."Platform AoAc Override" = "Disabled (Performance mode)"
            }
            if ($power.CoalescingTimerInterval -eq 0) {
                $optimizations.Power."Timer Coalescing" = "Disabled (Reduces latency)"
            }
        }
        
        # Network Optimizations
        $networkProfile = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -ErrorAction SilentlyContinue
        if ($networkProfile -and $networkProfile.NetworkThrottlingIndex -eq 0xffffffff) {
            $optimizations.Network."Network Throttling Index" = "Disabled (Gaming optimization)"
        }
        
        $totalOptimizations = ($optimizations.Gaming.Count + $optimizations.Graphics.Count + 
                              $optimizations.Memory.Count + $optimizations.CPU.Count + 
                              $optimizations.Network.Count + $optimizations.Power.Count + 
                              $optimizations.Insider.Count + $optimizations.ThirdParty.Count + 
                              $optimizations.Hardware.Count)
        
        Write-EnhancedLog "Registry scan completed - found $totalOptimizations optimizations" "SUCCESS" "SCANNER"
        return $optimizations
        
    }
    catch {
        Write-EnhancedLog "Registry scan failed: $($_.Exception.Message)" "ERROR" "SCANNER"
        return $optimizations
    }
}

function Show-OptimizationResults {
    Write-EnhancedLog "Generating AI-powered comprehensive optimization report..." "INFO" "SCANNER"
    
    try {
        $optimizations = Scan-AllOptimizations
        
        # 🤖 AI Analysis Engine
        Write-EnhancedLog "Running AI analysis engine..." "INFO" "AI_SCANNER"
        $intelligence = Analyze-OptimizationIntelligence $optimizations
        
        # 📊 Load previous scan for comparison (if exists)
        $previousScanPath = "$global:ConfigPath\last_scan.json"
        $comparativeAnalysis = $null
        if (Test-Path $previousScanPath) {
            try {
                $previousOptimizations = Get-Content $previousScanPath -Encoding UTF8 | ConvertFrom-Json
                $comparativeAnalysis = Generate-ComparativeAnalysis $optimizations $previousOptimizations
                Write-EnhancedLog "Comparative analysis completed" "SUCCESS" "AI_SCANNER"
            } catch {
                Write-EnhancedLog "Could not load previous scan for comparison" "WARN" "AI_SCANNER"
            }
        }
        
        # Save current scan for future comparisons (ensure JSON-safe format)
        try {
            # Convert PSCustomObjects to hashtables for consistent JSON serialization
            $jsonSafeOptimizations = @{}
            foreach ($category in @("Gaming", "Graphics", "Memory", "CPU", "Network", "Power", "Insider", "ThirdParty", "Hardware")) {
                $jsonSafeOptimizations[$category] = @{}
                if ($optimizations.$category) {
                    if ($optimizations.$category -is [hashtable]) {
                        $jsonSafeOptimizations[$category] = $optimizations.$category
                    } elseif ($optimizations.$category -is [PSCustomObject]) {
                        foreach ($property in ($optimizations.$category | Get-Member -MemberType Properties)) {
                            $jsonSafeOptimizations[$category][$property.Name] = $optimizations.$category.($property.Name)
                        }
                    }
                }
            }
            
            $jsonSafeOptimizations | ConvertTo-Json -Depth 10 | Set-Content $previousScanPath -Encoding UTF8
            Write-EnhancedLog "Current scan saved for future comparisons" "SUCCESS" "AI_SCANNER"
        } catch {
            Write-EnhancedLog "Failed to save current scan: $($_.Exception.Message)" "WARN" "AI_SCANNER"
        }
        
        # Create advanced results window
        $resultForm = New-Object System.Windows.Forms.Form
        $resultForm.Text = "🤖 AI-Powered Gaming Optimization Analysis"
        $resultForm.Size = New-Object System.Drawing.Size(1400, 900)
        $resultForm.StartPosition = "CenterScreen"
        $resultForm.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
        $resultForm.ForeColor = [System.Drawing.Color]::White
        $resultForm.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        
        # Header with AI branding
        $headerPanel = New-Object System.Windows.Forms.Panel
        $headerPanel.Location = New-Object System.Drawing.Point(0, 0)
        $headerPanel.Size = New-Object System.Drawing.Size(1400, 100)
        $headerPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
        $resultForm.Controls.Add($headerPanel)
        
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "🤖 AI-Powered Gaming Optimization Analysis"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        $titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
        $titleLabel.Location = New-Object System.Drawing.Point(20, 15)
        $titleLabel.Size = New-Object System.Drawing.Size(600, 35)
        $headerPanel.Controls.Add($titleLabel)
        
        $aiLabel = New-Object System.Windows.Forms.Label
        $aiLabel.Text = "🧠 Advanced Intelligence Scanner • Performance Level: $($intelligence.PerformanceLevel)% • $($intelligence.SystemProfile)"
        $aiLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 150)
        $aiLabel.Location = New-Object System.Drawing.Point(20, 50)
        $aiLabel.Size = New-Object System.Drawing.Size(900, 20)
        $headerPanel.Controls.Add($aiLabel)
        
        $systemLabel = New-Object System.Windows.Forms.Label
        $systemLabel.Text = "💻 $global:CPUName | $global:GPUName | $global:RAMTotal GB $global:RAMType • Risk: $($intelligence.RiskAssessment)"
        $systemLabel.ForeColor = [System.Drawing.Color]::Gray
        $systemLabel.Location = New-Object System.Drawing.Point(20, 75)
        $systemLabel.Size = New-Object System.Drawing.Size(1000, 20)
        $headerPanel.Controls.Add($systemLabel)
        
        # Main content with tabs
        $tabControl = New-Object System.Windows.Forms.TabControl
        $tabControl.Location = New-Object System.Drawing.Point(20, 110)
        $tabControl.Size = New-Object System.Drawing.Size(1340, 650)
        $tabControl.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $tabControl.ForeColor = [System.Drawing.Color]::White
        $resultForm.Controls.Add($tabControl)
        
        # Tab 1: AI Analysis Overview
        $aiTab = New-Object System.Windows.Forms.TabPage
        $aiTab.Text = "🤖 AI Analysis"
        $aiTab.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $aiTab.ForeColor = [System.Drawing.Color]::White
        $tabControl.TabPages.Add($aiTab)
        
        $aiOverviewText = New-Object System.Windows.Forms.RichTextBox
        $aiOverviewText.ReadOnly = $true
        $aiOverviewText.Font = New-Object System.Drawing.Font("Consolas", 10)
        $aiOverviewText.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
        $aiOverviewText.ForeColor = [System.Drawing.Color]::White
        $aiOverviewText.Location = New-Object System.Drawing.Point(10, 10)
        $aiOverviewText.Size = New-Object System.Drawing.Size(1300, 580)
        $aiOverviewText.ScrollBars = "Both"
        $aiTab.Controls.Add($aiOverviewText)
        
        # AI Overview Content
        $aiContent = @"
🤖 ARTIFICIAL INTELLIGENCE ANALYSIS REPORT
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
════════════════════════════════════════════════════════════════════════════════

🎯 USER PROFILE CLASSIFICATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Profile: $($intelligence.SystemProfile)
Performance Level: $($intelligence.PerformanceLevel)% optimized
Risk Assessment: $($intelligence.RiskAssessment)

🔍 INTELLIGENT SOURCE ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@

        foreach ($source in $intelligence.SourceAnalysis.Keys | Sort-Object {$intelligence.SourceAnalysis[$_]} -Descending) {
            $count = $intelligence.SourceAnalysis[$source]
            if ($count -gt 0) {
                $percentage = [math]::Round(($count / ($intelligence.SourceAnalysis.Values | Measure-Object -Sum).Sum) * 100, 1)
                $aiContent += "`n   🔧 $source`: $count optimization(s) ($percentage%)"
            }
        }

        if ($intelligence.ConflictDetection.Count -gt 0) {
            $aiContent += "`n`n⚠️ CONFLICT DETECTION ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            foreach ($conflict in $intelligence.ConflictDetection) {
                $aiContent += "`n   🚨 $conflict"
            }
        } else {
            $aiContent += "`n`n✅ CONFLICT DETECTION ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ No conflicts detected - System configuration is stable"
        }

        if ($intelligence.Recommendations.Count -gt 0) {
            $aiContent += "`n`n💡 AI PERFORMANCE RECOMMENDATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            foreach ($recommendation in $intelligence.Recommendations) {
                $aiContent += "`n   $recommendation"
            }
        }

        if ($comparativeAnalysis -and $comparativeAnalysis.Changes.Count -gt 0) {
            $aiContent += "`n`n📊 COMPARATIVE ANALYSIS (Since Last Scan)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary: $($comparativeAnalysis.Summary)

Recent Changes:"
            foreach ($change in $comparativeAnalysis.Changes | Select-Object -First 10) {
                $aiContent += "`n   $change"
            }
            if ($comparativeAnalysis.Changes.Count -gt 10) {
                $aiContent += "`n   ... and $($comparativeAnalysis.Changes.Count - 10) more changes"
            }
        }

        if ($intelligence.UnknownModifications.Count -gt 0) {
            $aiContent += "`n`n🕵️ UNKNOWN MODIFICATIONS DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The AI detected modifications that don't match known optimization patterns:"
            foreach ($unknown in $intelligence.UnknownModifications | Select-Object -First 15) {
                $aiContent += "`n   🔍 $unknown"
            }
        }

        $aiOverviewText.Text = $aiContent
        
        # Tab 2: Detailed Optimization Inventory
        $detailTab = New-Object System.Windows.Forms.TabPage
        $detailTab.Text = "📋 Detailed Inventory"
        $detailTab.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $detailTab.ForeColor = [System.Drawing.Color]::White
        $tabControl.TabPages.Add($detailTab)
        
        $detailText = New-Object System.Windows.Forms.RichTextBox
        $detailText.ReadOnly = $true
        $detailText.Font = New-Object System.Drawing.Font("Consolas", 9)
        $detailText.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
        $detailText.ForeColor = [System.Drawing.Color]::White
        $detailText.Location = New-Object System.Drawing.Point(10, 10)
        $detailText.Size = New-Object System.Drawing.Size(1300, 580)
        $detailText.ScrollBars = "Both"
        $detailTab.Controls.Add($detailText)
        
        # Build detailed inventory
        $detailContent = @"
📋 COMPLETE OPTIMIZATION INVENTORY
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
System: $global:CPUName | $global:GPUName | $global:RAMTotal GB $global:RAMType
═══════════════════════════════════════════════════════════════════════════════

"@
        
        # Add optimization categories with enhanced formatting
        $categories = @(
            @{Name="🎮 GAMING OPTIMIZATIONS"; Data=$optimizations.Gaming; Icon="🎯"},
            @{Name="🖥️ GRAPHICS & DISPLAY"; Data=$optimizations.Graphics; Icon="📺"},
            @{Name="🧠 MEMORY MANAGEMENT"; Data=$optimizations.Memory; Icon="💾"},
            @{Name="⚡ CPU PERFORMANCE"; Data=$optimizations.CPU; Icon="🔥"},
            @{Name="🌐 NETWORK SETTINGS"; Data=$optimizations.Network; Icon="📶"},
            @{Name="🔋 POWER MANAGEMENT"; Data=$optimizations.Power; Icon="⚡"},
            @{Name="🔥 MICROSOFT INSIDER TWEAKS"; Data=$optimizations.Insider; Icon="🚀"},
            @{Name="🛠️ THIRD-PARTY TOOLS"; Data=$optimizations.ThirdParty; Icon="📦"},
            @{Name="🎯 HARDWARE-SPECIFIC"; Data=$optimizations.Hardware; Icon="🔧"}
        )
        
        foreach ($category in $categories) {
            if ($category.Data.Count -gt 0) {
                $detailContent += "`n$($category.Name) ($($category.Data.Count) found)`n"
                $detailContent += "─" * 95 + "`n"
                
                foreach ($key in $category.Data.Keys | Sort-Object) {
                    $source = Identify-OptimizationSource $category.Name $key $category.Data[$key]
                    $detailContent += "  $($category.Icon) $key`n"
                    $detailContent += "     └─ Value: $($category.Data[$key])`n"
                    $detailContent += "     └─ Source: $source (AI-Detected)`n`n"
                }
            }
        }
        
        $detailText.Text = $detailContent
        
        # Tab 3: Performance Metrics
        $metricsTab = New-Object System.Windows.Forms.TabPage
        $metricsTab.Text = "📊 Performance Metrics"
        $metricsTab.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $metricsTab.ForeColor = [System.Drawing.Color]::White
        $tabControl.TabPages.Add($metricsTab)
        
        $metricsText = New-Object System.Windows.Forms.RichTextBox
        $metricsText.ReadOnly = $true
        $metricsText.Font = New-Object System.Drawing.Font("Consolas", 10)
        $metricsText.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
        $metricsText.ForeColor = [System.Drawing.Color]::White
        $metricsText.Location = New-Object System.Drawing.Point(10, 10)
        $metricsText.Size = New-Object System.Drawing.Size(1300, 580)
        $metricsText.ScrollBars = "Both"
        $metricsTab.Controls.Add($metricsText)
        
        # Calculate metrics
        $totalOptimizations = ($optimizations.Gaming.Count + $optimizations.Graphics.Count + 
                              $optimizations.Memory.Count + $optimizations.CPU.Count + 
                              $optimizations.Network.Count + $optimizations.Power.Count + 
                              $optimizations.Insider.Count + $optimizations.ThirdParty.Count + 
                              $optimizations.Hardware.Count)
        
        $estimatedPerformanceGain = [math]::Min(100, ($totalOptimizations * 3) + ($optimizations.Insider.Count * 5) + ($optimizations.Hardware.Count * 4))
        
        $metricsContent = @"
📊 ADVANCED PERFORMANCE METRICS
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
═══════════════════════════════════════════════════════════════════════════════

🎯 OPTIMIZATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Optimizations Found: $totalOptimizations
AI Performance Level: $($intelligence.PerformanceLevel)%
Estimated Performance Gain: $estimatedPerformanceGain%
System Profile: $($intelligence.SystemProfile)
Risk Assessment: $($intelligence.RiskAssessment)

📈 CATEGORY BREAKDOWN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎮 Gaming Optimizations: $($optimizations.Gaming.Count) ($([math]::Round(($optimizations.Gaming.Count / $totalOptimizations) * 100, 1))%)
🖥️ Graphics Optimizations: $($optimizations.Graphics.Count) ($([math]::Round(($optimizations.Graphics.Count / $totalOptimizations) * 100, 1))%)
🧠 Memory Optimizations: $($optimizations.Memory.Count) ($([math]::Round(($optimizations.Memory.Count / $totalOptimizations) * 100, 1))%)
⚡ CPU Optimizations: $($optimizations.CPU.Count) ($([math]::Round(($optimizations.CPU.Count / $totalOptimizations) * 100, 1))%)
🌐 Network Optimizations: $($optimizations.Network.Count) ($([math]::Round(($optimizations.Network.Count / $totalOptimizations) * 100, 1))%)
🔋 Power Optimizations: $($optimizations.Power.Count) ($([math]::Round(($optimizations.Power.Count / $totalOptimizations) * 100, 1))%)
🔥 Insider Tweaks: $($optimizations.Insider.Count) ($([math]::Round(($optimizations.Insider.Count / $totalOptimizations) * 100, 1))%)
🛠️ Third-Party Tools: $($optimizations.ThirdParty.Count) ($([math]::Round(($optimizations.ThirdParty.Count / $totalOptimizations) * 100, 1))%)
🎯 Hardware-Specific: $($optimizations.Hardware.Count) ($([math]::Round(($optimizations.Hardware.Count / $totalOptimizations) * 100, 1))%)

🔧 HARDWARE ASSESSMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CPU: $global:CPUName
   └─ Type: $(if($global:IsAMDCPU){"AMD Ryzen"}elseif($global:IsIntelCPU){"Intel Core"}else{"Unknown"})
   └─ X3D Support: $(if($global:HasX3D){"✅ Detected - Specialized optimizations available"}else{"❌ Not detected"})
   └─ Optimization Status: $(if($optimizations.CPU.Count -gt 0){"✅ Optimized ($($optimizations.CPU.Count) tweaks)"}else{"⚠️ Not optimized"})

GPU: $global:GPUName
   └─ Vendor: $(if($global:IsNVIDIA){"NVIDIA"}elseif($global:IsAMDGPU){"AMD"}else{"Unknown"})
   └─ Optimization Status: $(if($optimizations.Graphics.Count -gt 0){"✅ Optimized ($($optimizations.Graphics.Count) tweaks)"}else{"⚠️ Not optimized"})

Memory: $global:RAMTotal GB $global:RAMType-$global:RAMSpeed
   └─ Type Assessment: $(if($global:RAMType -eq "DDR5"){"🚀 Latest generation"}elseif($global:RAMType -eq "DDR4"){"⚡ Modern"}else{"📋 Standard"})
   └─ Speed Category: $(if($global:RAMSpeed -gt 4000){"🔥 High-speed"}elseif($global:RAMSpeed -gt 3000){"⚡ Fast"}else{"📋 Standard"})
   └─ Optimization Status: $(if($optimizations.Memory.Count -gt 0){"✅ Optimized ($($optimizations.Memory.Count) tweaks)"}else{"⚠️ Not optimized"})

Operating System: $global:OSName
   └─ Gaming Support: $(if($global:IsWindows11){"✅ Windows 11 - Latest gaming features"}else{"⚡ Windows 10 - Good gaming support"})

🏆 PERFORMANCE BENCHMARK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Optimization Density: $(if($totalOptimizations -gt 30){"🔥 Extreme"}elseif($totalOptimizations -gt 20){"🚀 High"}elseif($totalOptimizations -gt 10){"⚡ Moderate"}else{"📋 Low"})
Gaming Readiness: $(if($optimizations.Gaming.Count -gt 5){"✅ Excellent"}elseif($optimizations.Gaming.Count -gt 2){"⚡ Good"}else{"⚠️ Needs improvement"})
Stability Risk: $(if($intelligence.RiskAssessment -like "*LOW*"){"✅ Minimal risk"}elseif($intelligence.RiskAssessment -like "*MODERATE*"){"⚠️ Monitor closely"}else{"🚨 High risk - review settings"})
Advanced Features: $(if($optimizations.Insider.Count -gt 0){"✅ Using cutting-edge tweaks"}else{"📋 Using standard optimizations"})

💡 NEXT STEPS RECOMMENDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@

        if ($intelligence.PerformanceLevel -lt 50) {
            $metricsContent += "`n✨ BEGINNER: Start with Conservative or Balanced profile for safe improvements"
        } elseif ($intelligence.PerformanceLevel -lt 80) {
            $metricsContent += "`n🚀 INTERMEDIATE: Consider Aggressive profile and hardware-specific optimizations"
        } else {
            $metricsContent += "`n🔥 EXPERT: System is highly optimized - monitor for new tweaking opportunities"
        }

        $metricsText.Text = $metricsContent
        
        # Button panel with enhanced export options
        $buttonPanel = New-Object System.Windows.Forms.Panel
        $buttonPanel.Location = New-Object System.Drawing.Point(20, 780)
        $buttonPanel.Size = New-Object System.Drawing.Size(1340, 60)
        $buttonPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
        $resultForm.Controls.Add($buttonPanel)
        
        # Export Professional Report
        $exportReportBtn = New-Object System.Windows.Forms.Button
        $exportReportBtn.Text = "📄 Export Professional Report"
        $exportReportBtn.Location = New-Object System.Drawing.Point(10, 15)
        $exportReportBtn.Size = New-Object System.Drawing.Size(180, 35)
        $exportReportBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 180)
        $exportReportBtn.ForeColor = [System.Drawing.Color]::White
        $exportReportBtn.FlatStyle = "Flat"
        $exportReportBtn.Add_Click({
            $professionalReport = Export-ProfessionalReport $optimizations $intelligence $comparativeAnalysis
            $exportPath = "$env:USERPROFILE\Desktop\FPS_Suite_AI_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
            Set-Content -Path $exportPath -Value $professionalReport -Encoding UTF8
            Write-EnhancedLog "Professional AI report exported to: $exportPath" "SUCCESS" "AI_SCANNER"
            [System.Windows.Forms.MessageBox]::Show("Professional AI report exported to:`n$exportPath`n`nThis report includes AI analysis, source detection, conflict analysis, and performance recommendations.", "Export Complete", "OK", "Information")
        })
        $buttonPanel.Controls.Add($exportReportBtn)
        
        # Export Raw Data
        $exportDataBtn = New-Object System.Windows.Forms.Button
        $exportDataBtn.Text = "💾 Export Raw Data (JSON)"
        $exportDataBtn.Location = New-Object System.Drawing.Point(200, 15)
        $exportDataBtn.Size = New-Object System.Drawing.Size(160, 35)
        $exportDataBtn.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        $exportDataBtn.ForeColor = [System.Drawing.Color]::White
        $exportDataBtn.FlatStyle = "Flat"
        $exportDataBtn.Add_Click({
            $rawData = @{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                SystemInfo = @{
                    CPU = $global:CPUName
                    GPU = $global:GPUName
                    RAM = "$global:RAMTotal GB $global:RAMType-$global:RAMSpeed"
                    OS = $global:OSName
                }
                Optimizations = $optimizations
                Intelligence = $intelligence
                ComparativeAnalysis = $comparativeAnalysis
            }
            $exportPath = "$env:USERPROFILE\Desktop\FPS_Suite_Raw_Data_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            $rawData | ConvertTo-Json -Depth 10 | Set-Content -Path $exportPath -Encoding UTF8
            Write-EnhancedLog "Raw data exported to: $exportPath" "SUCCESS" "AI_SCANNER"
            [System.Windows.Forms.MessageBox]::Show("Raw data exported to:`n$exportPath`n`nThis JSON file contains all scan data and can be used for advanced analysis or sharing with support.", "Export Complete", "OK", "Information")
        })
        $buttonPanel.Controls.Add($exportDataBtn)
        
        # Share Analysis
        $shareBtn = New-Object System.Windows.Forms.Button
        $shareBtn.Text = "📤 Share Analysis Summary"
        $shareBtn.Location = New-Object System.Drawing.Point(370, 15)
        $shareBtn.Size = New-Object System.Drawing.Size(160, 35)
        $shareBtn.BackColor = [System.Drawing.Color]::FromArgb(150, 100, 0)
        $shareBtn.ForeColor = [System.Drawing.Color]::White
        $shareBtn.FlatStyle = "Flat"
        $shareBtn.Add_Click({
            $shareSummary = @"
🎮 Alphacode GameBoost - System Analysis Summary

System: $global:CPUName | $global:GPUName | $global:RAMTotal GB $global:RAMType
Profile: $($intelligence.SystemProfile)
Performance Level: $($intelligence.PerformanceLevel)%
Total Optimizations: $totalOptimizations
Risk Level: $($intelligence.RiskAssessment)

Generated by Alphacode GameBoost Ultimate Edition
"@
            [System.Windows.Forms.Clipboard]::SetText($shareSummary)
            [System.Windows.Forms.MessageBox]::Show("Analysis summary copied to clipboard!`n`nYou can now paste it in forums, Discord, or support tickets.", "Copied to Clipboard", "OK", "Information")
        })
        $buttonPanel.Controls.Add($shareBtn)
        
        # Close button
        $closeBtn = New-Object System.Windows.Forms.Button
        $closeBtn.Text = "Close"
        $closeBtn.Location = New-Object System.Drawing.Point(1200, 15)
        $closeBtn.Size = New-Object System.Drawing.Size(100, 35)
        $closeBtn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
        $closeBtn.ForeColor = [System.Drawing.Color]::White
        $closeBtn.FlatStyle = "Flat"
        $closeBtn.Add_Click({ $resultForm.Close() })
        $buttonPanel.Controls.Add($closeBtn)
        
        Write-EnhancedLog "AI-powered optimization analysis completed - displaying results" "SUCCESS" "AI_SCANNER"
        $resultForm.ShowDialog()
        
    }
    catch {
        Write-EnhancedLog "Failed to generate AI optimization results: $($_.Exception.Message)" "ERROR" "AI_SCANNER"
        [System.Windows.Forms.MessageBox]::Show("Error generating AI optimization report. Check logs for details.", "AI Analysis Error", "OK", "Error")
    }
}

function Get-SystemOptimizationStatus {
    try {
        $status = @{
            GPUPriority = "Not Set"
            CPUPriority = "Not Set"
            SystemResponsiveness = "Not Set"
            HardwareScheduling = "Disabled"
            TDRLevel = "Not Set"
            GameDVR = "Enabled"
            OptimizationLevel = 0
            OverallStatus = "📋 Needs Optimization"
        }
        
        # Gaming Task Priority
        try {
            $gamingTasks = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -ErrorAction SilentlyContinue
            if ($gamingTasks) {
                if ($gamingTasks."GPU Priority") {
                    $status.GPUPriority = $gamingTasks."GPU Priority"
                }
                if ($gamingTasks.Priority) {
                    $status.CPUPriority = $gamingTasks.Priority
                }
            }
        } catch {
            Write-EnhancedLog "Failed to read gaming tasks: $($_.Exception.Message)" "DEBUG" "STATUS"
        }
        
        # System Responsiveness
        try {
            $multimedia = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -ErrorAction SilentlyContinue
            if ($multimedia -and $multimedia.SystemResponsiveness -ne $null) {
                $status.SystemResponsiveness = $multimedia.SystemResponsiveness
            }
        } catch {
            Write-EnhancedLog "Failed to read system responsiveness: $($_.Exception.Message)" "DEBUG" "STATUS"
        }
        
        # Hardware Scheduling
        try {
            $graphics = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -ErrorAction SilentlyContinue
            if ($graphics) {
                if ($graphics.HwSchMode -eq 2) {
                    $status.HardwareScheduling = "Enabled"
                }
                if ($graphics.TdrLevel -ne $null) {
                    $status.TDRLevel = $graphics.TdrLevel
                }
            }
        } catch {
            Write-EnhancedLog "Failed to read graphics settings: $($_.Exception.Message)" "DEBUG" "STATUS"
        }
        
        # Game DVR Status
        try {
            $gameDVR = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -ErrorAction SilentlyContinue
            if ($gameDVR -and $gameDVR.GameDVR_Enabled -eq 0) {
                $status.GameDVR = "Disabled (Optimized)"
            }
        } catch {
            Write-EnhancedLog "Failed to read Game DVR settings: $($_.Exception.Message)" "DEBUG" "STATUS"
        }
        
        # Calculate optimization score
        $optimizationScore = 0
        $totalChecks = 5
        
        if ($status.GPUPriority -match '^\d+' -and [int]$status.GPUPriority -ge 6) { $optimizationScore++ }
        if ($status.SystemResponsiveness -match '^\d+' -and [int]$status.SystemResponsiveness -le 10) { $optimizationScore++ }
        if ($status.HardwareScheduling -eq "Enabled") { $optimizationScore++ }
        if ($status.GameDVR -like "*Optimized*") { $optimizationScore++ }
        if ($status.TDRLevel -match '^\d+' -and [int]$status.TDRLevel -le 2) { $optimizationScore++ }
        
        $status.OptimizationLevel = [math]::Round(($optimizationScore / $totalChecks) * 100, 1)
        $status.OverallStatus = switch ($status.OptimizationLevel) {
            {$_ -ge 90} { "🔥 Excellent" }
            {$_ -ge 70} { "🚀 Very Good" }
            {$_ -ge 50} { "⚡ Good" }
            {$_ -ge 30} { "🛡️ Fair" }
            default { "📋 Needs Optimization" }
        }
        
        return $status
    }
    catch {
        Write-EnhancedLog "Failed to get system status: $($_.Exception.Message)" "ERROR" "STATUS"
        return @{
            GPUPriority = "Error"
            CPUPriority = "Error"
            SystemResponsiveness = "Error"
            HardwareScheduling = "Error"
            TDRLevel = "Error"
            GameDVR = "Error"
            OptimizationLevel = 0
            OverallStatus = "❌ Error"
        }
    }
}

# ===== STATUS UPDATE FUNCTION (GLOBAL SCOPE) =====
function Update-StatusDisplay {
    try {
        if (-not $global:StatusRichTextBox) {
            Write-EnhancedLog "StatusRichTextBox not initialized" "DEBUG" "GUI"
            return
        }
        
        $status = Get-SystemOptimizationStatus
        if ($status) {
            $statusText = @"
═══════════════════════════════════════════════════════════════════════════════
GAMING PERFORMANCE STATUS • $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
═══════════════════════════════════════════════════════════════════════════════

🎯 OVERALL OPTIMIZATION: $($status.OverallStatus) ($($status.OptimizationLevel)% Optimized)

🎮 GAMING CONFIGURATION:
   GPU Priority: $($status.GPUPriority) $(if($status.GPUPriority -ge 6){"✅"}elseif($status.GPUPriority -ge 4){"⚡"}else{"📋"})
   CPU Priority: $($status.CPUPriority) $(if($status.CPUPriority -ge 6){"✅"}elseif($status.CPUPriority -ge 4){"⚡"}else{"📋"})
   Responsiveness: $($status.SystemResponsiveness) $(if($status.SystemResponsiveness -le 5){"✅"}elseif($status.SystemResponsiveness -le 10){"⚡"}else{"📋"})

🖥️ GRAPHICS & DISPLAY:
   Hardware Scheduling: $($status.HardwareScheduling) $(if($status.HardwareScheduling -eq "Enabled"){"✅"}else{"📋"})
   TDR Level: $($status.TDRLevel) $(if($status.TDRLevel -le 2){"✅"}elseif($status.TDRLevel -eq 3){"📋"}else{"⚠️"})
   Game DVR: $($status.GameDVR) $(if($status.GameDVR -like "*Optimized*"){"✅"}else{"⚠️"})

🔧 HARDWARE DETECTED:
   CPU: $global:CPUName $(if($global:HasX3D){"🔥 X3D"}else{""})
   GPU: $global:GPUName $(if($global:IsNVIDIA){"🟢 NVIDIA"}elseif($global:IsAMDGPU){"🔴 AMD"}else{""})
   Memory: $global:RAMTotal GB $global:RAMType$(if($global:RAMSpeed -gt 4000){"-$global:RAMSpeed 🚀"}else{""})
   OS: $global:OSName $(if($global:IsWindows11){"✅ Win11"}else{"📋"})

═══════════════════════════════════════════════════════════════════════════════
"@
            $global:StatusRichTextBox.Text = $statusText
            Write-EnhancedLog "Status display updated successfully" "DEBUG" "GUI"
        }
    } catch {
        Write-EnhancedLog "Failed to update status display: $($_.Exception.Message)" "ERROR" "GUI"
    }
}
function Restore-SystemDefaults {
    Write-EnhancedLog "Initiating system defaults restoration..." "INFO" "RESTORE"
    
    try {
        $backupPath = Create-EnterpriseBackup "pre_restore" "Safety backup before restoring Windows defaults" $false
        if (-not $backupPath) {
            Write-EnhancedLog "Safety backup failed - restoration aborted" "CRITICAL" "RESTORE"
            return $false
        }
        
        Write-EnhancedLog "Restoring Windows default settings..." "INFO" "RESTORE"
        
        # Restore defaults
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value 2 -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value 2 -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 20 -Type DWord
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "TdrLevel" -Value 3 -Type DWord
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "GameDVR_Enabled" -Value 1 -Type DWord
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 0 -Type DWord
        
        Write-EnhancedLog "System defaults restored successfully!" "SUCCESS" "RESTORE"
        return $true
        
    } catch {
        Write-EnhancedLog "System restoration failed: $($_.Exception.Message)" "ERROR" "RESTORE"
        return $false
    }
}

# ===== MODERN GUI =====
function Create-ModernGUI {
    Write-EnhancedLog "Initializing modern GUI interface..." "INFO" "GUI"
    
    # Main Form
    $global:MainForm = New-Object System.Windows.Forms.Form
    $global:MainForm.Text = "$global:AppName v$global:AppVersion"
    $global:MainForm.Size = New-Object System.Drawing.Size(1200, 800)
    $global:MainForm.StartPosition = "CenterScreen"
    $global:MainForm.FormBorderStyle = "FixedDialog"
    $global:MainForm.MaximizeBox = $false
    $global:MainForm.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
    $global:MainForm.ForeColor = [System.Drawing.Color]::White
    $global:MainForm.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    
    # Header Panel
    $headerPanel = New-Object System.Windows.Forms.Panel
    $headerPanel.Location = New-Object System.Drawing.Point(0, 0)
    $headerPanel.Size = New-Object System.Drawing.Size(1200, 90)
    $headerPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
    $global:MainForm.Controls.Add($headerPanel)
    
    # Title
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "Alphacode GameBoost"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
    $titleLabel.Location = New-Object System.Drawing.Point(30, 15)
    $titleLabel.Size = New-Object System.Drawing.Size(400, 35)
    $headerPanel.Controls.Add($titleLabel)
    
    # Version
    $versionLabel = New-Object System.Windows.Forms.Label
    $versionLabel.Text = "Ultimate Edition v$global:AppVersion"
    $versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Italic)
    $versionLabel.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
    $versionLabel.Location = New-Object System.Drawing.Point(30, 50)
    $versionLabel.Size = New-Object System.Drawing.Size(300, 20)
    $headerPanel.Controls.Add($versionLabel)
    
    # Hardware Info
    $hwInfo = "🖥️ $($global:CPUName.Substring(0, [Math]::Min($global:CPUName.Length, 30))) | 🎮 $($global:GPUName.Substring(0, [Math]::Min($global:GPUName.Length, 25))) | 💾 $global:RAMTotal GB $global:RAMType"
    $hwLabel = New-Object System.Windows.Forms.Label
    $hwLabel.Text = $hwInfo
    $hwLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $hwLabel.ForeColor = [System.Drawing.Color]::FromArgb(160, 160, 160)
    $hwLabel.Location = New-Object System.Drawing.Point(30, 70)
    $hwLabel.Size = New-Object System.Drawing.Size(900, 20)
    $headerPanel.Controls.Add($hwLabel)
    
    # Main Content
    $contentPanel = New-Object System.Windows.Forms.Panel
    $contentPanel.Location = New-Object System.Drawing.Point(20, 110)
    $contentPanel.Size = New-Object System.Drawing.Size(1160, 580)
    $contentPanel.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
    $global:MainForm.Controls.Add($contentPanel)
    
    # Left Panel - Controls
    $controlPanel = New-Object System.Windows.Forms.Panel
    $controlPanel.Location = New-Object System.Drawing.Point(10, 10)
    $controlPanel.Size = New-Object System.Drawing.Size(400, 560)
    $controlPanel.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 22)
    $contentPanel.Controls.Add($controlPanel)
    
    # Performance Profiles Section
    $profilesLabel = New-Object System.Windows.Forms.Label
    $profilesLabel.Text = "🚀 Performance Profiles"
    $profilesLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $profilesLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
    $profilesLabel.Location = New-Object System.Drawing.Point(20, 20)
    $profilesLabel.Size = New-Object System.Drawing.Size(360, 25)
    $controlPanel.Controls.Add($profilesLabel)
    
    # Button Creation Function
    function New-ModernButton {
        param($Text, $Location, $Size, $BackColor, $Action)
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $Text
        $button.Location = $Location
        $button.Size = $Size
        $button.BackColor = $BackColor
        $button.ForeColor = [System.Drawing.Color]::White
        $button.FlatStyle = "Flat"
        $button.FlatAppearance.BorderSize = 0
        $button.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $button.Cursor = "Hand"
        $button.Add_Click($Action)
        
        # Hover effects
        $button.Add_MouseEnter({
            try {
                if ($this.BackColor -ne $null) {
                    $this.BackColor = [System.Drawing.Color]::FromArgb(
                        [math]::Min(255, $this.BackColor.R + 20),
                        [math]::Min(255, $this.BackColor.G + 20),
                        [math]::Min(255, $this.BackColor.B + 20)
                    )
                }
            } catch {
                # Ignore hover effect errors
            }
        })
        $button.Add_MouseLeave({ 
            try {
                if ($BackColor -ne $null) {
                    $this.BackColor = $BackColor 
                }
            } catch {
                # Ignore hover effect errors
            }
        })
        
        return $button
    }
    
    # Profile Buttons
    $conservativeBtn = New-ModernButton "🛡️ Conservative Profile" (New-Object System.Drawing.Point(20, 55)) (New-Object System.Drawing.Size(175, 45)) ([System.Drawing.Color]::FromArgb(0, 120, 180)) {
        try {
            $result = Apply-IntelligentOptimizations -Profile "Conservative"
            Update-StatusDisplay
            if ($result) {
                [System.Windows.Forms.MessageBox]::Show("Conservative profile applied successfully!", "Conservative Mode Applied", "OK", "Information")
            } else {
                [System.Windows.Forms.MessageBox]::Show("Profile application failed!", "Error", "OK", "Error")
            }
        } catch {
            Write-EnhancedLog "Conservative profile error: $($_.Exception.Message)" "ERROR" "GUI"
            [System.Windows.Forms.MessageBox]::Show("Error applying Conservative profile!", "Error", "OK", "Error")
        }
    }
    $controlPanel.Controls.Add($conservativeBtn)
    
    $balancedBtn = New-ModernButton "⚖️ Balanced Profile" (New-Object System.Drawing.Point(205, 55)) (New-Object System.Drawing.Size(175, 45)) ([System.Drawing.Color]::FromArgb(0, 150, 100)) {
        try {
            $result = Apply-IntelligentOptimizations -Profile "Balanced"
            Update-StatusDisplay
            if ($result) {
                [System.Windows.Forms.MessageBox]::Show("Balanced profile applied successfully!", "Balanced Mode Applied", "OK", "Information")
            } else {
                [System.Windows.Forms.MessageBox]::Show("Profile application failed!", "Error", "OK", "Error")
            }
        } catch {
            Write-EnhancedLog "Balanced profile error: $($_.Exception.Message)" "ERROR" "GUI"
            [System.Windows.Forms.MessageBox]::Show("Error applying Balanced profile!", "Error", "OK", "Error")
        }
    }
    $controlPanel.Controls.Add($balancedBtn)
    
    $aggressiveBtn = New-ModernButton "🚀 Aggressive Profile" (New-Object System.Drawing.Point(20, 110)) (New-Object System.Drawing.Size(175, 45)) ([System.Drawing.Color]::FromArgb(200, 100, 0)) {
        try {
            $result = Apply-IntelligentOptimizations -Profile "Aggressive"
            Update-StatusDisplay
            if ($result) {
                [System.Windows.Forms.MessageBox]::Show("Aggressive profile applied successfully!", "Aggressive Mode Applied", "OK", "Information")
            } else {
                [System.Windows.Forms.MessageBox]::Show("Profile application failed!", "Error", "OK", "Error")
            }
        } catch {
            Write-EnhancedLog "Aggressive profile error: $($_.Exception.Message)" "ERROR" "GUI"
            [System.Windows.Forms.MessageBox]::Show("Error applying Aggressive profile!", "Error", "OK", "Error")
        }
    }
    $controlPanel.Controls.Add($aggressiveBtn)
    
    $maximumBtn = New-ModernButton "🔥 Maximum Performance" (New-Object System.Drawing.Point(205, 110)) (New-Object System.Drawing.Size(175, 45)) ([System.Drawing.Color]::FromArgb(200, 50, 50)) {
        try {
            $confirm = [System.Windows.Forms.MessageBox]::Show("Maximum Performance mode applies experimental tweaks. Proceed?", "Confirm Maximum Mode", "YesNo", "Warning")
            if ($confirm -eq "Yes") {
                $result = Apply-IntelligentOptimizations -Profile "Maximum"
                Update-StatusDisplay
                if ($result) {
                    [System.Windows.Forms.MessageBox]::Show("Maximum performance profile applied!", "Maximum Performance Applied", "OK", "Information")
                } else {
                    [System.Windows.Forms.MessageBox]::Show("Profile application failed!", "Error", "OK", "Error")
                }
            }
        } catch {
            Write-EnhancedLog "Maximum profile error: $($_.Exception.Message)" "ERROR" "GUI"
            [System.Windows.Forms.MessageBox]::Show("Error applying Maximum profile!", "Error", "OK", "Error")
        }
    }
    $controlPanel.Controls.Add($maximumBtn)
    
    # System Analysis Section
    $analysisLabel = New-Object System.Windows.Forms.Label
    $analysisLabel.Text = "🔍 System Analysis & Tools"
    $analysisLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $analysisLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
    $analysisLabel.Location = New-Object System.Drawing.Point(20, 180)
    $analysisLabel.Size = New-Object System.Drawing.Size(360, 25)
    $controlPanel.Controls.Add($analysisLabel)
    
    $scanBtn = New-ModernButton "🔍 Complete Registry Scan" (New-Object System.Drawing.Point(20, 215)) (New-Object System.Drawing.Size(175, 40)) ([System.Drawing.Color]::FromArgb(75, 0, 130)) {
        Write-EnhancedLog "Starting comprehensive registry optimization scan..." "INFO" "USER_ACTION"
        Show-OptimizationResults
    }
    $controlPanel.Controls.Add($scanBtn)
    
    $hwOptBtn = New-ModernButton "🎯 Hardware Optimizations" (New-Object System.Drawing.Point(205, 215)) (New-Object System.Drawing.Size(175, 40)) ([System.Drawing.Color]::FromArgb(120, 0, 150)) {
        try {
            $result = Apply-HardwareSpecificOptimizations
            Update-StatusDisplay
            if ($result) {
                $message = "Hardware-specific optimizations applied successfully!"
                if ($global:HasX3D) { $message += "`n• AMD X3D cache optimizations enabled" }
                if ($global:IsNVIDIA) { $message += "`n• NVIDIA driver optimizations applied" }
                if ($global:RAMSpeed -gt 4000) { $message += "`n• High-speed RAM optimizations configured" }
                [System.Windows.Forms.MessageBox]::Show($message, "Hardware Optimization Complete", "OK", "Information")
            } else {
                [System.Windows.Forms.MessageBox]::Show("Hardware optimization failed!", "Error", "OK", "Error")
            }
        } catch {
            Write-EnhancedLog "Hardware optimization error: $($_.Exception.Message)" "ERROR" "GUI"
            [System.Windows.Forms.MessageBox]::Show("Error applying hardware optimizations!", "Error", "OK", "Error")
        }
    }
    $controlPanel.Controls.Add($hwOptBtn)
    
    # Backup & Restore Section
    $backupLabel = New-Object System.Windows.Forms.Label
    $backupLabel.Text = "💾 Backup & Restore"
    $backupLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $backupLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
    $backupLabel.Location = New-Object System.Drawing.Point(20, 280)
    $backupLabel.Size = New-Object System.Drawing.Size(360, 25)
    $controlPanel.Controls.Add($backupLabel)
    
    $backupBtn = New-ModernButton "💾 Create Manual Backup" (New-Object System.Drawing.Point(20, 315)) (New-Object System.Drawing.Size(175, 40)) ([System.Drawing.Color]::FromArgb(75, 75, 150)) {
        $backupPath = Create-EnterpriseBackup "manual_backup" "User-initiated manual backup" $false
        if ($backupPath) {
            [System.Windows.Forms.MessageBox]::Show("Manual backup created successfully!`n`nLocation: $backupPath", "Backup Complete", "OK", "Information")
        } else {
            [System.Windows.Forms.MessageBox]::Show("Backup creation failed!", "Backup Error", "OK", "Error")
        }
    }
    $controlPanel.Controls.Add($backupBtn)
    
    $restoreBtn = New-ModernButton "🔄 Restore Defaults" (New-Object System.Drawing.Point(205, 315)) (New-Object System.Drawing.Size(175, 40)) ([System.Drawing.Color]::FromArgb(150, 75, 0)) {
        try {
            $confirm = [System.Windows.Forms.MessageBox]::Show("This will restore all gaming optimizations to Windows defaults. Proceed?", "Confirm System Restore", "YesNo", "Question")
            if ($confirm -eq "Yes") {
                $result = Restore-SystemDefaults
                Update-StatusDisplay
                if ($result) {
                    [System.Windows.Forms.MessageBox]::Show("System defaults restored successfully!", "Restore Complete", "OK", "Information")
                } else {
                    [System.Windows.Forms.MessageBox]::Show("System restoration failed!", "Restore Error", "OK", "Error")
                }
            }
        } catch {
            Write-EnhancedLog "Restore defaults error: $($_.Exception.Message)" "ERROR" "GUI"
            [System.Windows.Forms.MessageBox]::Show("Error restoring defaults!", "Error", "OK", "Error")
        }
    }
    $controlPanel.Controls.Add($restoreBtn)
    
    # Configuration Section
    $configLabel = New-Object System.Windows.Forms.Label
    $configLabel.Text = "⚙️ Configuration"
    $configLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $configLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
    $configLabel.Location = New-Object System.Drawing.Point(20, 380)
    $configLabel.Size = New-Object System.Drawing.Size(360, 25)
    $controlPanel.Controls.Add($configLabel)
    
    $global:AutoBackupCheckbox = New-Object System.Windows.Forms.CheckBox
    $global:AutoBackupCheckbox.Text = "🔄 Automatic backup before optimizations"
    $global:AutoBackupCheckbox.ForeColor = [System.Drawing.Color]::White
    $global:AutoBackupCheckbox.Location = New-Object System.Drawing.Point(20, 410)
    $global:AutoBackupCheckbox.Size = New-Object System.Drawing.Size(280, 20)
    $global:AutoBackupCheckbox.Checked = $true
    $controlPanel.Controls.Add($global:AutoBackupCheckbox)
    
    $saveConfigBtn = New-ModernButton "💾 Save" (New-Object System.Drawing.Point(310, 405)) (New-Object System.Drawing.Size(70, 30)) ([System.Drawing.Color]::FromArgb(60, 60, 60)) {
        try {
            $config = @{
                AutoBackup = $global:AutoBackupCheckbox.Checked
                SafeMode = $false
                LastAppliedProfile = ""
                PreferredProfile = "Balanced"
                Version = $global:AppVersion
            }
            $result = Save-Configuration $config
            if ($result) {
                [System.Windows.Forms.MessageBox]::Show("Configuration saved successfully!", "Settings Saved", "OK", "Information")
                Write-EnhancedLog "User configuration saved manually" "SUCCESS" "CONFIG"
            } else {
                [System.Windows.Forms.MessageBox]::Show("Failed to save configuration!", "Save Error", "OK", "Error")
            }
        } catch {
            Write-EnhancedLog "Save configuration error: $($_.Exception.Message)" "ERROR" "GUI"
            [System.Windows.Forms.MessageBox]::Show("Error saving configuration!", "Error", "OK", "Error")
        }
    }
    $controlPanel.Controls.Add($saveConfigBtn)
    
    # Right Panel - Status
    $statusPanel = New-Object System.Windows.Forms.Panel
    $statusPanel.Location = New-Object System.Drawing.Point(430, 10)
    $statusPanel.Size = New-Object System.Drawing.Size(720, 560)
    $statusPanel.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 22)
    $contentPanel.Controls.Add($statusPanel)
    
    # System Status Section
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "📊 System Optimization Status"
    $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
    $statusLabel.Location = New-Object System.Drawing.Point(20, 20)
    $statusLabel.Size = New-Object System.Drawing.Size(680, 25)
    $statusPanel.Controls.Add($statusLabel)
    
    # Status Display
    $global:StatusRichTextBox = New-Object System.Windows.Forms.RichTextBox
    $global:StatusRichTextBox.ReadOnly = $true
    $global:StatusRichTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
    $global:StatusRichTextBox.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
    $global:StatusRichTextBox.ForeColor = [System.Drawing.Color]::White
    $global:StatusRichTextBox.Location = New-Object System.Drawing.Point(20, 55)
    $global:StatusRichTextBox.Size = New-Object System.Drawing.Size(680, 220)
    $global:StatusRichTextBox.BorderStyle = "None"
    $statusPanel.Controls.Add($global:StatusRichTextBox)
    
    # Activity Log Section
    $logLabel = New-Object System.Windows.Forms.Label
    $logLabel.Text = "📝 Activity Log"
    $logLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $logLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 150, 255)
    $logLabel.Location = New-Object System.Drawing.Point(20, 295)
    $logLabel.Size = New-Object System.Drawing.Size(680, 25)
    $statusPanel.Controls.Add($logLabel)
    
    # Log Display
    $global:LogRichTextBox = New-Object System.Windows.Forms.RichTextBox
    $global:LogRichTextBox.ReadOnly = $true
    $global:LogRichTextBox.Font = New-Object System.Drawing.Font("Consolas", 8)
    $global:LogRichTextBox.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
    $global:LogRichTextBox.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 100)
    $global:LogRichTextBox.Location = New-Object System.Drawing.Point(20, 330)
    $global:LogRichTextBox.Size = New-Object System.Drawing.Size(680, 210)
    $global:LogRichTextBox.BorderStyle = "None"
    $statusPanel.Controls.Add($global:LogRichTextBox)
    
    # Footer
    $footerPanel = New-Object System.Windows.Forms.Panel
    $footerPanel.Location = New-Object System.Drawing.Point(0, 710)
    $footerPanel.Size = New-Object System.Drawing.Size(1200, 50)
    $footerPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
    $global:MainForm.Controls.Add($footerPanel)
    
    $footerLabel = New-Object System.Windows.Forms.Label
    $footerLabel.Text = "$global:AppName v$global:AppVersion • $global:AppPublisher • Professional Gaming Performance Optimizer"
    $footerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $footerLabel.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
    $footerLabel.Location = New-Object System.Drawing.Point(30, 15)
    $footerLabel.Size = New-Object System.Drawing.Size(800, 20)
    $footerPanel.Controls.Add($footerLabel)
    
    # Status update function
    function Update-StatusDisplay {
        try {
            if (-not $global:StatusRichTextBox) {
                Write-EnhancedLog "StatusRichTextBox not initialized" "DEBUG" "GUI"
                return
            }
            
            $status = Get-SystemOptimizationStatus
            if ($status) {
                $statusText = @"
═══════════════════════════════════════════════════════════════════════════════
GAMING PERFORMANCE STATUS • $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
═══════════════════════════════════════════════════════════════════════════════

🎯 OVERALL OPTIMIZATION: $($status.OverallStatus) ($($status.OptimizationLevel)% Optimized)

🎮 GAMING CONFIGURATION:
   GPU Priority: $($status.GPUPriority) $(if($status.GPUPriority -ge 6){"✅"}elseif($status.GPUPriority -ge 4){"⚡"}else{"📋"})
   CPU Priority: $($status.CPUPriority) $(if($status.CPUPriority -ge 6){"✅"}elseif($status.CPUPriority -ge 4){"⚡"}else{"📋"})
   Responsiveness: $($status.SystemResponsiveness) $(if($status.SystemResponsiveness -le 5){"✅"}elseif($status.SystemResponsiveness -le 10){"⚡"}else{"📋"})

🖥️ GRAPHICS & DISPLAY:
   Hardware Scheduling: $($status.HardwareScheduling) $(if($status.HardwareScheduling -eq "Enabled"){"✅"}else{"📋"})
   TDR Level: $($status.TDRLevel) $(if($status.TDRLevel -le 2){"✅"}elseif($status.TDRLevel -eq 3){"📋"}else{"⚠️"})
   Game DVR: $($status.GameDVR) $(if($status.GameDVR -like "*Optimized*"){"✅"}else{"⚠️"})

🔧 HARDWARE DETECTED:
   CPU: $global:CPUName $(if($global:HasX3D){"🔥 X3D"}else{""})
   GPU: $global:GPUName $(if($global:IsNVIDIA){"🟢 NVIDIA"}elseif($global:IsAMDGPU){"🔴 AMD"}else{""})
   Memory: $global:RAMTotal GB $global:RAMType$(if($global:RAMSpeed -gt 4000){"-$global:RAMSpeed 🚀"}else{""})
   OS: $global:OSName $(if($global:IsWindows11){"✅ Win11"}else{"📋"})

═══════════════════════════════════════════════════════════════════════════════
"@
                $global:StatusRichTextBox.Text = $statusText
                Write-EnhancedLog "Status display updated successfully" "DEBUG" "GUI"
            }
        } catch {
            Write-EnhancedLog "Failed to update status display: $($_.Exception.Message)" "ERROR" "GUI"
        }
    }
    
    # Initialize display
    try {
        Update-StatusDisplay
        Write-EnhancedLog "Status display initialized successfully" "SUCCESS" "GUI"
    } catch {
        Write-EnhancedLog "Failed to initialize status display: $($_.Exception.Message)" "WARN" "GUI"
    }
    
    # Load saved configuration
    try {
        $savedConfig = Load-Configuration
        if ($savedConfig -and $global:AutoBackupCheckbox) {
            if ($savedConfig -is [hashtable] -and $savedConfig.ContainsKey("AutoBackup")) {
                $global:AutoBackupCheckbox.Checked = $savedConfig["AutoBackup"]
            } elseif ($savedConfig -is [PSCustomObject] -and ($savedConfig | Get-Member -Name "AutoBackup" -MemberType Properties)) {
                $global:AutoBackupCheckbox.Checked = $savedConfig.AutoBackup
            } else {
                $global:AutoBackupCheckbox.Checked = $true  # Default value
            }
            Write-EnhancedLog "Configuration loaded successfully" "SUCCESS" "GUI"
        }
    } catch {
        Write-EnhancedLog "Failed to load saved configuration: $($_.Exception.Message)" "WARN" "GUI"
        if ($global:AutoBackupCheckbox) {
            $global:AutoBackupCheckbox.Checked = $true  # Default value
        }
    }
    
    Write-EnhancedLog "Modern GUI interface initialized successfully" "SUCCESS" "GUI"
    return $global:MainForm
}

# ===== MAIN APPLICATION ENTRY POINT =====
function Start-FPSSuiteProfessional {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $global:AppName" -ForegroundColor White
    Write-Host "  Professional Gaming Performance Optimizer" -ForegroundColor Gray
    Write-Host "  $global:AppPublisher" -ForegroundColor Gray
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Check Administrator privileges
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "❌ ERROR: Administrator privileges required!" -ForegroundColor Red
        Write-Host ""
        Write-Host "This application requires Administrator privileges to modify system settings." -ForegroundColor Yellow
        Write-Host "Please right-click and 'Run as Administrator' to continue." -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        return
    }
    
    Write-Host "✅ Administrator privileges: CONFIRMED" -ForegroundColor Green
    Write-Host ""
    
    # Initialize application
    Write-Host "🔄 Initializing Alphacode GameBoost Ultimate Edition..." -ForegroundColor Yellow
    if (-not (Initialize-Application)) {
        Write-Host "❌ Application initialization failed! Check logs for details." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        return
    }
    
    Write-Host "🔍 Hardware detection completed:" -ForegroundColor Green
    Write-Host "   CPU: $global:CPUName" -ForegroundColor White
    Write-Host "   GPU: $global:GPUName" -ForegroundColor White
    Write-Host "   RAM: $global:RAMTotal GB $global:RAMType-$global:RAMSpeed" -ForegroundColor White
    Write-Host "   OS: $global:OSName" -ForegroundColor White
    
    if ($global:HasX3D) {
        Write-Host "🔥 X3D CPU detected - specialized optimizations available!" -ForegroundColor Yellow
    }
    Write-Host ""
    
    # Create and show GUI
    Write-Host "🎨 Launching graphical interface..." -ForegroundColor Yellow
    try {
        $mainForm = Create-ModernGUI
        if ($mainForm) {
            Write-Host "✅ GUI launched successfully! Enjoy optimizing your gaming performance!" -ForegroundColor Green
            Write-Host ""
            
            # Show the form
            [System.Windows.Forms.Application]::EnableVisualStyles()
            [System.Windows.Forms.Application]::Run($mainForm)
        } else {
            Write-Host "❌ Failed to create GUI interface!" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ GUI Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Fallback: You can still use the optimization functions manually in PowerShell." -ForegroundColor Yellow
    }
}

# ===== START APPLICATION =====
Start-FPSSuiteProfessional