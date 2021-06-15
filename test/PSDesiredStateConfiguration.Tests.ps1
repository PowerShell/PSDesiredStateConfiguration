# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
Function Install-ModuleIfMissing {
    param(
        [parameter(Mandatory)]
        [String]
        $Name,
        [version]
        $MinimumVersion,
        [switch]
        $SkipPublisherCheck,
        [switch]
        $Force
    )

    $module = Get-Module -Name $Name -ListAvailable -ErrorAction Ignore | Sort-Object -Property Version -Descending | Select-Object -First 1

    if (!$module -or $module.Version -lt $MinimumVersion) {
        Write-Verbose "Installing module '$Name' ..." -Verbose
        Install-Module -Name $Name -Force -SkipPublisherCheck:$SkipPublisherCheck.IsPresent
    }
}

Describe "Test PSDesiredStateConfiguration" {
    Context "Module loading" {
        BeforeAll {
            Function BeCommand {
                [CmdletBinding()]
                Param(
                    [object[]] $ActualValue,
                    [string] $CommandName,
                    [string] $ModuleName,
                    [switch]$Negate
                )

                $failure = if ($Negate) {
                    "Expected: Command $CommandName should not exist in module $ModuleName"
                }
                else {
                    "Expected: Command $CommandName should exist in module $ModuleName"
                }

                $succeeded = if ($Negate) {
                    ($ActualValue | Where-Object { $_.Name -eq $CommandName }).count -eq 0
                }
                else {
                    ($ActualValue | Where-Object { $_.Name -eq $CommandName }).count -gt 0
                }

                return [PSCustomObject]@{
                    Succeeded = $succeeded
                    FailureMessage = $failure
                }
            }

            Add-AssertionOperator -Name 'HaveCommand' -Test $Function:BeCommand -SupportsArrayInput

            $commands = Get-Command -Module PSDesiredStateConfiguration
        }

        It "The module should have the Configuration Command" {
            $commands | Should -HaveCommand -CommandName 'Configuration' -ModuleName PSDesiredStateConfiguration
        }

        It "The module should have the New-DscChecksum Command" {
            $commands | Should -HaveCommand -CommandName 'New-DscChecksum' -ModuleName PSDesiredStateConfiguration
        }

        It "The module should have the Get-DscResource Command" {
            $commands | Should -HaveCommand -CommandName 'Get-DscResource' -ModuleName PSDesiredStateConfiguration
        }

        It "The module should have the Invoke-DscResource Command" {
            $commands | Should -HaveCommand -CommandName 'Invoke-DscResource' -ModuleName PSDesiredStateConfiguration
        }

        It "The module should have the ConvertTo-DscJsonSchema Command" {
            $commands | Should -HaveCommand -CommandName 'ConvertTo-DscJsonSchema' -ModuleName PSDesiredStateConfiguration
        }
    }

    Context "Get-DscResource - Class base Resources" {

        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
            Install-ModuleIfMissing -Name XmlContentDsc -Force
            $classTestCases = @(
                @{
                    TestCaseName = 'Good case'
                    Name         = 'XmlFileContentResource'
                    ModuleName   = 'XmlContentDsc'
                }
                @{
                    TestCaseName = 'Module Name case mismatch'
                    Name         = 'XmlFileContentResource'
                    ModuleName   = 'xmlcontentdsc'
                }
                @{
                    TestCaseName = 'Resource name case mismatch'
                    Name         = 'xmlfilecontentresource'
                    ModuleName   = 'XmlContentDsc'
                }
            )
        }

        AfterAll {
            $global:ProgressPreference = $origProgress
        }

        it "should be able to get class resource - <Name> from <ModuleName> - <TestCaseName>" -TestCases $classTestCases {
            param($Name, $ModuleName, $PendingBecause)

            if ($PendingBecause) {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resource = Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
            $resource.ImplementationDetail | Should -Be 'ClassBased'
        }

        it "should be able to get class resource - <Name> - <TestCaseName>" -TestCases $classTestCases {
            param($Name, $ModuleName, $PendingBecause)

            if ($PendingBecause) {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resource = Get-DscResource -Name $Name
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
            $resource.ImplementationDetail | Should -Be 'ClassBased'
        }
    }

    Context "Invoke-DscResource" {
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
            $module = Get-InstalledModule -Name PsDscResources -ErrorAction Ignore
            if ($module) {
                Write-Verbose "removing PSDscResources, tests will re-install..." -Verbose
                Uninstall-Module -Name PsDscResources -AllVersions -Force
            }
        }

        AfterAll {
            $Global:ProgressPreference = $origProgress
        }

        Context "Class Based Resources" {
            BeforeAll {
                Install-ModuleIfMissing -Name XmlContentDsc -Force
            }

            AfterAll {
                $Global:ProgressPreference = $origProgress
            }

            BeforeEach {
                $testXmlPath = 'TestDrive:\test.xml'
                @'
<configuration>
<appSetting>
    <Test1/>
</appSetting>
</configuration>
'@ | Out-File -FilePath $testXmlPath -Encoding utf8NoBOM
                $resolvedXmlPath = (Resolve-Path -Path $testXmlPath).ProviderPath
            }

            it 'Set method should work' {
                param(
                    $value,
                    $ExpectedResult
                )

                $testString = '890574209347509120348'
                $result = Invoke-DscResource -Name XmlFileContentResource -ModuleName XmlContentDsc -Property @{Path = $resolvedXmlPath; XPath = '/configuration/appSetting/Test1'; Ensure = 'Present'; Attributes = @{ TestValue2 = $testString; Name = $testString } } -Method Set
                $result | Should -Not -BeNullOrEmpty
                $result.GetType() | Should -Be 'InvokeDscResourceSetResult'
                $result.RebootRequired | Should -BeFalse
                $testXmlPath | Should -FileContentMatch $testString
            }

            it 'Get method should work' {
                param(
                    $value,
                    $ExpectedResult
                )

                $result = Invoke-DscResource -Name XmlFileContentResource -ModuleName XmlContentDsc -Property @{Path = $resolvedXmlPath; XPath = '/configuration/appSetting/Test1'} -Method Get
                $result.GetType() | Should -Be 'XmlFileContentResource'
            }

            it 'Test method should work' {
                param(
                    $value,
                    $ExpectedResult
                )

                $result = Invoke-DscResource -Name XmlFileContentResource -ModuleName XmlContentDsc -Property @{Path = $resolvedXmlPath; XPath = '/configuration/appSetting/Test1'} -Method Test
                $result | Should -Not -BeNullOrEmpty
                $result.GetType() | Should -Be 'InvokeDscResourceTestResult'
                $result.InDesiredState | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe "DSC MOF Compilation" {
    BeforeAll {
        # ensure that module is imported
        Import-Module -Name PSDesiredStateConfiguration -MinimumVersion 3.0.0
        Install-ModuleIfMissing -Name XmlContentDsc -Force
    }

    It "Should be able to compile a MOF using configuration keyword" {

        Write-Verbose "DSC_HOME: ${env:DSC_HOME}" -Verbose
        [Scriptblock]::Create(@"
configuration DSCTestConfig
{
    Import-DscResource -ModuleName XmlContentDsc
    Node "localhost" {
        XmlFileContentResource f1
        {
            Path = 'testpath'
            XPath = '/configuration/appSetting/Test1'
            Ensure = 'Absent'
        }
    }
}

DSCTestConfig -OutputPath TestDrive:\DscTestConfig2
"@) | Should -Not -Throw

        "TestDrive:\DscTestConfig2\localhost.mof" | Should -Exist
    }
}

Describe "All types DSC resource" {
    BeforeAll {
        $SavedPSModulePath = $env:PSModulePath

        $testModulesPath = Join-Path $PSScriptRoot "TestModules"
        "TestModulesPath is " + $testModulesPath | Write-Verbose -Verbose
        $env:PSModulePath = $testModulesPath
    }

    AfterAll {
        $env:PSModulePath = $SavedPSModulePath
    }

    It "Check Get-DscResource on all-types dsc resource and check returned property types" {

        $resource = Get-DscResource | ? {$_.Name -eq "xTestClassResource"}
        $resource | Should -Not -BeNullOrEmpty
        $resource.Properties.Count | Should -Be 31

        foreach($dscResourcePropertyInfo in $resource.Properties)
        {
            $f = $dscResourcePropertyInfo.Name + " - " + $dscResourcePropertyInfo.PropertyType
            

            switch ($dscResourcePropertyInfo.Name)
            {
                "Name" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[string]'}
                "Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[string]'}
                "bValue" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[bool]'}
                "sArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[string[]]'}
                "bValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[bool[]]'}
                "char16Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[char]'}
                "char16ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[char[]]'}
                "dateTimeVal" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[DateTime]'}
                "dateTimeArrayVal" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[DateTime[]]'}
                "EmbClassObj" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[EmbClass[]]'}
                "Ensure" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[string]'}
                "Real32Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Single]'}
                "Real32ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Single[]]'}
                "Real64Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[double]'}
                "Real64ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[double[]]'}

                "sInt8Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[SByte]'}
                "sInt8ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[SByte[]]'}
                "sInt16Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Int16]'}
                "sInt16ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Int16[]]'}
                "sInt32Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Int32]'}
                "sInt32ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Int32[]]'}
                "sInt64Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Int64]'}
                "sInt64ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Int64[]]'}

                "uInt8Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Byte]'}
                "uInt8ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[Byte[]]'}
                "uInt16Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[UInt16]'}
                "uInt16ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[UInt16[]]'}
                "uInt32Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[UInt32]'}
                "uInt32ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[UInt32[]]'}
                "uInt64Value" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[UInt64]'}
                "uInt64ValueArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[UInt64[]]'}
            }
        }
    }
}
