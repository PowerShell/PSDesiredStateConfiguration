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
        it "should be able to get a resource without module name" -Pending {
            $resource =Get-DscResource -Name PsModule
            $resource | Should -Not -BeNullOrEmpty
        }

        # Linux issue: https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12
        # macOS issue: https://github.com/PowerShell/MMI/issues/33
        it "should be able to get a resource with module name" -skip:($IsMacOS -or $IsLinux) {
            $resource =Get-DscResource -Name PsModule -Module PowerShellGet
            $resource | Should -Not -BeNullOrEmpty
        }
    }
}
