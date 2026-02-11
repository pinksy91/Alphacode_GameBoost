# Alphacode GameBoost - Next-Gen Orchestrator
# Integrates all next-gen features: game detection, auto-optim, tray UI, monitoring, smart scheduling

# Import all modules
. "$PSScriptRoot\detection\game-detector.ps1"
. "$PSScriptRoot\ui\tray-integration.ps1"
. "$PSScriptRoot\monitoring\performance-monitor.ps1"
. "$PSScriptRoot\scheduler\smart-scheduler.ps1"

# ===== ORCHESTRATOR =====
$script:OrchestratorRunning = $false

function Start-NextGenOrchestrator {
    <#
    .SYNOPSIS
        Starts all next-gen services
    
    .DESCRIPTION
        Lightweight orchestrator that manages:
        - Smart game detection
        - System tray UI
        - Performance monitoring
        - Smart scheduler
        
        100% local, privacy-first, zero external dependencies
    
    .PARAMETER EnableAutoOptimize
        Auto-apply profiles when games detected
    
    .PARAMETER ShowTrayIcon
        Show system tray icon (default: true)
    
    .PARAMETER EnableMonitoring
        Enable performance monitoring (default: true)
    
    .PARAMETER EnableSmartScheduler
        Enable intelligent scheduling (default: true)
    #>
    
    param(
        [bool]$EnableAutoOptimize = $true,
        [bool]$ShowTrayIcon = $true,
        [bool]$EnableMonitoring = $true,
        [bool]$EnableSmartScheduler = $true
    )
    
    Write-EnhancedLog "═══════════════════════════════════════════" "INFO" "ORCHESTRATOR"
    Write-EnhancedLog "  Alphacode GameBoost Next-Gen v3.3.0   " "SUCCESS" "ORCHESTRATOR"
    Write-EnhancedLog "  100% Local | Privacy-First | Lightweight  " "INFO" "ORCHESTRATOR"
    Write-EnhancedLog "═══════════════════════════════════════════" "INFO" "ORCHESTRATOR"
    
    $script:OrchestratorRunning = $true
    
    # 1. Initialize System Tray
    if ($ShowTrayIcon) {
        Write-EnhancedLog "Starting System Tray Integration..." "INFO" "ORCHESTRATOR"
        Initialize-SystemTrayIcon
        Update-TrayIconProfile -ProfileName (Get-Configuration).LastAppliedProfile
    }
    
    # 2. Initialize Game Detector
    Write-EnhancedLog "Starting Smart Game Detector..." "INFO" "ORCHESTRATOR"
    Initialize-GameDetector
    
    # 3. Start Performance  Monitoring
    if ($EnableMonitoring) {
        Write-EnhancedLog "Starting Performance Monitor..." "INFO" "ORCHESTRATOR"
        Initialize-PerformanceMonitor
        Start-PerformanceMonitoring
    }
    
    # 4. Initialize Smart Scheduler
    if ($EnableSmartScheduler) {
        Write-EnhancedLog "Starting Smart Scheduler..." "INFO" "ORCHESTRATOR"
        Initialize-SmartScheduler
        Start-SmartScheduler -CheckIntervalMinutes 60
    }
    
    # 5. Start Auto-Optimization Loop
    if ($EnableAutoOptimize) {
        Write-EnhancedLog "Starting Auto-Optimization Engine..." "INFO" "ORCHESTRATOR"
        
        # Run game-based optimization in background
        Start-Job -ScriptBlock {
            param($AutoApply)
            
            . "$using:PSScriptRoot\detection\game-detector.ps1"
            Invoke-GameBasedOptimization -AutoApply $AutoApply
            
        } -ArgumentList $EnableAutoOptimize | Out-Null
    }
    
    Write-EnhancedLog "═══════════════════════════════════════════" "SUCCESS" "ORCHESTRATOR"
    Write-EnhancedLog "  All Services Running Successfully!    " "SUCCESS" "ORCHESTRATOR"
    Write-EnhancedLog "═══════════════════════════════════════════" "SUCCESS" "ORCHESTRATOR"
    
    # Show welcome notification
    if ($ShowTrayIcon) {
        Show-TrayNotification -Title "GameBoost Active" `
            -Message "Next-gen optimization engine running. Right-click tray icon for options." `
            -Icon "Info"
    }
    
    # Keep running
    Write-EnhancedLog "Orchestrator running - minimize this window (services run in background)" "INFO" "ORCHESTRATOR"
    Write-EnhancedLog "To exit: Right-click tray icon > Exit" "INFO" "ORCHESTRATOR"
}

