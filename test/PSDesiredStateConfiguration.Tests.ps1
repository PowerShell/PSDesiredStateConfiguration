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
            $testCases = @(
                @{
                    TestCaseName = 'case mismatch in resource name'
                    Name = 'PsModule'
                    ModuleName = 'PowerShellGet'
                }
                @{
                    TestCaseName = 'Good'
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
        it "should be able to get a <Name> - <TestCaseName>" -TestCases $testCases -skip:($IsWindows -or $IsLinux)  {
            param($Name)
            $resource =Get-DscResource -Name $name
            $resource | Should -Not -BeNullOrEmpty
        }

        # Linux issue: https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12
        # macOS issue: https://github.com/PowerShell/MMI/issues/33
        it "should be able to get a <Name> from <ModuleName> - <TestCaseName>" -TestCases $testCases -Skip:($IsLinux)  {
            param($Name,$ModuleName, $PendingBecause)
            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $Because
            }
            $resource =Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
        }
    }
}
