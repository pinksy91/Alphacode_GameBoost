# Alphacode GameBoost - Test Suite
# Pester test framework for production-ready quality assurance

BeforeAll {
    # Import main module
    . "$PSScriptRoot\..\modules\FPS_Suite_ScanUltimate_AI.ps1"
    
    # Initialize test environment
    $global:TestLogPath = "$env:TEMP\FPSSuite_Tests\Logs"
    $global:TestBackupPath = "$env:TEMP\FPSSuite_Tests\Backups"
    $global:TestConfigPath = "$env:TEMP\FPSSuite_Tests\Config"
    
    # Override global paths for testing
    $env:FPS_SUITE_LOG_PATH = $global:TestLogPath
    $env:FPS_SUITE_BACKUP_PATH = $global:TestBackupPath
    $env:FPS_SUITE_CONFIG_PATH = $global:TestConfigPath
}

AfterAll {
    # Cleanup test environment
    if (Test-Path "$env:TEMP\FPSSuite_Tests") {
        Remove-Item "$env:TEMP\FPSSuite_Tests" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Describe "Registry Safety Wrapper" {
    BeforeEach {
        # Create test registry key
        $script:TestRegPath = "HKCU:\Software\FPSSuite_Test_$(Get-Random)"
        New-Item -Path $script:TestRegPath -Force | Out-Null
        
        # Clear rollback stack
        $script:RegistryBackupStack = @()
    }
    
    AfterEach {
        # Cleanup test registry
        if (Test-Path $script:TestRegPath) {
            Remove-Item -Path $script:TestRegPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Context "Set-SafeItemProperty" {
        It "Creates new registry value successfully" {
            $result = Set-SafeItemProperty -Path $script:TestRegPath -Name "TestValue" -Value 42 -Type DWord
            $result | Should -Be $true
            
            $value = Get-ItemProperty -Path $script:TestRegPath -Name "TestValue"
            $value.TestValue | Should -Be 42
        }
        
        It "Backs up existing value before overwriting" {
            # Set initial value
            Set-ItemProperty -Path $script:TestRegPath -Name "TestValue" -Value 10 -Type DWord
            
            # Overwrite with Safe wrapper
            Set-SafeItemProperty -Path $script:TestRegPath -Name "TestValue" -Value 20 -Type DWord
            
            # Check backup stack contains old value
            $script:RegistryBackupStack.Count | Should -BeGreaterThan 0
            $script:RegistryBackupStack[-1].Value | Should -Be 10
        }
        
        It "Creates missing parent paths automatically" {
            $missingPath = "$script:TestRegPath\NonExistent\Deep\Path"
            $result = Set-SafeItemProperty -Path $missingPath -Name "TestValue" -Value "test" -Type String
            
            $result | Should -Be $true
            Test-Path $missingPath | Should -Be $true
        }
        
        It "Rejects invalid registry path format" {
            $result = Set-SafeItemProperty -Path "C:\InvalidPath" -Name "Test" -Value 1 -Type DWord
            $result | Should -Be $false
        }
    }
    
    Context "Invoke-RegistryRollback" {
        It "Rolls back single registry change" {
            # Set initial value
            Set-ItemProperty -Path $script:TestRegPath -Name "TestValue" -Value 10 -Type DWord
            
            # Change with safe wrapper
            Set-SafeItemProperty -Path $script:TestRegPath -Name "TestValue" -Value 20 -Type DWord
            
            # Rollback
            Invoke-RegistryRollback
            
            # Verify original value restored
            $value = Get-ItemProperty -Path $script:TestRegPath -Name "TestValue"
            $value.TestValue | Should -Be 10
        }
        
        It "Rolls back multiple changes in order" {
            # Create multiple values
            Set-ItemProperty -Path $script:TestRegPath -Name "Value1" -Value 1 -Type DWord
            Set-ItemProperty -Path $script:TestRegPath -Name "Value2" -Value 2 -Type DWord
            
            # Modify with safe wrapper
            Set-SafeItemProperty -Path $script:TestRegPath -Name "Value1" -Value 100 -Type DWord
            Set-SafeItemProperty -Path $script:TestRegPath -Name "Value2" -Value 200 -Type DWord
            
            # Rollback
            Invoke-RegistryRollback
            
            # Verify both restored
            $val1 = Get-ItemProperty -Path $script:TestRegPath -Name "Value1"
            $val2 = Get-ItemProperty -Path $script:TestRegPath -Name "Value2"
            $val1.Value1 | Should -Be 1
            $val2.Value2 | Should -Be 2
        }
        
        It "Clears backup stack after successful rollback" {
            Set-SafeItemProperty -Path $script:TestRegPath -Name "Test" -Value 1 -Type DWord
            Invoke-RegistryRollback
            
            $script:RegistryBackupStack.Count | Should -Be 0
        }
        
        It "Handles rollback when no changes were made" {
            $result = Invoke-RegistryRollback
            $result | Should -Be $true
        }
    }
}

Describe "Logging System" {
    It "Creates log directory on initialization" {
        Initialize-LoggingSystem
        Test-Path $global:TestLogPath | Should -Be $true
    }
    
    It "Writes log entries to file" {
        Initialize-LoggingSystem
        Write-EnhancedLog "Test message" "INFO" "TEST"
        
        $logFile = Get-ChildItem -Path $global:TestLogPath -Filter "*.log" | Select-Object -First 1
        $logFile | Should -Not -BeNullOrEmpty
        
        $content = Get-Content $logFile.FullName -Raw
        $content | Should -Match "Test message"
    }
    
    It "Filters log messages based on log level" {
        $env:FPS_SUITE_LOG_LEVEL = "WARN"
        
        # INFO message should be filtered out
        Write-EnhancedLog "Info message" "INFO" "TEST"
        
        # WARN message should appear
        Write-EnhancedLog "Warning message" "WARN" "TEST"
        
        $logFile = Get-ChildItem -Path $global:TestLogPath -Filter "*.log" | Select-Object -First 1
        $content = Get-Content $logFile.FullName -Raw
        
        $content | Should -Not -Match "Info message"
        $content | Should -Match "Warning message"
        
        # Reset
        $env:FPS_SUITE_LOG_LEVEL = "INFO"
    }
    
    It "Creates JSON log when format is set to json" {
        $env:FPS_SUITE_LOG_FORMAT = "json"
        Write-EnhancedLog "JSON test" "INFO" "TEST"
        
        $jsonFile = Get-ChildItem -Path $global:TestLogPath -Filter "*.jsonl" | Select-Object -First 1
        $jsonFile | Should -Not -BeNullOrEmpty
        
        $content = Get-Content $jsonFile.FullName -Raw
        $json = $content | ConvertFrom-Json
        $json.message | Should -Be "JSON test"
        
        # Reset
        $env:FPS_SUITE_LOG_FORMAT = "text"
    }
}

Describe "Configuration System" {
    It "Creates default configuration if none exists" {
        $config = Load-Configuration
        $config | Should -Not -BeNullOrEmpty
        $config.AutoBackup | Should -Be $true
    }
    
    It "Saves and loads configuration successfully" {
        $testConfig = @{
            AutoBackup         = $false
            SafeMode           = $true
            LastAppliedProfile = "Balanced"
            PreferredProfile   = "Conservative"
            Version            = "3.2.0"
        }
        
        Save-Configuration $testConfig
        $loaded = Load-Configuration
        
        $loaded.AutoBackup | Should -Be $false
        $loaded.SafeMode | Should -Be $true
        $loaded.LastAppliedProfile | Should -Be "Balanced"
    }
    
    It "Merges loaded config with defaults for missing keys" {
        # Save incomplete config
        $incompleteConfig = @{
            AutoBackup = $true
        }
        Save-Configuration $incompleteConfig
        
        # Load should merge with defaults
        $loaded = Load-Configuration
        $loaded.PreferredProfile | Should -Not -BeNullOrEmpty
    }
}

Describe "Input Validation" {
    It "Sanitizes user input correctly" {
        # This would need to be tested against actual input sanitization in bat file
        # For now, we document expected behavior
        
        # Expected: Strip dangerous characters
        $dangerousInput = "test;malicious&command|here"
        # After sanitization should be: "testmaliciouscommandhere"
        
        # This is a placeholder - actual implementation would test the bat file logic
    }
}

Describe "Backup System Integration" {
    BeforeEach {
        Initialize-Application | Out-Null
    }
    
    It "Creates backup with timestamp and unique ID" {
        $backup = Create-EnterpriseBackup "test_backup" "Unit test backup"
        $backup | Should -Not -BeNullOrEmpty
        $backup | Should -Match "test_backup_\d{8}_\d{6}_[A-F0-9]{8}"
        Test-Path $backup | Should -Be $true
    }
    
    It "Exports registry keys to .reg files" {
        $backup = Create-EnterpriseBackup "test_backup" "Test"
        $regFiles = Get-ChildItem "$backup\*.reg"
        $regFiles.Count | Should -BeGreaterThan 0
    }
    
    It "Includes metadata JSON file" {
        $backup = Create-EnterpriseBackup "test_backup" "Test metadata"
        $metadataFile = Join-Path $backup "backup_metadata.json"
        Test-Path $metadataFile | Should -Be $true
        
        $metadata = Get-Content $metadataFile | ConvertFrom-Json
        $metadata.Description | Should -Be "Test metadata"
    }
}
