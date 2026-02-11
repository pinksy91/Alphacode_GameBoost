# Alphacode GameBoost - Tweak Applicator
# Safely applies user-approved tweaks with full audit trail

. "$PSScriptRoot\tweak-registry.ps1"
. "$PSScriptRoot\..\..\..\modules\FPS_Suite_ScanUltimate_AI.ps1"  # For Set-SafeItemProperty

function Apply-ApprovedTweaks {
    <#
    .SYNOPSIS
        Applies only user-approved tweaks with full safety checks
    
    .PARAMETER Tweaks
        Array of approved tweak objects
    
    .PARAMETER ProfileName
        Name of profile (for logging)
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [array]$Tweaks,
        
        [string]$ProfileName = "Custom"
    )
    
    Write-EnhancedLog "═══════════════════════════════════════════" "INFO" "TWEAK_APPLY"
    Write-EnhancedLog "  Applying $($Tweaks.Count) Approved Tweaks" "INFO" "TWEAK_APPLY"
    Write-EnhancedLog "  Profile: $ProfileName" "INFO" "TWEAK_APPLY"
    Write-EnhancedLog "═══════════════════════════════════════════" "INFO" "TWEAK_APPLY"
    
    $successCount = 0
    $failedCount = 0
    
    try {
        # Create backup first
        $backupName = "pre_$($ProfileName)_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-EnhancedLog "Creating backup: $backupName" "INFO" "TWEAK_APPLY"
        Create-EnterpriseBackup -BackupName $backupName -Description "Before applying $ProfileName profile"
        
        foreach ($tweak in $Tweaks) {
            Write-EnhancedLog "Applying: $($tweak.Name) [$($tweak.RiskLevel)]" "INFO" "TWEAK_APPLY"
            
            # Safety verification
            if (-not (Test-TweakSafety -Tweak $tweak)) {
                Write-EnhancedLog "Safety check failed for $($tweak.ID) - SKIPPED" "ERROR" "TWEAK_APPLY"
                $failedCount++
                continue
            }
            
            # Apply each registry change
            $tweakSuccess = $true
            foreach ($change in $tweak.Changes) {
                $fullPath = $tweak.RegistryPath
                
                $result = Set-SafeItemProperty -Path $fullPath `
                    -Name $change.Name `
                    -Value $change.Value `
                    -Type $change.Type
                
                if (-not $result) {
                    Write-EnhancedLog "Failed to apply change: $fullPath\$($change.Name)" "ERROR" "TWEAK_APPLY"
                    $tweakSuccess = $false
                    break
                }
            }
            
            if ($tweakSuccess) {
                $successCount++
                Write-EnhancedLog "✓ $($tweak.Name) applied successfully" "SUCCESS" "TWEAK_APPLY"
            }
            else {
                $failedCount++
            }
        }
        
        # Save applied tweaks to config for audit trail
        $appliedTweaksAudit = @{
            Timestamp     = Get-Date
            ProfileName   = $ProfileName
            TweaksApplied = $Tweaks | ForEach-Object {
                @{
                    ID        = $_.ID
                    Name      = $_.Name
                    RiskLevel = $_.RiskLevel
                }
            }
            BackupName    = $backupName
        }
        
        # Append to audit log
        $auditPath = "$global:ConfigPath\tweak_audit.jsonl"
        $appliedTweaksAudit | ConvertTo-Json -Compress | Add-Content $auditPath -Encoding UTF8
        
        Write-EnhancedLog "═══════════════════════════════════════════" "SUCCESS" "TWEAK_APPLY"
        Write-EnhancedLog "  ✓ $successCount tweaks applied" "SUCCESS" "TWEAK_APPLY"
        if ($failedCount -gt 0) {
            Write-EnhancedLog "  ✗ $failedCount tweaks failed" "ERROR" "TWEAK_APPLY"
        }
        Write-EnhancedLog "  Backup: $backupName" "INFO" "TWEAK_APPLY"
        Write-EnhancedLog "═══════════════════════════════════════════" "SUCCESS" "TWEAK_APPLY"
        
        # Update configuration
        Set-Configuration -Key "LastAppliedProfile" -Value $ProfileName
        Set-Configuration -Key "LastAppliedTimestamp" -Value (Get-Date).ToString()
        Save-Configuration (Get-Configuration)
        
        # Update tray icon
        Update-TrayIconProfile -ProfileName $ProfileName
        
        # Clear rollback stack (changes were intentional)
        Clear-RegistryBackupStack
        
        return @{
            Success      = ($failedCount -eq 0)
            SuccessCount = $successCount
            FailedCount  = $failedCount
            BackupName   = $backupName
        }
        
    }
    catch {
        Write-EnhancedLog "Critical error during tweak application: $($_.Exception.Message)" "ERROR" "TWEAK_APPLY"
        
        # Automatic rollback
        Write-EnhancedLog "Initiating automatic rollback..." "WARN" "TWEAK_APPLY"
        Invoke-RegistryRollback
        
        return @{
            Success = $false
            Error   = $_.Exception.Message
        }
    }
}

# Export functions
Export-ModuleMember -Function Apply-ApprovedTweaks
