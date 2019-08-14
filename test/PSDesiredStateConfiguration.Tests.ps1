Describe "Test PSDesiredStateConfiguration" -tags CI {
    Context "Module loading" {
        BeforeAll {
            $commands = Get-Command -Module PSDesiredStateConfiguration
            $expectedCommandCount = 3
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
}

