Describe "Test PSDesiredStateConfiguration" -tags CI {
    Context "Module loading" {
        BeforeAll {
            $commands = Get-Command -Module PSDesiredStateConfiguration
            $expectedCommandCount = 4
        }
        BeforeEach {
        }
        AfterEach {
        }
        AfterAll {
        }

        It "The module should have $expectedCommandCount commands" {
            if($commands.Count -ne $expectedCommandCount)
            {
                $modulePath = (Get-Module PSDesiredStateConfiguration).Path
                Write-Verbose -Verbose -Message "PSDesiredStateConfiguration Path: $modulePath"
                $commands | Out-String | Write-Verbose -Verbose
            }
            $commands.Count | Should -Be $expectedCommandCount
        }
        It "The module should have the Configuration Command" {
            $commands | Where-Object {$_.Name -eq 'Configuration'} | Should -Not -BeNullOrEmpty
        }
        It "The module should have the Get-DscResource Command" {
            $commands | Where-Object {$_.Name -eq 'Get-DscResource'} | Should -Not -BeNullOrEmpty
        }
    }
    Context "Get-DscResource" {
        # https://github.com/PowerShell/PSDesiredStateConfiguration/issues/11
        BeforeAll {
            $testCases = @(
                @{
                    TestCaseName = 'case mismatch in resource name'
                    Name = 'PsModule'
                    ModuleName = 'PowerShellGet'
                }
                @{
                    TestCaseName = 'Both names have matching case'
                    Name = 'PSModule'
                    ModuleName = 'PowerShellGet'
                }
                @{
                    TestCaseName = 'case mismatch in module name'
                    Name = 'PSModule'
                    ModuleName = 'powershellget'
                    PendingBecause = 'Broken everywhere'
                }
            )

        }
        it "should be able to get a <Name> - <TestCaseName>" -TestCases $testCases -Pending:($IsWindows -or $IsLinux)  {
            param($Name)
            $resource = Get-DscResource -Name $name
            $resource | Should -Not -BeNullOrEmpty
        }

        # Linux issue: https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12
        # macOS issue: https://github.com/PowerShell/MMI/issues/33
        it "should be able to get a <Name> from <ModuleName> - <TestCaseName>" -TestCases $testCases -Pending:($IsLinux)  {
            param($Name,$ModuleName, $PendingBecause)
            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $Because
            }
            $resource = Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
        }
        # Fails on on platforms
        it "should throw when resource is not found" -Pending {
            {
                Get-DscResource -Name antoehusatnoheusntahoesnuthao -Module tanshoeusnthaosnetuhasntoheusnathoseun
            } |
                Should -Throw -ErrorId 'Microsoft.PowerShell.Commands.WriteErrorException,CheckResourceFound'
        }
    }
    Context "Invoke-DscResource" {
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
            $module = Get-InstalledModule -Name PsDscResources -ErrorAction Ignore
            if($module)
            {
                Write-Verbose "removing PSDscResources, tests will re-install..." -Verbose
                Uninstall-Module -Name PsDscResources -AllVersions -Force
            }
        }
        AfterAll {
            $Global:ProgressPreference = $origProgress
        }
        Context "mof resources"  {
            it "Set method should work" {
                if(!$IsLinux)
                {
                    $result  = Invoke-DscResource -Name PSModule -Module PowerShellGet -Method set -Properties @{
                        Name = 'PsDscResources'
                        InstallationPolicy = 'Trusted'
                    }
                }
                else
                {
                    Install-Module -Name PsDscResources -Force
                    # being fixed in https://github.com/PowerShell/PowerShellGet/pull/521
                    set-ItResult -Pending -Because "PowerShellGet resources don't currently work on Linux"
                }
                $module = Get-module PsDscResources -ListAvailable
                $module | Should -Not -BeNullOrEmpty -Because "Resource should have installed module"
            }
            it "Test method should return false" {
                $result  = Invoke-DscResource -Name Script -Module PSDscResources -Method Test -Properties @{TestScript = {Write-Output 'test';return $false};GetScript = {return @{}}; SetScript = {return}}
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeFalse -Because "Test method return false"
            }
            it "Test method should return true" {
                $result  = Invoke-DscResource -Name Script -Module PSDscResources -Method Test -Properties @{TestScript = {Write-Host 'test';return $true};GetScript = {return @{}}; SetScript = {return}}
                $result | Should -BeTrue -Because "Test method return true"
            }
            it "Test method should return true with moduleSpecification" {
                $module = get-module PsDscResources -ListAvailable
                $moduleSpecification = @{ModuleName=$module.Name;ModuleVersion=$module.Version.ToString()}
                $result  = Invoke-DscResource -Name Script -Module $moduleSpecification -Method Test -Properties @{TestScript = {Write-Host 'test';return $true};GetScript = {return @{}}; SetScript = {return}}
                $result | Should -BeTrue -Because "Test method return true"
            }
            it "Invalid moduleSpecification" {
                $moduleSpecification = @{ModuleName='PsDscResources';ModuleVersion='99.99.99.993'}
                {
                    Invoke-DscResource -Name Script -Module $moduleSpecification -Method Test -Properties @{TestScript = {Write-Host 'test';return $true};GetScript = {return @{}}; SetScript = {return}} -ErrorAction Stop
                } |
                    Should -Throw -ErrorId 'InvalidResourceSpecification,Invoke-DscResource' -ExpectedMessage 'Invalid Resource Name ''Script'' or module specification.'
            }

            # waiting on Get-DscResource to be fixed
            it "Invalid module name" -Pending {
                {
                    Invoke-DscResource -Name Script -Module santoheusnaasonteuhsantoheu -Method Test -Properties @{TestScript = {Write-Host 'test';return $true};GetScript = {return @{}}; SetScript = {return}} -ErrorAction Stop
                } |
                    Should -Throw -ErrorId 'Microsoft.PowerShell.Commands.WriteErrorException,CheckResourceFound'
            }
            # waiting on Get-DscResource to be fixed
            it "Invalid resource name" -Pending {
                {
                    Invoke-DscResource -Name santoheusnaasonteuhsantoheu -Method Test -Properties @{TestScript = {Write-Host 'test';return $true};GetScript = {return @{}}; SetScript = {return}} -ErrorAction Stop
                } |
                    Should -Throw -ErrorId 'Microsoft.PowerShell.Commands.WriteErrorException,CheckResourceFound'
            }

            # being fixed in https://github.com/PowerShell/PowerShellGet/pull/521
            it "Get method should work" -Pending:($IsLinux) {
                $result  = Invoke-DscResource -Name PSModule -Module PowerShellGet -Method Get -Properties @{ Name = 'PsDscResources'}
                $result.Author | Should -BeLike 'Microsoft*'
                $result.InstallationPolicy | Should -BeOfType [string]
                $result.Guid | Should -BeOfType [Guid]
                $result.Ensure | Should -Be 'Present'
                $result.Name | Should -be 'PsDscResources'
                $result.Description | Should -BeLike 'This*DSC*'
                $result.InstalledVersion | should -BeOfType [Version]
                $result.ModuleBase | Should -BeLike '*PSDscResources*'
                $result.Repository | should -BeOfType [string]
                $result.ModuleType | Should -Be 'Manifest'
            }
        }
    }
}
