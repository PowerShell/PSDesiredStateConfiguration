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
    Context "Get-DscResource - ScriptResources" {
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
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
                    # Linux issue: https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12
                    PendingBecause = 'https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12'
                }
            )
        }
        AfterAll {
            $Global:ProgressPreference = $origProgress
        }

        it "should be able to get <Name> - <TestCaseName>" -TestCases $testCases {
            param($Name)

            if($IsLinux -or $IsWindows)
            {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/15"
            }

            $resource = Get-DscResource -Name $name
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
        }

        it "should be able to get <Name> from <ModuleName> - <TestCaseName>" -TestCases $testCases {
            param($Name,$ModuleName, $PendingBecause)

            if($IsLinux)
            {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12"
            }

            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $PendingBecause
            }
            $resource = Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
        }

        # Fails on all platforms
        it "should throw when resource is not found" {
            Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/17"
            {
                Get-DscResource -Name antoehusatnoheusntahoesnuthao -Module tanshoeusnthaosnetuhasntoheusnathoseun
            } |
                Should -Throw -ErrorId 'Microsoft.PowerShell.Commands.WriteErrorException,CheckResourceFound'
        }
    }
    Context "Get-DscResource - Class base Resources" {

        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
            Install-Module -Name XmlContentDsc -Force
            $classTestCases = @(
                @{
                    TestCaseName = 'Good case'
                    Name = 'XmlFileContentResource'
                    ModuleName = 'XmlContentDsc'
                    PendingBecause = "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/19"
                }
                @{
                    TestCaseName = 'Module Name case mismatch'
                    Name = 'XmlFileContentResource'
                    ModuleName = 'xmlcontentdsc'
                    PendingBecause = 'https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12'
                }
                @{
                    TestCaseName = 'Resource name case mismatch'
                    Name = 'xmlfilecontentresource'
                    ModuleName = 'XmlContentDsc'
                }
            )
        }
        AfterAll {
            $Global:ProgressPreference = $origProgress
            Uninstall-Module -name XmlContentDsc -AllVersions
        }

        # Fix for most of thse are in https://github.com/PowerShell/PowerShell/pull/10350
        it "should be able to get class resource - <Name> from <ModuleName> - <TestCaseName>" -TestCases $classTestCases {
            param($Name,$ModuleName, $PendingBecause)
            if($IsLinux -or $IsMacOs)
            {
                Set-ItResult -Pending -Because "Fix for most of these are in https://github.com/PowerShell/PowerShell/pull/10350"
            }

            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $PendingBecause
            }
            $resource = Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
        }

        it "should be able to get class resource - <Name> - <TestCaseName>" -TestCases $classTestCases {
            param($Name,$ModuleName, $PendingBecause)
            Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/19"
            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $PendingBecause
            }
            $resource = Get-DscResource -Name $Name
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
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
            # Get-DscResource needs to be fixed
            it "Invalid moduleSpecification" -Pending {
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

