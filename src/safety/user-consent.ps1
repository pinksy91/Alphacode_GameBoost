# Alphacode GameBoost - User Consent System
# Always ask user permission before applying any tweaks

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Import tweak registry
. "$PSScriptRoot\..\safety\tweak-registry.ps1"

function Show-TweakConsentDialog {
    <#
    .SYNOPSIS
        Shows detailed consent dialog before applying tweaks
    
    .DESCRIPTION
        Displays:
        - List of tweaks to be applied
        - Risk level for each
        - Detailed description of changes
        - Impact and side effects
        - Requires explicit user confirmation
    
    .PARAMETER Tweaks
        Array of tweak objects to apply
    
    .PARAMETER ProfileName
        Name of profile (for context)
    
    .OUTPUTS
        @{ Approved = $true/$false; SelectedTweaks = array }
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [array]$Tweaks,
        
        [string]$ProfileName = "Custom"
    )
    
    # Create dialog
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = "Alphacode GameBoost - Confirm Optimizations"
    $dialog.Size = New-Object System.Drawing.Size(700, 600)
    $dialog.StartPosition = "CenterScreen"
    $dialog.FormBorderStyle = "FixedDialog"
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false
    
    # Header
    $headerLabel = New-Object System.Windows.Forms.Label
    $headerLabel.Location = New-Object System.Drawing.Point(20, 20)
    $headerLabel.Size = New-Object System.Drawing.Size(650, 40)
    $headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $headerLabel.Text = "Profile: $ProfileName`nReview changes before applying:"
    $dialog.Controls.Add($headerLabel)
    
    # Tweak list with checkboxes
    $tweakPanel = New-Object System.Windows.Forms.Panel
    $tweakPanel.Location = New-Object System.Drawing.Point(20, 70)
    $tweakPanel.Size = New-Object System.Drawing.Size(650, 400)
    $tweakPanel.AutoScroll = $true
    $tweakPanel.BorderStyle = "FixedSingle"
    $dialog.Controls.Add($tweakPanel)
    
    $yPos = 10
    $checkboxes = @()
    
    foreach ($tweak in $Tweaks) {
        # Checkbox for tweak
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Location = New-Object System.Drawing.Point(10, $yPos)
        $checkbox.Size = New-Object System.Drawing.Size(600, 20)
        $checkbox.Checked = $true
        $checkbox.Tag = $tweak
        
        # Color-coded by risk
        $riskColor = switch ($tweak.RiskLevel) {
            "SAFE" { [System.Drawing.Color]::Green }
            "WARNING" { [System.Drawing.Color]::Orange }
            "DANGEROUS" { [System.Drawing.Color]::Red }
        }
        
        $checkbox.ForeColor = $riskColor
        $checkbox.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $checkbox.Text = "[$($tweak.RiskLevel)] $($tweak.Name)"
        
        $tweakPanel.Controls.Add($checkbox)
        $checkboxes += $checkbox
        $yPos += 25
        
        # Description
        $descLabel = New-Object System.Windows.Forms.Label
        $descLabel.Location = New-Object System.Drawing.Point(30, $yPos)
        $descLabel.Size = New-Object System.Drawing.Size(580, 40)
        $descLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $descLabel.Text = "$($tweak.Description)`n✓ $($tweak.Impact)"
        $tweakPanel.Controls.Add($descLabel)
        $yPos += 45
        
        # Warning/Danger message if applicable
        if ($tweak.RiskLevel -eq "WARNING" -and $tweak.WarningMessage) {
            $warnLabel = New-Object System.Windows.Forms.Label
            $warnLabel.Location = New-Object System.Drawing.Point(30, $yPos)
            $warnLabel.Size = New-Object System.Drawing.Size(580, 30)
            $warnLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)
            $warnLabel.ForeColor = [System.Drawing.Color]::DarkOrange
            $warnLabel.Text = $tweak.WarnMessage
            $tweakPanel.Controls.Add($warnLabel)
            $yPos += 35
        }
        
        if ($tweak.RiskLevel -eq "DANGEROUS" -and $tweak.DangerMessage) {
            $dangerLabel = New-Object System.Windows.Forms.Label
            $dangerLabel.Location = New-Object System.Drawing.Point(30, $yPos)
            $dangerLabel.Size = New-Object System.Drawing.Size(580, 40)
            $dangerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
            $dangerLabel.ForeColor = [System.Drawing.Color]::Red
            $dangerLabel.Text = $tweak.DangerMessage
            $tweakPanel.Controls.Add($dangerLabel)
            $yPos += 45
        }
        
        # Changes details
        $changesText = "Registry changes:"
        foreach ($change in $tweak.Changes) {
            $changesText += "`n  • $($tweak.RegistryPath)\$($change.Name) = $($change.Value)"
        }
        
        $changesLabel = New-Object System.Windows.Forms.Label
        $changesLabel.Location = New-Object System.Drawing.Point(30, $yPos)
        $changesLabel.Size = New-Object System.Drawing.Size(580, ($tweak.Changes.Count * 15) + 15)
        $changesLabel.Font = New-Object System.Drawing.Font("Consolas", 7)
        $changesLabel.ForeColor = [System.Drawing.Color]::Gray
        $changesLabel.Text = $changesText
        $tweakPanel.Controls.Add($changesLabel)
        $yPos += ($tweak.Changes.Count * 15) + 25
        
        # Separator
        $separator = New-Object System.Windows.Forms.Label
        $separator.Location = New-Object System.Drawing.Point(10, $yPos)
        $separator.Size = New-Object System.Drawing.Size(600, 2)
        $separator.BorderStyle = "Fixed3D"
        $tweakPanel.Controls.Add($separator)
        $yPos += 15
    }
    
    # Disclaimer at bottom
    $disclaimer = New-Object System.Windows.Forms.Label
    $disclaimer.Location = New-Object System.Drawing.Point(20, 480)
    $disclaimer.Size = New-Object System.Drawing.Size(650, 40)
    $disclaimer.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)
    $disclaimer.ForeColor = [System.Drawing.Color]::Gray
    $disclaimer.Text = "⚠️ All changes are reversible via 'Restore Backup' feature. A backup will be created automatically.`nYou apply these optimizations at your own risk. See SECURITY.md for details."
    $dialog.Controls.Add($disclaimer)
    
    # Buttons
    $applyButton = New-Object System.Windows.Forms.Button
    $applyButton.Location = New-Object System.Drawing.Point(450, 530)
    $applyButton.Size = New-Object System.Drawing.Size(100, 30)
    $applyButton.Text = "Apply Selected"
    $applyButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $applyButton.BackColor = [System.Drawing.Color]::LimeGreen
    $applyButton.Add_Click({
            $dialog.Tag = @{
                Approved       = $true
                SelectedTweaks = ($checkboxes | Where-Object { $_.Checked }).Tag
            }
            $dialog.Close()
        })
    $dialog.Controls.Add($applyButton)
    
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(560, 530)
    $cancelButton.Size = New-Object System.Drawing.Size(100, 30)
    $cancelButton.Text = "Cancel"
    $cancelButton.Add_Click({
            $dialog.Tag = @{ Approved = $false }
            $dialog.Close()
        })
    $dialog.Controls.Add($cancelButton)
    
    # Show dialog
    $dialog.ShowDialog() | Out-Null
    
    return $dialog.Tag
}

