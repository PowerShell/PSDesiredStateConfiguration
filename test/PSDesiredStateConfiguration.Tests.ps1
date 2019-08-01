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

    It "The module should have 3 commands" {
        if($commands.Count -ne 3)
        {
            $modulePath = (Get-Module PSDesiredStateConfiguration).Path
            Write-Verbose -Verbose -Message "PSDesiredStateConfiguration Path: $modulePath"
            $commands | Out-String | Write-Verbose -Verbose
        }
        $commands.Count | Should -Be 3
    }
    It "The module should have the Configuration Command" {
        $commands | Where-Object {$_.Name -eq 'Configuration'} | Should -Not -BeNullOrEmpty
    }
    It "The module should have the Get-DscResource Command" {
        $commands | Where-Object {$_.Name -eq 'Get-DscResource'} | Should -Not -BeNullOrEmpty
    }
}
