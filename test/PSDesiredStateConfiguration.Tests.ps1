# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

BeforeDiscovery {
    Function global:Test-IsInvokeDscResourceEnable {
        return ($PSVersionTable.PSVersion.Major -ge 7)
    }
}

Describe "Test PSDesiredStateConfiguration" {
    Context "Module loading" {
        BeforeAll {
            Function BeCommand {
                [CmdletBinding()]
                Param(
                    $ActualValue,
                    [string] $CommandName,
                    [string] $ModuleName,
                    [switch]$Negate,
                    [string]$Because,
                    $CallerSessionState
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

        It "The module should have the Configuration Command" {
            $commands | Should -HaveCommand -CommandName 'New-DscChecksum' -ModuleName PSDesiredStateConfiguration
        }

        It "The module should have the Get-DscResource Command" {
            $commands | Should -HaveCommand -CommandName 'Get-DscResource' -ModuleName PSDesiredStateConfiguration
        }

        It "The module should have the Invoke-DscResource Command" -Skip:(!(Test-IsInvokeDscResourceEnable)) {
            $commands | Should -HaveCommand -CommandName 'Invoke-DscResource' -ModuleName PSDesiredStateConfiguration
        }
    }
    Context "Get-DscResource - Composite Resources" {
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
            $testCases = @(
                @{
                    TestCaseName = 'case mismatch in resource name'
                    Name         = 'groupset'
                    ModuleName   = 'PSDscResources'
                }
                @{
                    TestCaseName = 'Both names have matching case'
                    Name         = 'GroupSet'
                    ModuleName   = 'PSDscResources'
                }
                @{
                    TestCaseName = 'case mismatch in module name'
                    Name         = 'GroupSet'
                    ModuleName   = 'psdscResources'
                }
            )
        }

        AfterAll {
            $Global:ProgressPreference = $origProgress
        }

        it "should be able to get <Name> - <TestCaseName>" -TestCases $testCases {
            param($Name)

            if ($IsWindows) {
                Set-ItResult -Pending -Because "Will only find script from PSDesiredStateConfiguration without modulename"
            }

            if (-not $IsWindows) {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/26"
            }

            $resource = Get-DscResource -Name $name
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
            if (Test-IsInvokeDscResourceEnable) {
                $resource.ImplementationDetail | Should -BeNullOrEmpty
            }
            else {
                $resource.ImplementationDetail | Should -BeNullOrEmpty
            }

        }

        it "should be able to get <Name> from <ModuleName> - <TestCaseName>" -TestCases $testCases {
            param($Name, $ModuleName, $PendingBecause)

            if (-not $IsWindows) {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/26"
            }

            if ($PendingBecause) {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resource = Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
            if (Test-IsInvokeDscResourceEnable) {
                $resource.ImplementationDetail | Should -BeNullOrEmpty
            }
            else {
                $resource.ImplementationDetail | Should -BeNullOrEmpty
            }
        }
    }

    Context "Get-DscResource - ScriptResources" {
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'

            $module = Get-Module PowerShellGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1

            $psGetModuleSpecification = @{ModuleName = $module.Name; ModuleVersion = $module.Version.ToString() }
            $psGetModuleCount = @(Get-Module PowerShellGet -ListAvailable).Count
            $testCases = @(
                @{
                    TestCaseName = 'case mismatch in resource name'
                    Name         = 'script'
                    ModuleName   = 'PSDscResources'
                }
                @{
                    TestCaseName = 'Both names have matching case'
                    Name         = 'Script'
                    ModuleName   = 'PSDscResources'
                }
                @{
                    TestCaseName = 'case mismatch in module name'
                    Name         = 'Script'
                    ModuleName   = 'psdscResources'
                }
                <#
                Add these back when PowerShellGet is fixed https://github.com/PowerShell/PowerShellGet/pull/529
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
                }
                #>
            )
        }

        AfterAll {
            $Global:ProgressPreference = $origProgress
        }

        it "should be able to get <Name> - <TestCaseName>" -TestCases $testCases {
            param($Name)

            if ($IsWindows) {
                Set-ItResult -Pending -Because "Will only find script from PSDesiredStateConfiguration without modulename"
            }

            if ($PendingBecause) {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resources = @(Get-DscResource -Name $name)
            $resources | Should -Not -BeNullOrEmpty
            foreach ($resource in $resource) {
                $resource.Name | Should -Be $Name
                if (Test-IsInvokeDscResourceEnable) {
                    $resource.ImplementationDetail | Should -Be 'ScriptBased'
                }
                else {
                    $resource.ImplementationDetail | Should -BeNullOrEmpty
                }

            }
        }

        it "should be able to get <Name> from <ModuleName> - <TestCaseName>" -TestCases $testCases {
            param($Name, $ModuleName, $PendingBecause)

            if (-not $IsWindows) {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12 and https://github.com/PowerShell/PowerShellGet/pull/529"
            }

            if ($PendingBecause) {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resources = @(Get-DscResource -Name $name -Module $ModuleName)
            $resources | Should -Not -BeNullOrEmpty
            foreach ($resource in $resource) {
                $resource.Name | Should -Be $Name
                if (Test-IsInvokeDscResourceEnable) {
                    $resource.ImplementationDetail | Should -Be 'ScriptBased'
                }
                else {
                    $resource.ImplementationDetail | Should -BeNullOrEmpty
                }
            }
        }

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
            if (Test-IsInvokeDscResourceEnable) {
                $resource.ImplementationDetail | Should -Be 'ClassBased'
            }
            else {
                $resource.ImplementationDetail | Should -BeNullOrEmpty
            }
        }

        it "should be able to get class resource - <Name> - <TestCaseName>" -TestCases $classTestCases {
            param($Name, $ModuleName, $PendingBecause)
            if ($IsWindows) {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/19"
            }

            if ($PendingBecause) {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resource = Get-DscResource -Name $Name
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
            if (Test-IsInvokeDscResourceEnable) {
                $resource.ImplementationDetail | Should -Be 'ClassBased'
            }
            else {
                $resource.ImplementationDetail | Should -BeNullOrEmpty
            }
        }
    }
    Context "Invoke-DscResource" {
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
        }

        AfterAll {
            $Global:ProgressPreference = $origProgress
        }

        Context "mof resources" {
            BeforeAll {
                $dscMachineStatusCases = @(
                    @{
                        value          = '1'
                        expectedResult = $true
                    }
                    @{
                        value          = '$true'
                        expectedResult = $true
                    }
                    @{
                        value          = '0'
                        expectedResult = $false
                    }
                    @{
                        value          = '$false'
                        expectedResult = $false
                    }
                )

                $module = Get-Module PowerShellGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1

                $psGetModuleSpecification = @{ModuleName = $module.Name; ModuleVersion = $module.Version.ToString() }
            }
            it "Set method should work" -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                if ($env:TF_BUILD -eq 'true') {
                    Set-ItResult -Skipped -Because "cannot install PSDscResources module during tests in Azure DevOps"
                }

                $result = Invoke-DscResource -Name PSModule -ModuleName $psGetModuleSpecification -Method set -Property @{
                    Name               = 'PSDscResources'
                    InstallationPolicy = 'Trusted'
                }

                $result.RebootRequired | Should -BeFalse
                $module = Get-module PSDscResources -ListAvailable
                $module | Should -Not -BeNullOrEmpty -Because "Resource should have installed module"
            }
            it 'Set method should return RebootRequired=<expectedResult> when $global:DSCMachineStatus = <value>'  -Skip:(!(Test-IsInvokeDscResourceEnable))  -TestCases $dscMachineStatusCases {
                param(
                    $value,
                    $ExpectedResult
                )

                # using create scriptBlock because $using:<variable> doesn't work with existing Invoke-DscResource
                # Verified in Windows PowerShell on 20190814
                $result = Invoke-DscResource -Name Script -ModuleName PSDscResources -Method Set -Property @{TestScript = { Write-Output 'test'; return $false }; GetScript = { return @{ } }; SetScript = [scriptblock]::Create("`$global:DSCMachineStatus = $value;return") }
                $result | Should -Not -BeNullOrEmpty
                $result.RebootRequired | Should -BeExactly $expectedResult
            }

            it "Test method should return false"  -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                if ($env:TF_BUILD -eq 'true') {
                    Set-ItResult -Skipped -Because "cannot install PSDscResources module during tests in Azure DevOps"
                }

                $result = Invoke-DscResource -Name Script -ModuleName PSDscResources -Method Test -Property @{TestScript = { Write-Output 'test'; return $false }; GetScript = { return @{ } }; SetScript = { return } }
                $result | Should -Not -BeNullOrEmpty
                $result.InDesiredState | Should -BeFalse -Because "Test method return false"
            }

            it "Test method should return true"  -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                if ($env:TF_BUILD -eq 'true') {
                    Set-ItResult -Skipped -Because "cannot install PSDscResources module during tests in Azure DevOps"
                }

                $result = Invoke-DscResource -Name Script -ModuleName PSDscResources -Method Test -Property @{TestScript = { Write-Verbose 'test'; return $true }; GetScript = { return @{ } }; SetScript = { return } }
                $result | Should -BeTrue -Because "Test method return true"
            }

            it "Test method should return true with moduleSpecification"  -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                if ($env:TF_BUILD -eq 'true') {
                    Set-ItResult -Skipped -Because "cannot install PSDscResources module during tests in Azure DevOps"
                }

                $module = get-module PSDscResources -ListAvailable
                $moduleSpecification = @{ModuleName = $module.Name; ModuleVersion = $module.Version.ToString() }
                $result = Invoke-DscResource -Name Script -ModuleName $moduleSpecification -Method Test -Property @{TestScript = { Write-Verbose 'test'; return $true }; GetScript = { return @{ } }; SetScript = { return } }
                $result | Should -BeTrue -Because "Test method return true"
            }

            it "Invalid moduleSpecification"  -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/17"
                $moduleSpecification = @{ModuleName = 'PSDscResources'; ModuleVersion = '99.99.99.993' }
                {
                    Invoke-DscResource -Name Script -ModuleName $moduleSpecification -Method Test -Property @{TestScript = { Write-Host 'test'; return $true }; GetScript = { return @{ } }; SetScript = { return } } -ErrorAction Stop
                } |
                Should -Throw -ErrorId 'InvalidResourceSpecification,Invoke-DscResource' -ExpectedMessage 'Invalid Resource Name ''Script'' or module specification.'
            }

            it "Test an embedded DSC resource"  {
                if (!(Test-IsInvokeDscResourceEnable)) {
                    Set-ItResult -Skipped -Because "Feature not enabled"
                }

                if ($env:TF_BUILD -eq 'true') {
                    Set-ItResult -Skipped -Because "cannot install PSDscResources module during tests in Azure DevOps"
                }

                $resourceName="TestRes"
                $moduleName="TestEmbeddedDSCResource"
                $embObj = @(New-Object -TypeName psobject -Property @{embclassprop="property1"})

                Install-Module -Name $moduleName -Force

                $resource = Get-DscResource -Name $resourceName -Module $moduleName -ErrorAction Stop
                $resource | Should -Not -BeNullOrEmpty
                $resource.Name | Should -Be $resourceName

                $methodName="Test"
                $result = Invoke-DscResource -Name $resourceName -ModuleName $moduleName -Method $methodName -Property @{embclassobj=$embObj;propName="property1"}
                $result.InDesiredState | Should -BeTrue
                $result = Invoke-DscResource -Name $resourceName -ModuleName $moduleName -Method $methodName -Property  @{embclassobj=$embObj;propName="property2"}
                $result.InDesiredState | Should -BeFalse

                $methodName="Get"
                $result = Invoke-DscResource -Name $resourceName -ModuleName $moduleName -Method $methodName -Property @{embclassobj=$embObj;propName="property1"}
                $result.propName | Should -Be "property1"
                $result = Invoke-DscResource -Name $resourceName -ModuleName $moduleName -Method $methodName -Property @{embclassobj=$embObj;propName="property2"}
                $result.propName | Should -Not -Be "property1"

                $methodName="Set"
                $result = Invoke-DscResource -Name $resourceName -ModuleName $moduleName -Method $methodName -Property @{embclassobj=$embObj;propName="property1"}
                $result | Should -Not -BeNullOrEmpty
                $result.RebootRequired | Should -BeFalse
            }

            it "Using PsDscRunAsCredential should say not supported" -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                {
                    Invoke-DscResource -Name Script -ModuleName PSDscResources -Method Set -Property @{TestScript = { Write-Output 'test'; return $false }; GetScript = { return @{ } }; SetScript = {return}; PsDscRunAsCredential='natoheu'}  -ErrorAction Stop
                } |
                Should -Throw -ErrorId 'PsDscRunAsCredentialNotSupport,Invoke-DscResource'
            }

            # waiting on Get-DscResource to be fixed
            it "Invalid module name" -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/17"
                {
                    Invoke-DscResource -Name Script -ModuleName santoheusnaasonteuhsantoheu -Method Test -Property @{TestScript = { Write-Host 'test'; return $true }; GetScript = { return @{ } }; SetScript = { return } } -ErrorAction Stop
                } |
                Should -Throw -ErrorId 'Microsoft.PowerShell.Commands.WriteErrorException,CheckResourceFound'
            }

            it "Invalid resource name" -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                if ($IsWindows) {
                    Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/17"
                }

                {
                    Invoke-DscResource -Name santoheusnaasonteuhsantoheu -Method Test -Property @{TestScript = { Write-Host 'test'; return $true }; GetScript = { return @{ } }; SetScript = { return } } -ErrorAction Stop
                } |
                Should -Throw -ErrorId 'Microsoft.PowerShell.Commands.WriteErrorException,CheckResourceFound'
            }

            it "Get method should work"  -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                if ($env:TF_BUILD -eq 'true') {
                    Set-ItResult -Skipped -Because "cannot install PSDscResources module during tests in Azure DevOps"
                }

                if (-not $IsWindows) {
                    Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12 and https://github.com/PowerShell/PowerShellGet/pull/529"
                }

                $result = Invoke-DscResource -Name PSModule -ModuleName $psGetModuleSpecification -Method Get -Property @{ Name = 'PSDscResources' }
                $result | Should -Not -BeNullOrEmpty
                $result.Author | Should -BeLike 'Microsoft*'
                $result.InstallationPolicy | Should -BeOfType [string]
                $result.Guid | Should -BeOfType [Guid]
                $result.Ensure | Should -Be 'Present'
                $result.Name | Should -be 'PSDscResources'
                $result.Description | Should -BeLike 'This*DSC*'
                $result.InstalledVersion | should -BeOfType [Version]
                $result.ModuleBase | Should -BeLike '*PSDscResources*'
                $result.Repository | should -BeOfType [string]
                $result.ModuleType | Should -Be 'Manifest'
            }
        }

        Context "Class Based Resources" {
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

            it 'Set method should work'  -Skip:(!(Test-IsInvokeDscResourceEnable)) {
                param(
                    $value,
                    $ExpectedResult
                )

                $testString = '890574209347509120348'
                $result = Invoke-DscResource -Name XmlFileContentResource -ModuleName XmlContentDsc -Property @{Path = $resolvedXmlPath; XPath = '/configuration/appSetting/Test1'; Ensure = 'Present'; Attributes = @{ TestValue2 = $testString; Name = $testString } } -Method Set
                $result | Should -Not -BeNullOrEmpty
                $result.RebootRequired | Should -BeFalse
                $testXmlPath | Should -FileContentMatch $testString
            }
        }
    }
}
