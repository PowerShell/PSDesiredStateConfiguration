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

Describe "All types DSC resource tests" {
    BeforeAll {

        Import-Module -Name PSDesiredStateConfiguration -MinimumVersion 3.0.0

        $SavedPSModulePath = $env:PSModulePath

        $testModulesPath = Join-Path $PSScriptRoot "TestModules"
        "TestModulesPath is " + $testModulesPath | Write-Verbose -Verbose
        $env:PSModulePath = $testModulesPath + [System.IO.Path]::PathSeparator + $env:PSModulePath
        "PSModulePath is " + $env:PSModulePath | Write-Verbose -Verbose
    }

    AfterAll {
        $env:PSModulePath = $SavedPSModulePath
    }

    It "Check all property types in Get-DscResource" {

        $resource = Get-DscResource | ? {$_.Name -eq "xTestClassResource"}
        $resource | Should -Not -BeNullOrEmpty
        $resource.Properties.Count | Should -Be 32

        foreach($dscResourcePropertyInfo in $resource.Properties)
        {
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
                "EmbClassObj" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[EmbClass]'}
                "EmbClassObjArray" {$dscResourcePropertyInfo.PropertyType |  Should -Be '[EmbClass[]]'}
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

    It "Check all property types in Invoke-DscResource" {

        $resource = Invoke-DscResource -Name xTestClassResource -ModuleName xTestClassResource -Method Get -Property @{Name="Test"}
        $resource | Should -Not -BeNullOrEmpty
        $resource.GetType().Name | Should -Be "xTestClassResource"
        $resource.Name | Should -Be "Test"
        $resource.Value | Should -Be "Inside if"
        
        $resource.Name.GetType().Name | Should -Be "String"
        $resource.Value.GetType().Name | Should -Be "String"
        $resource.sArray.GetType().Name | Should -Be "String[]"

        $resource.bValue.GetType().Name | Should -Be "Boolean"
        $resource.bValueArray.GetType().Name | Should -Be "Boolean[]"
        $resource.char16Value.GetType().Name | Should -Be "Char"
        $resource.char16ValueArray.GetType().Name | Should -Be "Char[]"
        $resource.dateTimeVal.GetType().Name | Should -Be "DateTime"
        $resource.dateTimeArrayVal.GetType().Name | Should -Be "DateTime[]"
        $resource.EmbClassObj.GetType().Name | Should -Be "EmbClass"
        $resource.EmbClassObjArray.GetType().Name | Should -Be "EmbClass[]"
        $resource.Ensure.GetType().Name | Should -Be "Ensure"
        $resource.Real32Value.GetType().Name | Should -Be "Single"
        $resource.Real32ValueArray.GetType().Name | Should -Be "Single[]"
        $resource.Real64Value.GetType().Name | Should -Be "Double"
        $resource.Real64ValueArray.GetType().Name | Should -Be "Double[]"
        
        $resource.sInt8Value.GetType().Name | Should -Be "SByte"
        $resource.sInt8ValueArray.GetType().Name | Should -Be "SByte[]"
        $resource.sInt16Value.GetType().Name | Should -Be "Int16"
        $resource.sInt16ValueArray.GetType().Name | Should -Be "Int16[]"
        $resource.sInt32Value.GetType().Name | Should -Be "Int32"
        $resource.sInt32ValueArray.GetType().Name | Should -Be "Int32[]"
        $resource.sInt64Value.GetType().Name | Should -Be "Int64"
        $resource.sInt64ValueArray.GetType().Name | Should -Be "Int64[]"

        $resource.uInt8Value.GetType().Name | Should -Be "Byte"
        $resource.uInt8ValueArray.GetType().Name | Should -Be "Byte[]"
        $resource.uInt16Value.GetType().Name | Should -Be "UInt16"
        $resource.uInt16ValueArray.GetType().Name | Should -Be "UInt16[]"
        $resource.uInt32Value.GetType().Name | Should -Be "UInt32"
        $resource.uInt32ValueArray.GetType().Name | Should -Be "UInt32[]"
        $resource.uInt64Value.GetType().Name | Should -Be "UInt64"
        $resource.uInt64ValueArray.GetType().Name | Should -Be "UInt64[]"

        # extra check for embedded objects
        $resource.EmbClassObj.EmbClassStr1 | Should -Be "TestEmbObjValue"
        $resource.EmbClassObjArray[0].EmbClassStr1 | Should -Be "TestEmbClassStr1Value"
    }

    It "Check all property types in configuration compilation" {

        [Scriptblock]::Create(@"
configuration DSCAllTypesConfig
{
    Import-DscResource -ModuleName xTestClassResource
    Node "localhost" {
        xTestClassResource f1
        {
            Name = 'TestName'
            Value = 'TestValue'

            char16Value = 'A'
            char16ValueArray = @('A','B')

            sArray = @('Test1','Test2')

            bValue = `$true
            bValueArray = @(`$true,`$false)

            dateTimeVal = Get-Date
            dateTimeArrayVal = @(`$(Get-Date), `$(Get-Date))

            Ensure = 'Present'

            uInt8Value = 255
            sInt8Value = -128
            uInt16Value = 65535
            sInt16Value = -32768
            uInt32Value = 4294967295
            sInt32Value = -2147483648
            uInt64Value = 18446744073709551615
            sInt64Value = -9223372036854775808

            Real32Value = [Single]-1.234
            Real64Value = [Double]-1.234

            uInt8ValueArray = @(255)
            sInt8ValueArray = @(-128)
            uInt16ValueArray = @(65535)
            sInt16ValueArray = @(-32768)
            uInt32ValueArray = @(4294967295)
            sInt32ValueArray = @(-2147483648)
            uInt64ValueArray = @(18446744073709551615)
            sInt64ValueArray = @(-9223372036854775808)
        }
    }
}

DSCAllTypesConfig -OutputPath TestDrive:\DSCAllTypesConfig
"@) | Should -Not -Throw

        "TestDrive:\DSCAllTypesConfig\localhost.mof" | Should -Exist
        Get-Content -Raw -Path "TestDrive:\DSCAllTypesConfig\localhost.mof" | Write-Verbose -Verbose
    }
}
