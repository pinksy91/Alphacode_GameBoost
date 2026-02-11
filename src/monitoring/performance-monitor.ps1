# Alphacode GameBoost - Performance Monitor
# Local-only monitoring via WMI/Performance Counters - zero external dependencies

Add-Type -AssemblyName System.Windows.Forms

# ===== PERFORMANCE MONITORING =====
$script:MonitorRunning = $false
$script:PerformanceHistory = @()
$script:MonitorInterval = 1000  # ms

function Initialize-PerformanceMonitor {
    <#
    .SYNOPSIS
        Initializes lightweight performance monitoring
    
    .DESCRIPTION
        Monitors CPU, GPU, RAM, Temps using Windows APIs only
        No external tools required (uses WMI + Performance Counters)
    #>
    
    Write-EnhancedLog "Initializing Performance Monitor..." "INFO" "MONITOR"
    
    # Initialize performance counters
    try {
        $script:CPUCounter = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
        $script:RAMCounter = New-Object System.Diagnostics.PerformanceCounter("Memory", "Available MBytes")
        
        Write-EnhancedLog "Performance counters initialized" "SUCCESS" "MONITOR"
    }
    catch {
        Write-EnhancedLog "Failed to initialize counters: $($_.Exception.Message)" "ERROR" "MONITOR"
    }
}

function Get-CurrentPerformanceMetrics {
    <#
    .SYNOPSIS
        Gets current system performance snapshot
    
    .OUTPUTS
        Hashtable with CPU, GPU, RAM, Temps
    #>
    
    $metrics = @{
        Timestamp = Get-Date
        CPU       = @{
            Usage       = 0
            Temperature = 0
            Name        = ""
        }
        GPU       = @{
            Usage       = 0
            Temperature = 0
            Name        = ""
            VRAM        = 0
        }
        RAM       = @{
            TotalMB      = 0
            UsedMB       = 0
            UsagePercent = 0
        }
    }
    
    try {
        # CPU Usage (Performance Counter)
        if ($script:CPUCounter) {
            $metrics.CPU.Usage = [Math]::Round($script:CPUCounter.NextValue(), 1)
        }
        
        # CPU Info & Temp (WMI)
        $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
        $metrics.CPU.Name = $cpu.Name
        
        # Try to get CPU temp (works on some systems)
        try {
            $temps = Get-WmiObject -Namespace "root\wmi" -Class MSAcpi_ThermalZoneTemperature
            if ($temps) {
                $tempKelvin = $temps | Select-Object -First 1 -ExpandProperty CurrentTemperature
                $metrics.CPU.Temperature = [Math]::Round(($tempKelvin / 10) - 273.15, 1)
            }
        }
        catch {
            # Temperature not available on all systems
            $metrics.CPU.Temperature = $null
        }
        
        # GPU Info (WMI)
        $gpu = Get-WmiObject Win32_VideoController | Select-Object -First 1
        $metrics.GPU.Name = $gpu.Name
        $metrics.GPU.VRAM = [Math]::Round($gpu.AdapterRAM / 1GB, 1)
        
        # GPU usage (requires additional tools like nvidia-smi or AMD equivalent)
        # For now, we skip this to keep it lightweight
        $metrics.GPU.Usage = $null
        
        # RAM (Performance Counter + WMI)
        $ram = Get-WmiObject Win32_OperatingSystem
        $metrics.RAM.TotalMB = [Math]::Round($ram.TotalVisibleMemorySize / 1KB)
        
        if ($script:RAMCounter) {
            $availableMB = $script:RAMCounter.NextValue()
            $metrics.RAM.UsedMB = $metrics.RAM.TotalMB - $availableMB
            $metrics.RAM.UsagePercent = [Math]::Round(($metrics.RAM.UsedMB / $metrics.RAM.TotalMB) * 100, 1)
        }
        
    }
    catch {
        Write-EnhancedLog "Error collecting metrics: $($_.Exception.Message)" "ERROR" "MONITOR"
    }
    
    return $metrics
}

