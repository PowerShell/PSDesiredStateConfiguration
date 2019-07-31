Describe "Test PSDesiredStateConfiguration" -tags CI {
    BeforeAll {
        $commands = Get-Command -Module PSDesiredStateConfiguration
    }
    BeforeEach {
    }
    AfterEach {
    }
    AfterAll {
    }

    It "The module should have 2 commands" {
        $commands.Count | Should -Be 2
    }
    It "The module should have the Configuration Command" {
        $commands | Where-Object {$_.Name -eq 'Configuration'} | Should -Not -BeNullOrEmpty
    }
    It "The module should have the Get-DscResource Command" {
        $commands | Where-Object {$_.Name -eq 'Get-DscResource'} | Should -Not -BeNullOrEmpty
    }
}
