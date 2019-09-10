# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
Describe "DSC MOF Compilation" -tags "CI" {
    BeforeAll {
        $module = Get-Module PowerShellGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1

        $psGetModuleVersion = $module.Version.ToString()
    }

    It "Should be able to compile a MOF using PSModule resource"  {
        Write-Verbose "DSC_HOME: ${env:DSC_HOME}" -verbose
        [Scriptblock]::Create(@"
        configuration DSCTestConfig
        {
            Import-DscResource -ModuleName PowerShellGet -ModuleVersion $psGetModuleVersion
            Node "localhost" {
                PSModule f1
                {
                    Name = 'PsDscResources'
                    InstallationPolicy = 'Trusted'
                }
            }
        }

        DSCTestConfig -OutputPath TestDrive:\DscTestConfig2
"@) | Should -Not -Throw

        "TestDrive:\DscTestConfig2\localhost.mof" | Should -Exist
    }
}
