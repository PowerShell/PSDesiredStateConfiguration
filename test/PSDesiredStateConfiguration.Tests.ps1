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
    Context "Get-DscResource" {
        # https://github.com/PowerShell/PSDesiredStateConfiguration/issues/11
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
            Install-Module -Name XmlContentDsc -Force
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
            $classTestCases = @(
                @{
                    TestCaseName = 'Good case'
                    Name = 'XmlFileContentResource'
                    ModuleName = 'XmlContentDsc'
                    PendingBecause = 'Broken everywhere'
                }
                @{
                    TestCaseName = 'Module Name case mismatch'
                    Name = 'XmlFileContentResource'
                    ModuleName = 'xmlcontentdsc'
                    PendingBecause = 'Broken everywhere'
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
        }
        it "should be able to get script resource - <Name> - <TestCaseName>" -TestCases $testCases -Pending:($IsWindows -or $IsLinux)  {
            param($Name)
            $resource = Get-DscResource -Name $name
            $resource | Should -Not -BeNullOrEmpty
        }

        # Linux issue: https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12
        # macOS issue: https://github.com/PowerShell/MMI/issues/33
        it "should be able to get script resource - <Name> from <ModuleName> - <TestCaseName>" -TestCases $testCases -Pending:($IsLinux)  {
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

        it "should be able to get class resource - <Name> from <ModuleName> - <TestCaseName>" -TestCases $classTestCases -Pending:($IsLinux -or $IsMacOs) {
            param($Name,$ModuleName, $PendingBecause)
            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $Because
            }
            $resource = Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
        }

        it "should be able to get class resource - <Name> - <TestCaseName>" -TestCases $classTestCases -Pending:($IsLinux -or $IsMacOs) {
            param($Name,$ModuleName, $PendingBecause)
            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $Because
            }
            $resource = Get-DscResource -Name $Name
            $resource | Should -Not -BeNullOrEmpty
        }
    }
}
