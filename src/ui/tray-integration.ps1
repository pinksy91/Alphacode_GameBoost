# Alphacode GameBoost - System Tray Integration
# Lightweight native Windows UI - no web dependencies

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== SYSTEM TRAY ICON =====
$script:TrayIcon = $null
$script:ContextMenu = $null
$script:CurrentProfile = "None"

function Initialize-SystemTrayIcon {
    <#
    .SYNOPSIS
        Creates system tray icon with context menu
    
    .DESCRIPTION
        Lightweight UI for quick actions:
        - View current profile
        - Switch profiles
        - Enable/disable auto-optimization
        - View performance stats
        - Exit
    #>
    
    # Create icon
    $script:TrayIcon = New-Object System.Windows.Forms.NotifyIcon
    
    # Load icon from embedded resource or create default
    $iconPath = "$PSScriptRoot\..\..\assets\tray-icon.ico"
    if (Test-Path $iconPath) {
        $script:TrayIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
    }
    else {
        # Create simple icon programmatically
        $bitmap = New-Object System.Drawing.Bitmap(16, 16)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.FillEllipse([System.Drawing.Brushes]::LimeGreen, 2, 2, 12, 12)
        $graphics.DrawString("GB", (New-Object System.Drawing.Font("Arial", 6)), [System.Drawing.Brushes]::Black, 3, 4)
        
        $hIcon = $bitmap.GetHicon()
        $script:TrayIcon.Icon = [System.Drawing.Icon]::FromHandle($hIcon)
    }
    
    $script:TrayIcon.Text = "Alphacode GameBoost"
    $script:TrayIcon.Visible = $true
    
    # Create context menu
    Create-TrayContextMenu
    
    # Double-click to open main window
    $script:TrayIcon.Add_DoubleClick({
            Show-QuickStatsWindow
        })
    
    Write-EnhancedLog "System tray icon initialized" "SUCCESS" "TRAY"
}

function Create-TrayContextMenu {
    <#
    .SYNOPSIS
        Creates right-click context menu for tray icon
    #>
    
    $script:ContextMenu = New-Object System.Windows.Forms.ContextMenuStrip
    
    # Header - Current Profile
    $headerItem = $script:ContextMenu.Items.Add("Current: $script:CurrentProfile")
    $headerItem.Font = New-Object System.Drawing.Font($headerItem.Font, [System.Drawing.FontStyle]::Bold)
    $headerItem.Enabled = $false
    
    $script:ContextMenu.Items.Add("-")  # Separator
    
    # Profile selection submenu
    $profileMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Switch Profile")
    
    $profiles = @("Conservative", "Balanced", "Aggressive", "Maximum")
    foreach ($profile in $profiles) {
        $profileItem = $profileMenu.DropDownItems.Add($profile)
        $profileItem.Add_Click({
                param($sender, $e)
                $selectedProfile = $sender.Text
                Apply-ProfileFromTray -ProfileName $selectedProfile
            })
    }
    
    $script:ContextMenu.Items.Add($profileMenu)
    
    # Auto-optimization toggle
    $autoOptItem = $script:ContextMenu.Items.Add("🎮 Auto-Optimize Games")
    $autoOptItem.CheckOnClick = $true
    $autoOptItem.Checked = (Get-Configuration).AutoOptimize
    $autoOptItem.Add_Click({
            param($sender, $e)
            Set-Configuration -Key "AutoOptimize" -Value $sender.Checked
            if ($sender.Checked) {
                Write-EnhancedLog "Auto-optimization enabled" "INFO" "TRAY"
                Start-GameDetectionLoop
            }
            else {
                Write-EnhancedLog "Auto-optimization disabled" "INFO" "TRAY"
                Stop-GameDetector
            }
        })
    
    $script:ContextMenu.Items.Add("-")  # Separator
    
    # Quick actions
    $statsItem = $script:ContextMenu.Items.Add("📊 Performance Stats")
    $statsItem.Add_Click({
            Show-QuickStatsWindow
        })
    
    $restoreItem = $script:ContextMenu.Items.Add("🔄 Restore Backup")
    $restoreItem.Add_Click({
            Show-RestoreDialog
        })
    
    $script:ContextMenu.Items.Add("-")  # Separator
    
    # Settings
    $settingsItem = $script:ContextMenu.Items.Add("⚙️ Settings")
    $settingsItem.Add_Click({
            Show-SettingsDialog
        })
    
    # Exit
    $exitItem = $script:ContextMenu.Items.Add("❌ Exit")
    $exitItem.Add_Click({
            Cleanup-TrayIcon
            [System.Windows.Forms.Application]::Exit()
        })
    
    $script:TrayIcon.ContextMenuStrip = $script:ContextMenu
}

