# Alphacode GameBoost - Smart Scheduler
# Rule-based intelligent scheduling - no ML, 100% local, privacy-first

# ===== SMART SCHEDULER =====
$script:SchedulerRules = @()
$script:UserPatterns = @()

function Initialize-SmartScheduler {
    <#
    .SYNOPSIS
        Initializes intelligent optimization scheduler
    
    .DESCRIPTION
        Learns user patterns (locally) and suggests optimal times to optimize
        100% rule-based - no external ML APIs
        Privacy-first - all data stored locally
    #>
    
    Write-EnhancedLog "Initializing Smart Scheduler..." "INFO" "SCHEDULER"
    
    # Load historical usage patterns
    Load-UserPatterns
    
    # Define scheduling rules
    Initialize-SchedulingRules
    
    Write-EnhancedLog "Smart Scheduler initialized with $($script:SchedulerRules.Count) rules" "SUCCESS" "SCHEDULER"
}

function Load-UserPatterns {
    <#
    .SYNOPSIS
        Loads user gaming patterns from local history
    #>
    
    $patternsFile = "$global:ConfigPath\user_patterns.json"
    
    if (Test-Path $patternsFile) {
        try {
            $script:UserPatterns = Get-Content $patternsFile -Raw | ConvertFrom-Json
            Write-EnhancedLog "Loaded $($script:UserPatterns.Count) user patterns" "INFO" "SCHEDULER"
        }
        catch {
            Write-EnhancedLog "Failed to load patterns: $($_.Exception.Message)" "ERROR" "SCHEDULER"
            $script:UserPatterns = @()
        }
    }
    else {
        $script:UserPatterns = @()
    }
}

function Save-UserPattern {
    <#
    .SYNOPSIS
        Saves a new user pattern (gaming session)
    #>
    
    param(
        [string]$GameName,
        [string]$ProfileUsed,
        [datetime]$StartTime,
        [datetime]$EndTime,
        [int]$DurationMinutes
    )
    
    $pattern = @{
        GameName        = $GameName
        ProfileUsed     = $ProfileUsed
        DayOfWeek       = $StartTime.DayOfWeek.ToString()
        Hour            = $StartTime.Hour
        DurationMinutes = $DurationMinutes
        Timestamp       = $StartTime
    }
    
    $script:UserPatterns += $pattern
    
    # Save to file
    $patternsFile = "$global:ConfigPath\user_patterns.json"
    $script:UserPatterns | ConvertTo-Json -Depth 10 | Set-Content $patternsFile -Encoding UTF8
    
    Write-EnhancedLog "Saved gaming session pattern: $GameName on $($StartTime.DayOfWeek) at $($StartTime.Hour):00" "DEBUG" "SCHEDULER"
}

function Initialize-SchedulingRules {
    <#
    .SYNOPSIS
        Defines intelligent scheduling rules
    #>
    
    $script:SchedulerRules = @(
        # Rule 1: Weekly gaming pattern
        @{
            Name      = "Weekly Gaming Pattern"
            Priority  = "High"
            Condition = {
                param($CurrentTime, $Patterns)
                
                # Check if user typically games at this time
                $currentDay = $CurrentTime.DayOfWeek
                $currentHour = $CurrentTime.Hour
                
                $matchingPatterns = $Patterns | Where-Object {
                    $_.DayOfWeek -eq $currentDay.ToString() -and
                    [Math]::Abs($_.Hour - $currentHour) -le 1  # Within 1 hour
                }
                
                return @{
                    Match           = ($matchingPatterns.Count -ge 2)  # At least 2 occurrences
                    Confidence      = [Math]::Min(($matchingPatterns.Count / 10.0), 1.0)  # Max 100%
                    Message         = "You typically game around this time ($currentDay $currentHour:00)"
                    SuggestedAction = "Apply your usual profile: $($matchingPatterns[0].ProfileUsed)"
                }
            }
        },
        
        # Rule 2: Performance degradation detection
        @{
            Name      = "Performance Degradation"
            Priority  = "High"
            Condition = {
                param($CurrentTime, $Patterns, $PerformanceHistory)
                
                if ($PerformanceHistory.Count -lt 100) {
                    return @{ Match = $false }
                }
                
                # Compare recent performance vs historical average
                $recentAvgCPU = ($PerformanceHistory | Select-Object -Last 20 | Measure-Object -Property CPUUsage -Average).Average
                $historicalAvgCPU = ($PerformanceHistory | Select-Object -First 50 | Measure-Object -Property CPUUsage -Average).Average
                
                $degradation = $recentAvgCPU - $historicalAvgCPU
                
                return @{
                    Match           = ($degradation -gt 15)  # 15% increase in CPU usage
                    Confidence      = [Math]::Min($degradation / 30.0, 1.0)
                    Message         = "CPU usage increased by $([Math]::Round($degradation, 1))% - system may need optimization"
                    SuggestedAction = "Re-apply optimizations or upgrade profile"
                }
            }
        },
        
        # Rule 3: System idle detection
        @{
            Name      = "System Idle Optimization"
            Priority  = "Low"
            Condition = {
                param($CurrentTime, $Patterns, $PerformanceHistory)
                
                # Check if system has been idle (low CPU) for a while
                $recentSamples = $PerformanceHistory | Select-Object -Last 10
                $avgCPU = ($recentSamples | Measure-Object -Property CPUUsage -Average).Average
                
                $isIdle = $avgCPU -lt 20
                
                return @{
                    Match           = $isIdle
                    Confidence      = 0.6
                    Message         = "System is idle - good time to apply optimizations without disruption"
                    SuggestedAction = "Run optimization maintenance"
                }
            }
        },
        
        # Rule 4: Driver update detection
        @{
            Name      = "Driver Update Detected"
            Priority  = "Medium"
            Condition = {
                param($CurrentTime, $Patterns)
                
                # Check last GPU driver update
                $gpu = Get-WmiObject Win32_VideoController | Select-Object -First 1
                $driverDate = [datetime]::ParseExact($gpu.DriverDate.Substring(0, 8), "yyyyMMdd", $null)
                
                $daysSinceUpdate = ($CurrentTime - $driverDate).Days
                
                return @{
                    Match           = ($daysSinceUpdate -le 3 -and $daysSinceUpdate -ge 0)
                    Confidence      = 0.8
                    Message         = "GPU driver updated $daysSinceUpdate days ago"
                    SuggestedAction = "Recalibrate optimizations for new driver"
                }
            }
        },
        
        # Rule 5: High memory usage
        @{
            Name      = "High Memory Usage"
            Priority  = "Medium"
            Condition = {
                param($CurrentTime, $Patterns, $PerformanceHistory)
                
                $recentRAM = ($PerformanceHistory | Select-Object -Last 5 | Measure-Object -Property RAMUsedGB -Average).Average
                $totalRAM = ($PerformanceHistory | Select-Object -Last 1)[0].RAMTotalGB
                
                $ramUsagePercent = ($recentRAM / $totalRAM) * 100
                
                return @{
                    Match           = ($ramUsagePercent -gt 85)
                    Confidence      = 0.7
                    Message         = "RAM usage at $([Math]::Round($ramUsagePercent, 1))%"
                    SuggestedAction = "Clear standby memory or reduce background processes"
                }
            }
        }
    )
}

