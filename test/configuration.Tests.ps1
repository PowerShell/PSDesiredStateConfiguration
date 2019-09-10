# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
Describe "DSC MOF Compilation" -tags "CI" {

    It "Should be able to compile a MOF using PSModule resource"  {
        Write-Verbose "DSC_HOME: ${env:DSC_HOME}" -verbose
        [Scriptblock]::Create(@"
        configuration DSCTestConfig
        {
            Import-DscResource -ModuleName PowerShellGet
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