function Update-TrayIconProfile {
    <#
    .SYNOPSIS
        Updates tray icon to reflect current profile
    #>
    
    param([string]$ProfileName)
    
    $script:CurrentProfile = $ProfileName
    
    # Update header in context menu
    $headerItem = $script:ContextMenu.Items[0]
    $headerItem.Text = "Current: $ProfileName"
    
    # Update tooltip
    $script:TrayIcon.Text = "Alphacode GameBoost`nProfile: $ProfileName"
    
    # Update icon color based on profile
    $iconColor = switch ($ProfileName) {
        "Conservative" { [System.Drawing.Color]::Green }
        "Balanced" { [System.Drawing.Color]::Yellow }
        "Aggressive" { [System.Drawing.Color]::Orange }
        "Maximum" { [System.Drawing.Color]::Red }
        default { [System.Drawing.Color]::Gray }
    }
    
    # Recreate icon with new color (simplified - actual impl would use better graphics)
    $bitmap = New-Object System.Drawing.Bitmap(16, 16)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.FillEllipse((New-Object System.Drawing.SolidBrush($iconColor)), 2, 2, 12, 12)
    
    $hIcon = $bitmap.GetHicon()
    $script:TrayIcon.Icon = [System.Drawing.Icon]::FromHandle($hIcon)
}

function Show-TrayNotification {
    <#
    .SYNOPSIS
        Shows balloon notification from tray icon
    
    .EXAMPLE
        Show-TrayNotification -Title "Optimization Applied" -Message "Balanced profile active" -Icon "Info"
    #>
    
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet("None", "Info", "Warning", "Error")]
        [string]$Icon = "Info",
        [int]$TimeoutMs = 5000
    )
    
    if ($script:TrayIcon) {
        $iconType = [System.Windows.Forms.ToolTipIcon]::$Icon
        $script:TrayIcon.ShowBalloonTip($TimeoutMs, $Title, $Message, $iconType)
    }
}

function Show-QuickStatsWindow {
    <#
    .SYNOPSIS
        Opens lightweight stats window (no web, pure WinForms)
    #>
    
    $statsForm = New-Object System.Windows.Forms.Form
    $statsForm.Text = "Alphacode GameBoost - Performance Stats"
    $statsForm.Size = New-Object System.Drawing.Size(400, 300)
    $statsForm.StartPosition = "CenterScreen"
    $statsForm.FormBorderStyle = "FixedDialog"
    $statsForm.MaximizeBox = $false
    
    # Current profile label
    $profileLabel = New-Object System.Windows.Forms.Label
    $profileLabel.Location = New-Object System.Drawing.Point(20, 20)
    $profileLabel.Size = New-Object System.Drawing.Size(350, 30)
    $profileLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $profileLabel.Text = "Current Profile: $script:CurrentProfile"
    $statsForm.Controls.Add($profileLabel)
    
    # System stats
    $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
    $gpu = Get-WmiObject Win32_VideoController | Select-Object -First 1
    $ram = Get-WmiObject Win32_OperatingSystem
    
    $statsText = New-Object System.Windows.Forms.TextBox
    $statsText.Location = New-Object System.Drawing.Point(20, 60)
    $statsText.Size = New-Object System.Drawing.Size(350, 150)
    $statsText.Multiline = $true
    $statsText.ReadOnly = $true
    $statsText.Font = New-Object System.Drawing.Font("Consolas", 9)
    $statsText.Text = @"
CPU: $($cpu.Name)
Load: $($cpu.LoadPercentage)%

GPU: $($gpu.Name)
VRAM: $([Math]::Round($gpu.AdapterRAM / 1GB, 1)) GB

RAM: $([Math]::Round($ram.TotalVisibleMemorySize / 1MB, 1)) GB
Free: $([Math]::Round($ram.FreePhysicalMemory / 1MB, 1)) GB

Optimizations Applied: $(if ($script:CurrentProfile -ne "None") { "Yes" } else { "No" })
"@
    $statsForm.Controls.Add($statsText)
    
    # Close button
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Location = New-Object System.Drawing.Point(140, 220)
    $closeButton.Size = New-Object System.Drawing.Size(100, 30)
    $closeButton.Text = "Close"
    $closeButton.Add_Click({ $statsForm.Close() })
    $statsForm.Controls.Add($closeButton)
    
    $statsForm.ShowDialog()
}