function Stop-NextGenOrchestrator {
    <#
    .SYNOPSIS
        Stops all next-gen services gracefully
    #>
    
    Write-EnhancedLog "Stopping orchestrator..." "INFO" "ORCHESTRATOR"
    
    # Stop all services
    Stop-GameDetector
    Stop-PerformanceMonitoring
    Stop-SmartScheduler
    Cleanup-TrayIcon
    
    # Stop background jobs
    Get-Job | Where-Object { $_.Name -like "*GameBoost*" } | Stop-Job
    Get-Job | Where-Object { $_.Name -like "*GameBoost*" } | Remove-Job
    
    $script:OrchestratorRunning = $false
    
    Write-EnhancedLog "Orchestrator stopped" "SUCCESS" "ORCHESTRATOR"
}

function Get-NextGenStatus {
    <#
    .SYNOPSIS
        Returns status of all next-gen services
    #>
    
    return @{
        OrchestratorRunning  = $script:OrchestratorRunning
        GameDetectorActive   = (Get-Job | Where-Object { $_.Name -like "*Detector*" }).State -eq "Running"
        MonitoringActive     = $script:MonitorRunning
        SmartSchedulerActive = (Get-ScheduledJob -Name "GameBoost_SmartScheduler" -ErrorAction SilentlyContinue) -ne $null
        DetectedGame         = Get-DetectedGame
        PerformanceMetrics   = Get-CurrentPerformanceMetrics
        SmartSuggestions     = Get-SmartSuggestions
    }
}

function Show-NextGenDashboard {
    <#
    .SYNOPSIS
        Shows comprehensive status dashboard (WinForms, not web)
    #>
    
    $status = Get-Next GenStatus
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Alphacode GameBoost - Next-Gen Dashboard"
    $form.Size = New-Object System.Drawing.Size(500, 400)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    
    # Status text
    $statusText = New-Object System.Windows.Forms.TextBox
    $statusText.Location = New-Object System.Drawing.Point(20, 20)
    $statusText.Size = New-Object System.Drawing.Size(450, 300)
    $statusText.Multiline = $true
    $statusText.ReadOnly = $true
    $statusText.Font = New-Object System.Drawing.Font("Consolas", 9)
    $statusText.ScrollBars = "Vertical"
    
    $statusText.Text = @"
═══════════ ALPHACODE GAMEBOOST NEXT-GEN ═══════════

🎮 GAME DETECTION:
   Status: $(if ($status.GameDetectorActive) { "✅ Active" } else { "❌ Inactive" })
   Current Game: $(if ($status.DetectedGame) { $status.DetectedGame.GameName } else { "None" })

📊 PERFORMANCE MONITORING:
   Status: $(if ($status.MonitoringActive) { "✅ Active" } else { "❌ Inactive" })
   CPU: $($status.PerformanceMetrics.CPU.Usage)%
   RAM: $($status.PerformanceMetrics.RAM.UsagePercent)%
   Temp: $($status.PerformanceMetrics.CPU.Temperature)°C

🔮 SMART SCHEDULER:
   Status: $(if ($status.SmartSchedulerActive) { "✅ Active" } else { "❌ Inactive" })
   Suggestions: $($status.SmartSuggestions.Count)

⚙️ CURRENT PROFILE:
   $($(Get-Configuration).LastAppliedProfile)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 SMART SUGGESTIONS:
$(foreach ($suggestion in ($status.SmartSuggestions | Select-Object -First 3)) {
    "   [$($suggestion.Priority)] $($suggestion.Message)`n   → $($suggestion.SuggestedAction)`n"
})

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔒 Privacy: 100% Local | No Telemetry | No External APIs
"@
    
    $form.Controls.Add($statusText)
    
    # Close button
    $closeBtn = New-Object System.Windows.Forms.Button
    $closeBtn.Location = New-Object System.Drawing.Point(200, 330)
    $closeBtn.Size = New-Object System.Drawing.Size(100, 30)
    $closeBtn.Text = "Close"
    $closeBtn.Add_Click({ $form.Close() })
    $form.Controls.Add($closeBtn)
    
    $form.ShowDialog()
}

# Export functions
Export-ModuleMember -Function Start-NextGenOrchestrator, Stop-NextGenOrchestrator, `
    Get-NextGenStatus, Show-NextGenDashboard
