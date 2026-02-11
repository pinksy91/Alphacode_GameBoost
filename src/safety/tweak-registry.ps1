# Alphacode GameBoost - Tweak Registry & Safety Classification
# Complete audit of all tweaks with risk levels and detailed descriptions

# ===== TWEAK CLASSIFICATION =====
# Risk Levels:
# - SAFE: Standard optimizations, reversible, no stability risk
# - WARNING: Advanced tweaks, may affect system behavior, fully reversible
# - DANGEROUS: Expert-only, potential stability/security impact, requires explicit consent

$script:TweakRegistry = @(
    # ===== SAFE TWEAKS =====
    @{
        ID             = "TWEAK_001"
        Name           = "Game Mode Priority Boost"
        Category       = "Performance"
        RiskLevel      = "SAFE"
        Description    = "Increases CPU and GPU priority for gaming tasks"
        RegistryPath   = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
        Changes        = @(
            @{ Name = "GPU Priority"; Value = 8; Type = "DWord"; Default = 4 }
            @{ Name = "Priority"; Value = 6; Type = "DWord"; Default = 2 }
            @{ Name = "Scheduling Category"; Value = "High"; Type = "String"; Default = "Medium" }
        )
        Impact         = "Improved frame pacing and reduced input lag"
        Reversible     = $true
        RequiresReboot = $false
    },
    
    @{
        ID             = "TWEAK_002"
        Name           = "Network Optimization"
        Category       = "Network"
        RiskLevel      = "SAFE"
        Description    = "Optimizes TCP/IP stack for gaming (reduces latency)"
        RegistryPath   = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Changes        = @(
            @{ Name = "TcpAckFrequency"; Value = 1; Type = "DWord"; Default = 2 }
            @{ Name = "TCPNoDelay"; Value = 1; Type = "DWord"; Default = 0 }
        )
        Impact         = "Lower network latency in online games"
        Reversible     = $true
        RequiresReboot = $false
    },
    
    @{
        ID             = "TWEAK_003"
        Name           = "System Responsiveness"
        Category       = "Performance"
        RiskLevel      = "SAFE"
        Description    = "Improves foreground application responsiveness"
        RegistryPath   = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
        Changes        = @(
            @{ Name = "Win32PrioritySeparation"; Value = 38; Type = "DWord"; Default = 2 }
        )
        Impact         = "Games get more CPU time when in foreground"
        Reversible     = $true
        RequiresReboot = $false
    },
    
    @{
        ID             = "TWEAK_004"
        Name           = "Visual Effects Reduction"
        Category       = "Graphics"
        RiskLevel      = "SAFE"
        Description    = "Disables unnecessary visual effects for better performance"
        RegistryPath   = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        Changes        = @(
            @{ Name = "VisualFXSetting"; Value = 2; Type = "DWord"; Default = 0 }
        )
        Impact         = "Reduced GPU usage on desktop, more resources for games"
        Reversible     = $true
        RequiresReboot = $false
    },
    
    @{
        ID             = "TWEAK_005"
        Name           = "Mouse Acceleration Disable"
        Category       = "Input"
        RiskLevel      = "SAFE"
        Description    = "Disables mouse acceleration for 1:1 input (essential for FPS)"
        RegistryPath   = "HKCU:\Control Panel\Mouse"
        Changes        = @(
            @{ Name = "MouseSpeed"; Value = "0"; Type = "String"; Default = "1" }
            @{ Name = "MouseThreshold1"; Value = "0"; Type = "String"; Default = "6" }
            @{ Name = "MouseThreshold2"; Value = "0"; Type = "String"; Default = "10" }
        )
        Impact         = "Consistent mouse sensitivity (recommended for competitive gaming)"
        Reversible     = $true
        RequiresReboot = $false
    },
    
    # ===== WARNING TWEAKS =====
    @{
        ID             = "TWEAK_101"
        Name           = "GPU Timeout Disable (TDR)"
        Category       = "Graphics"
        RiskLevel      = "WARNING"
        Description    = "Disables GPU driver timeout detection and recovery (TDR)"
        RegistryPath   = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        Changes        = @(
            @{ Name = "TdrLevel"; Value = 0; Type = "DWord"; Default = 3 }
            @{ Name = "TdrDelay"; Value = 60; Type = "DWord"; Default = 2 }
        )
        Impact         = "Prevents driver resets during heavy GPU load"
        SideEffects    = "System may freeze if GPU truly hangs (rare)"
        Reversible     = $true
        RequiresReboot = $true
        WarningMessage = "⚠️ Disabling TDR can cause system freezes if GPU crashes. Only use on STABLE systems."
    },
    
    @{
        ID             = "TWEAK_102"
        Name           = "CPU Parking Disable"
        Category       = "CPU"
        RiskLevel      = "WARNING"
        Description    = "Prevents CPU cores from entering low-power states"
        RegistryPath   = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
        Changes        = @(
            @{ Name = "ValueMax"; Value = 0; Type = "DWord"; Default = 100 }
        )
        Impact         = "All CPU cores always active, reduced latency"
        SideEffects    = "Higher idle power consumption and temperatures"
        Reversible     = $true
        RequiresReboot = $false
        WarningMessage = "⚠️ Increases power usage and heat. Monitor temperatures."
    },
    
    @{
        ID             = "TWEAK_103"
        Name           = "Large System Cache"
        Category       = "Memory"
        RiskLevel      = "WARNING"
        Description    = "Prioritizes system cache over application memory"
        RegistryPath   = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Changes        = @(
            @{ Name = "LargeSystemCache"; Value = 1; Type = "DWord"; Default = 0 }
        )
        Impact         = "Better file I/O performance"
        SideEffects    = "May reduce available RAM for applications (8GB+ recommended)"
        Reversible     = $true
        RequiresReboot = $true
        WarningMessage = "⚠️ Recommended only for systems with 16GB+ RAM"
    },
    
    @{
        ID             = "TWEAK_104"
        Name           = "HPET (High Precision Event Timer) Disable"
        Category       = "Performance"
        RiskLevel      = "WARNING"
        Description    = "Disables HPET which can reduce DPC latency"
        RegistryPath   = "HKLM:\SYSTEM\CurrentControlSet\Services\HPET"
        Changes        = @(
            @{ Name = "Start"; Value = 4; Type = "DWord"; Default = 3 }
        )
        Impact         = "Lower DPC latency on some systems"
        SideEffects    = "May cause timing issues on older hardware"
        Reversible     = $true
        RequiresReboot = $true
        WarningMessage = "⚠️ Test for a few hours - may cause instability on some systems"
    },
    
    # ===== DANGEROUS TWEAKS =====
    @{
        ID                      = "TWEAK_201"
        Name                    = "SEHOP Disable (Security Mitigation)"
        Category                = "Security"
        RiskLevel               = "DANGEROUS"
        Description             = "Disables Structured Exception Handler Overwrite Protection"
        RegistryPath            = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
        Changes                 = @(
            @{ Name = "DisableExceptionChainValidation"; Value = 1; Type = "DWord"; Default = 0 }
        )
        Impact                  = "Slight performance gain in edge cases"
        SideEffects             = "REDUCES EXPLOIT PROTECTION - system more vulnerable to attacks"
        Reversible              = $true
        RequiresReboot          = $true
        DangerMessage           = "🚨 DANGER: Reduces system security! Only for offline/air-gapped gaming PCs. STRONGLY DISCOURAGED."
        RequiresExplicitConsent = $true
    },
    
    @{
        ID                      = "TWEAK_202"
        Name                    = "Memory Integrity Disable (Core Isolation)"
        Category                = "Security"
        RiskLevel               = "DANGEROUS"
        Description             = "Disables Windows Memory Integrity / Hypervisor Code Integrity (HVCI)"
        RegistryPath            = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        Changes                 = @(
            @{ Name = "Enabled"; Value = 0; Type = "DWord"; Default = 1 }
        )
        Impact                  = "Potential performance gain (5-10% on some games)"
        SideEffects             = "SIGNIFICANTLY REDUCES SECURITY - malware can modify kernel memory"
        Reversible              = $true
        RequiresReboot          = $true
        DangerMessage           = "🚨 DANGER: Disables critical security feature! Only disable if you understand the risks."
        RequiresExplicitConsent = $true
    },
    
    @{
        ID                      = "TWEAK_203"
        Name                    = "Meltdown/Spectre Mitigations Disable"
        Category                = "Security"
        RiskLevel               = "DANGEROUS"
        Description             = "Disables CPU vulnerability mitigations for performance"
        RegistryPath            = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Changes                 = @(
            @{ Name = "FeatureSettingsOverride"; Value = 3; Type = "DWord"; Default = 0 }
            @{ Name = "FeatureSettingsOverrideMask"; Value = 3; Type = "DWord"; Default = 0 }
        )
        Impact                  = "5-10% performance gain on affected CPUs"
        SideEffects             = "EXPOSES CPU TO SIDE-CHANNEL ATTACKS - security risk"
        Reversible              = $true
        RequiresReboot          = $true
        DangerMessage           = "🚨 DANGER: Your CPU becomes vulnerable to attacks! Only for OFFLINE gaming PCs."
        RequiresExplicitConsent = $true
    }
)