function Get-SmartSuggestions {
    <#
    .SYNOPSIS
        Evaluates all rules and returns optimization suggestions
    
    .OUTPUTS
        Array of suggestions with confidence scores
    #>
    
    $currentTime = Get-Date
    $performanceHistory = Get-PerformanceHistory
    
    $suggestions = @()
    
    foreach ($rule in $script:SchedulerRules) {
        try {
            $result = & $rule.Condition -CurrentTime $currentTime `
                -Patterns $script:UserPatterns `
                -PerformanceHistory $performanceHistory
            
            if ($result.Match) {
                $suggestions += @{
                    RuleName        = $rule.Name
                    Priority        = $rule.Priority
                    Confidence      = $result.Confidence
                    Message         = $result.Message
                    SuggestedAction = $result.SuggestedAction
                    Timestamp       = $currentTime
                }
                
                Write-EnhancedLog "Smart suggestion: $($result.Message)" "INFO" "SCHEDULER"
            }
        }
        catch {
            Write-EnhancedLog "Error evaluating rule $($rule.Name): $($_.Exception.Message)" "ERROR" "SCHEDULER"
        }
    }
    
    # Sort by priority and confidence
    $priorityOrder = @{ "High" = 3; "Medium" = 2; "Low" = 1 }
    $suggestions = $suggestions | Sort-Object {
        $priorityOrder[$_.Priority] * 1000 + ($_.Confidence * 100)
    } -Descending
    
    return $suggestions
}

function Start-SmartScheduler {
    <#
    .SYNOPSIS
        Starts smart scheduler background service
    
    .PARAMETER CheckInterval
        How often to check for suggestions (minutes)
    #>
    
    param([int]$CheckIntervalMinutes = 60)
    
    Write-EnhancedLog "Starting Smart Scheduler (check interval: $CheckIntervalMinutes min)" "INFO" "SCHEDULER"
    
    # Register scheduled task
    $trigger = New-JobTrigger -Once -At (Get-Date) `
        -RepetitionInterval (New-TimeSpan -Minutes $CheckIntervalMinutes) `
        -RepeatIndefinitely
    
    $script:SchedulerJob = Register-ScheduledJob -Name "GameBoost_SmartScheduler" `
        -Trigger $trigger `
        -ScriptBlock {
        # Load patterns and check suggestions
        $suggestions = Get-SmartSuggestions
        
        # Show notification for high-priority suggestions
        $topSuggestion = $suggestions | Where-Object { $_.Priority -eq "High" -and $_.Confidence -gt 0.7 } | Select-Object -First 1
        
        if ($topSuggestion) {
            Show-TrayNotification -Title "GameBoost Suggestion" `
                -Message "$($topSuggestion.Message)`n`n$($topSuggestion.SuggestedAction)" `
                -Icon "Info"
        }
    }
    
    Write-EnhancedLog "Smart Scheduler started successfully" "SUCCESS" "SCHEDULER"
}

function Stop-SmartScheduler {
    <#
    .SYNOPSIS
        Stops smart scheduler
    #>
    
    Unregister-ScheduledJob -Name "GameBoost_SmartScheduler" -ErrorAction SilentlyContinue
    Write-EnhancedLog "Smart Scheduler stopped" "INFO" "SCHEDULER"
}

# Export functions
Export-ModuleMember -Function Initialize-SmartScheduler, Get-SmartSuggestions, Start-SmartScheduler, `
    Stop-SmartScheduler, Save-UserPattern