function Start-PerformanceMonitoring {
    <#
    .SYNOPSIS
        Starts background performance monitoring
    
    .PARAMETER HistorySize
        Number of samples to keep in history (default: 60 = 1 minute at 1s interval)
    #>
    
    param([int]$HistorySize = 60)
    
    $script:MonitorRunning = $true
    
    # Background monitoring loop
    $script:MonitorJob = Start-Job -ScriptBlock {
        param($Interval, $HistorySize)
        
        $history = @()
        
        while ($true) {
            # Collect metrics (simplified for job context)
            $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
            $ram = Get-WmiObject Win32_OperatingSystem
            
            $sample = @{
                Timestamp  = Get-Date
                CPUUsage   = $cpu.LoadPercentage
                RAMUsedGB  = [Math]::Round(($ram.TotalVisibleMemorySize - $ram.FreePhysicalMemory) / 1MB, 2)
                RAMTotalGB = [Math]::Round($ram.TotalVisibleMemorySize / 1MB, 2)
            }
            
            $history += $sample
            
            # Keep only recent history
            if ($history.Count -gt $HistorySize) {
                $history = $history | Select-Object -Last $HistorySize
            }
            
            # Output for retrieval
            $sample
            
            Start-Sleep -Milliseconds $Interval
        }
    } -ArgumentList $script:MonitorInterval, $HistorySize
    
    Write-EnhancedLog "Performance monitoring started (interval: $script:MonitorInterval ms)" "SUCCESS" "MONITOR"
}

function Get-PerformanceHistory {
    <#
    .SYNOPSIS
        Retrieves performance history from background monitor
    
    .OUTPUTS
        Array of performance samples
    #>
    
    if ($script:MonitorJob) {
        $samples = Receive-Job $script:MonitorJob -Keep
        return $samples
    }
    
    return @()
}

function Stop-PerformanceMonitoring {
    <#
    .SYNOPSIS
        Stops performance monitoring
    #>
    
    if ($script:MonitorJob) {
        Stop-Job $script:MonitorJob
        Remove-Job $script:MonitorJob
        $script:MonitorRunning = $false
        Write-EnhancedLog "Performance monitoring stopped" "INFO" "MONITOR"
    }
}

function Show-PerformanceOverlay {
    <#
    .SYNOPSIS
        Shows minimal on-screen performance overlay (WinForms, not intrusive)
    
    .DESCRIPTION
        Lightweight transparent overlay in corner of screen
        Shows: FPS (if available), CPU%, RAM%, GPU%
    #>
    
    $overlayForm = New-Object System.Windows.Forms.Form
    $overlayForm.Text = ""
    $overlayForm.Size = New-Object System.Drawing.Size(180, 100)
    $overlayForm.FormBorderStyle = "None"
    $overlayForm.BackColor = [System.Drawing.Color]::Black
    $overlayForm.Opacity = 0.7
    $overlayForm.TopMost = $true
    $overlayForm.ShowInTaskbar = $false
    
    # Position in top-right corner
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen
    $overlayForm.Location = New-Object System.Drawing.Point(($screen.WorkingArea.Width - 200), 20)
    
    # Stats label
    $statsLabel = New-Object System.Windows.Forms.Label
    $statsLabel.Location = New-Object System.Drawing.Point(10, 10)
    $statsLabel.Size = New-Object System.Drawing.Size(160, 80)
    $statsLabel.ForeColor = [System.Drawing.Color]::LimeGreen
    $statsLabel.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
    $statsLabel.BackColor = [System.Drawing.Color]::Transparent
    $overlayForm.Controls.Add($statsLabel)
    
    # Update timer
    $updateTimer = New-Object System.Windows.Forms.Timer
    $updateTimer.Interval = 1000  # Update every second
    $updateTimer.Add_Tick({
            $metrics = Get-CurrentPerformanceMetrics
        
            $statsLabel.Text = @"
CPU: $($metrics.CPU.Usage)%
RAM: $($metrics.RAM.UsagePercent)%
TEMP: $($metrics.CPU.Temperature)°C
"@
        })
    $updateTimer.Start()
    
    # Close on double-click
    $overlayForm.Add_DoubleClick({
            $updateTimer.Stop()
            $overlayForm.Close()
        })
    
    $overlayForm.Show()
    [System.Windows.Forms.Application]::Run($overlayForm)
}

function Get-AveragePerformance {
    <#
    .SYNOPSIS
        Calculates average performance over time window
    
    .PARAMETER Minutes
        Time window in minutes
    #>
    
    param([int]$Minutes = 5)
    
    $history = Get-PerformanceHistory
    $cutoff = (Get-Date).AddMinutes(-$Minutes)
    
    $recentSamples = $history | Where-Object { $_.Timestamp -gt $cutoff }
    
    if ($recentSamples.Count -eq 0) {
        return $null
    }
    
    return @{
        AvgCPU      = ($recentSamples | Measure-Object -Property CPUUsage -Average).Average
        AvgRAM      = ($recentSamples | Measure-Object -Property RAMUsedGB -Average).Average
        SampleCount = $recentSamples.Count
        TimeRange   = "$Minutes minutes"
    }
}

# Export functions
Export-ModuleMember -Function Initialize-PerformanceMonitor, Get-CurrentPerformanceMetrics, `
    Start-PerformanceMonitoring, Get-PerformanceHistory, `
    Stop-PerformanceMonitoring, Show-PerformanceOverlay, Get-AveragePerformance