function Request-GameOptimizationConsent {
    <#
    .SYNOPSIS
        Asks user if they want to optimize for detected game
    
    .PARAMETER GameName
        Name of detected game
    
    .PARAMETER RecommendedProfile
        Suggested optimization profile
    
    .OUTPUTS
        @{ Proceed = $true/$false; ProfileName = "..." }
    #>
    
    param(
        [string]$GameName,
        [string]$RecommendedProfile
    )
    
    # Simple yes/no dialog
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Detected: $GameName`n`nApply recommended profile: $RecommendedProfile?`n`n(You will review all changes before they are applied)",
        "Alphacode GameBoost - Game Detected",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        return @{
            Proceed     = $true
            ProfileName = $RecommendedProfile
        }
    }
    else {
        return @{ Proceed = $false }
    }
}

function Show-DangerousTweakWarning {
    <#
    .SYNOPSIS
        Shows explicit warning for dangerous tweaks (requires typed confirmation)
    
    .PARAMETER Tweak
        Dangerous tweak object
    
    .OUTPUTS
        $true if user explicitly consents, $false otherwise
    #>
    
    param([hashtable]$Tweak)
    
    $warningDialog = New-Object System.Windows.Forms.Form
    $warningDialog.Text = "⚠️ DANGEROUS TWEAK - Explicit Consent Required"
    $warningDialog.Size = New-Object System.Drawing.Size(500, 350)
    $warningDialog.StartPosition = "CenterScreen"
    $warningDialog.FormBorderStyle = "FixedDialog"
    $warningDialog.BackColor = [System.Drawing.Color]::FromArgb(40, 0, 0)  # Dark red
    
    # Warning icon
    $iconLabel = New-Object System.Windows.Forms.Label
    $iconLabel.Location = New-Object System.Drawing.Point(20, 20)
    $iconLabel.Size = New-Object System.Drawing.Size(60, 60)
    $iconLabel.Font = New-Object System.Drawing.Font("Segoe UI", 36)
    $iconLabel.Text = "🚨"
    $iconLabel.ForeColor = [System.Drawing.Color]::Red
    $warningDialog.Controls.Add($iconLabel)
    
    # Tweak name
    $nameLabel = New-Object System.Windows.Forms.Label
    $nameLabel.Location = New-Object System.Drawing.Point(90, 20)
    $nameLabel.Size = New-Object System.Drawing.Size(380, 30)
    $nameLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $nameLabel.ForeColor = [System.Drawing.Color]::White
    $nameLabel.Text = $Tweak.Name
    $warningDialog.Controls.Add($nameLabel)
    
    # Danger message
    $dangerText = New-Object System.Windows.Forms.TextBox
    $dangerText.Location = New-Object System.Drawing.Point(20, 90)
    $dangerText.Size = New-Object System.Drawing.Size(450, 120)
    $dangerText.Multiline = $true
    $dangerText.ReadOnly = $true
    $dangerText.BackColor = [System.Drawing.Color]::Black
    $dangerText.ForeColor = [System.Drawing.Color]::Yellow
    $dangerText.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
    $dangerText.Text = @"
$($Tweak.DangerMessage)

WHAT IT DOES:
$($Tweak.Description)

SIDE EFFECTS:
$($Tweak.SideEffects)

This tweak is NOT RECOMMENDED for most users.
Only proceed if you fully understand the risks.
"@
    $warningDialog.Controls.Add($dangerText)
    
    # Typed confirmation
    $confirmLabel = New-Object System.Windows.Forms.Label
    $confirmLabel.Location = New-Object System.Drawing.Point(20, 220)
    $confirmLabel.Size = New-Object System.Drawing.Size(450, 20)
    $confirmLabel.ForeColor = [System.Drawing.Color]::White
    $confirmLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $confirmLabel.Text = "Type 'I UNDERSTAND THE RISKS' to proceed:"
    $warningDialog.Controls.Add($confirmLabel)
    
    $confirmTextbox = New-Object System.Windows.Forms.TextBox
    $confirmTextbox.Location = New-Object System.Drawing.Point(20, 245)
    $confirmTextbox.Size = New-Object System.Drawing.Size(450, 25)
    $confirmTextbox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $warningDialog.Controls.Add($confirmTextbox)
    
    # Continue button (disabled until typed)
    $continueButton = New-Object System.Windows.Forms.Button
    $continueButton.Location = New-Object System.Drawing.Point(260, 280)
    $continueButton.Size = New-Object System.Drawing.Size(100, 30)
    $continueButton.Text = "Continue"
    $continueButton.Enabled = $false
    $continueButton.Add_Click({
            $warningDialog.Tag = $true
            $warningDialog.Close()
        })
    $warningDialog.Controls.Add($continueButton)
    
    # Cancel button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(370, 280)
    $cancelButton.Size = New-Object System.Drawing.Size(100, 30)
    $cancelButton.Text = "Cancel"
    $cancelButton.Add_Click({
            $warningDialog.Tag = $false
            $warningDialog.Close()
        })
    $warningDialog.Controls.Add($cancelButton)
    
    # Enable button when text matches
    $confirmTextbox.Add_TextChanged({
            $continueButton.Enabled = ($confirmTextbox.Text -eq "I UNDERSTAND THE RISKS")
        })
    
    $warningDialog.ShowDialog() | Out-Null
    
    return $warningDialog.Tag -eq $true
}

# Export functions
Export-ModuleMember -Function Show-TweakConsentDialog, Request-GameOptimizationConsent, Show-DangerousTweakWarning