function Apply-ProfileFromTray {
    <#
    .SYNOPSIS
        Applies optimization profile from tray menu
    #>
    
    param([string]$ProfileName)
    
    Write-EnhancedLog "Applying $ProfileName profile from tray..." "INFO" "TRAY"
    
    # Show progress notification
    Show-TrayNotification -Title "Applying Optimization" -Message "Applying $ProfileName profile..." -Icon "Info"
    
    try {
        # Apply profile (this calls the main optimization function)
        Apply-IntelligentOptimizations -Profile $ProfileName
        
        # Update tray icon
        Update-TrayIconProfile -ProfileName $ProfileName
        
        # Show success notification
        Show-TrayNotification -Title "Optimization Applied" -Message "$ProfileName profile is now active" -Icon "Info"
        
    }
    catch {
        Write-EnhancedLog "Failed to apply profile: $($_.Exception.Message)" "ERROR" "TRAY"
        Show-TrayNotification -Title "Optimization Failed" -Message "Failed to apply $ProfileName profile" -Icon "Error"
    }
}

function Show-SettingsDialog {
    <#
    .SYNOPSIS
        Shows settings dialog
    #>
    
    $settingsForm = New-Object System.Windows.Forms.Form
    $settingsForm.Text = "GameBoost Settings"
    $settingsForm.Size = New-Object System.Drawing.Size(350, 250)
    $settingsForm.StartPosition = "CenterScreen"
    $settingsForm.FormBorderStyle = "FixedDialog"
    
    # Auto-optimize checkbox
    $autoOptCheck = New-Object System.Windows.Forms.CheckBox
    $autoOptCheck.Location = New-Object System.Drawing.Point(20, 20)
    $autoOptCheck.Size = New-Object System.Drawing.Size(300, 20)
    $autoOptCheck.Text = "Enable auto-optimization for detected games"
    $autoOptCheck.Checked = (Get-Configuration).AutoOptimize
    $settingsForm.Controls.Add($autoOptCheck)
    
    # Revert on exit checkbox
    $revertCheck = New-Object System.Windows.Forms.CheckBox
    $revertCheck.Location = New-Object System.Drawing.Point(20, 50)
    $revertCheck.Size = New-Object System.Drawing.Size(300, 20)
    $revertCheck.Text = "Revert optimizations when game exits"
    $revertCheck.Checked = (Get-Configuration).RevertOnGameExit
    $settingsForm.Controls.Add($revertCheck)
    
    # Notification checkbox
    $notifCheck = New-Object System.Windows.Forms.CheckBox
    $notifCheck.Location = New-Object System.Drawing.Point(20, 80)
    $notifCheck.Size = New-Object System.Drawing.Size(300, 20)
    $notifCheck.Text = "Show tray notifications"
    $notifCheck.Checked = (Get-Configuration).ShowNotifications
    $settingsForm.Controls.Add($notifCheck)
    
    # Save button
    $saveButton = New-Object System.Windows.Forms.Button
    $saveButton.Location = New-Object System.Drawing.Point(70, 150)
    $saveButton.Size = New-Object System.Drawing.Size(80, 30)
    $saveButton.Text = "Save"
    $saveButton.Add_Click({
            Set-Configuration -Key "AutoOptimize" -Value $autoOptCheck.Checked
            Set-Configuration -Key "RevertOnGameExit" -Value $revertCheck.Checked
            Set-Configuration -Key "ShowNotifications" -Value $notifCheck.Checked
            Save-Configuration (Get-Configuration)
            $settingsForm.Close()
            Show-TrayNotification -Title "Settings Saved" -Message "Settings have been saved" -Icon "Info"
        })
    $settingsForm.Controls.Add($saveButton)
    
    # Cancel button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(170, 150)
    $cancelButton.Size = New-Object System.Drawing.Size(80, 30)
    $cancelButton.Text = "Cancel"
    $cancelButton.Add_Click({ $settingsForm.Close() })
    $settingsForm.Controls.Add($cancelButton)
    
    $settingsForm.ShowDialog()
}

function Cleanup-TrayIcon {
    <#
    .SYNOPSIS
        Cleans up tray icon on exit
    #>
    
    if ($script:TrayIcon) {
        $script:TrayIcon.Visible = $false
        $script:TrayIcon.Dispose()
    }
}

# Export functions
Export-ModuleMember -Function Initialize-SystemTrayIcon, Show-TrayNotification, Update-TrayIconProfile, Cleanup-TrayIcon