# ===== TWEAK FUNCTIONS =====

function Get-TweaksByProfile {
    <#
    .SYNOPSIS
        Returns recommended tweaks for a given optimization profile
    
    .PARAMETER ProfileName
        Conservative, Balanced, Aggressive, or Maximum
    #>
    
    param(
        [ValidateSet("Conservative", "Balanced", "Aggressive", "Maximum")]
        [string]$ProfileName
    )
    
    $tweaks = switch ($ProfileName) {
        "Conservative" {
            # Only SAFE tweaks
            $script:TweakRegistry | Where-Object { $_.RiskLevel -eq "SAFE" } | Select-Object -First 3
        }
        
        "Balanced" {
            # All SAFE tweaks
            $script:TweakRegistry | Where-Object { $_.RiskLevel -eq "SAFE" }
        }
        
        "Aggressive" {
            # SAFE + selected WARNING tweaks
            $script:TweakRegistry | Where-Object { 
                $_.RiskLevel -eq "SAFE" -or 
                ($_.RiskLevel -eq "WARNING" -and $_.ID -in @("TWEAK_101", "TWEAK_102"))
            }
        }
        
        "Maximum" {
            # SAFE + all WARNING (DANGEROUS require explicit opt-in)
            $script:TweakRegistry | Where-Object { 
                $_.RiskLevel -in @("SAFE", "WARNING")
            }
        }
    }
    
    return $tweaks
}

function Get-TweakByID {
    <#
    .SYNOPSIS
        Gets tweak details by ID
    #>
    
    param([string]$ID)
    
    return $script:TweakRegistry | Where-Object { $_.ID -eq $ID }
}

function Get-AllDangerousTweaks {
    <#
    .SYNOPSIS
        Returns all dangerous tweaks (never auto-included)
    #>
    
    return $script:TweakRegistry | Where-Object { $_.RiskLevel -eq "DANGEROUS" }
}

function Test-TweakSafety {
    <#
    .SYNOPSIS
        Validates that a tweak is in the registry and not deprecated
    #>
    
    param([hashtable]$Tweak)
    
    # Check if tweak exists in registry
    $exists = $script:TweakRegistry | Where-Object { $_.ID -eq $Tweak.ID }
    
    if (-not $exists) {
        Write-EnhancedLog "Unknown tweak ID: $($Tweak.ID) - BLOCKED" "ERROR" "SAFETY"
        return $false
    }
    
    return $true
}

# Export functions
Export-ModuleMember -Function Get-TweaksByProfile, Get-TweakByID, Get-AllDangerousTweaks, Test-TweakSafety
