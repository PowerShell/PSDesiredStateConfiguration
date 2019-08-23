Function Install-ModuleIfMissing
{
    param(
        [parameter(Mandatory)]
        [String]
        $Name,
        [version]
        $RequiredVersion,
        [switch]
        $SkipPublisherCheck,
        [switch]
        $Force
    )

    $module = Get-Module -Name $Name -ListAvailable -ErrorAction Ignore | Sort-Object -Property Version -Descending | Select-Object -First 1

    if(!$module -or $module.Version -lt $RequiredVersion)
    {
        Write-Verbose "Installing module '$Name' ..." -Verbose
        Install-Module -Name $Name -Force -SkipPublisherCheck:$SkipPublisherCheck.IsPresent
    }
}

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
    Context "Get-DscResource - Composite Resources" {
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
            Install-ModuleIfMissing -Name PSDscResources
            $testCases = @(
                @{
                    TestCaseName = 'case mismatch in resource name'
                    Name = 'groupset'
                    ModuleName = 'PSDscResources'
                }
                @{
                    TestCaseName = 'Both names have matching case'
                    Name = 'GroupSet'
                    ModuleName = 'PSDscResources'
                }
                @{
                    TestCaseName = 'case mismatch in module name'
                    Name = 'GroupSet'
                    ModuleName = 'psdscResources'
                }
            )
        }
        AfterAll {
            $Global:ProgressPreference = $origProgress
        }
        it "should be able to get <Name> - <TestCaseName>" -TestCases $testCases {
            param($Name)

            if($IsWindows)
            {
                Set-ItResult -Pending -Because "Will only find script from PSDesiredStateConfiguration without modulename"
            }

            if($IsLinux)
            {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/26"
            }

            $resource = Get-DscResource -Name $name
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
            $resource.ImplementationDetail | Should -BeNullOrEmpty
        }

        it "should be able to get <Name> from <ModuleName> - <TestCaseName>" -TestCases $testCases {
            param($Name,$ModuleName, $PendingBecause)

            if($IsLinux)
            {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/26"
            }

            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $PendingBecause
            }
            $resource = Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
            $resource.ImplementationDetail | Should -BeNullOrEmpty
        }
    }
    Context "Get-DscResource - ScriptResources" {
        BeforeAll {
            $origProgress = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'


            Install-ModuleIfMissing -Name PSDscResources -Force

            Install-ModuleIfMissing -Name PowerShellGet -RequiredVersion '2.2.1'
            $module = Get-Module PowerShellGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1

            $psGetModuleSpecification = @{ModuleName=$module.Name;ModuleVersion=$module.Version.ToString()}
            $psGetModuleCount = @(Get-Module PowerShellGet -ListAvailable).Count
            $testCases = @(
                @{
                    TestCaseName = 'case mismatch in resource name'
                    Name = 'script'
                    ModuleName = 'PSDscResources'
                }
                @{
                    TestCaseName = 'Both names have matching case'
                    Name = 'Script'
                    ModuleName = 'PSDscResources'
                }
                @{
                    TestCaseName = 'case mismatch in module name'
                    Name = 'Script'
                    ModuleName = 'psdscResources'
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

            if($IsWindows)
            {
                Set-ItResult -Pending -Because "Will only find script from PSDesiredStateConfiguration without modulename"
            }

            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resources = @(Get-DscResource -Name $name)
            $resources | Should -Not -BeNullOrEmpty
            foreach($resource in $resource)
            {
                $resource.Name | Should -Be $Name
            }
        }

        it "should be able to get <Name> from <ModuleName> - <TestCaseName>" -TestCases $testCases {
            param($Name,$ModuleName, $PendingBecause)

            if($IsLinux)
            {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/12 and https://github.com/PowerShell/PowerShellGet/pull/529"
            }

            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resources = @(Get-DscResource -Name $name -Module $ModuleName)
            $resources | Should -Not -BeNullOrEmpty
            foreach($resource in $resource)
            {
                $resource.Name | Should -Be $Name
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
            Install-ModuleIfMissing -Name XmlContentDsc -Force
            $classTestCases = @(
                @{
                    TestCaseName = 'Good case'
                    Name = 'XmlFileContentResource'
                    ModuleName = 'XmlContentDsc'
                }
                @{
                    TestCaseName = 'Module Name case mismatch'
                    Name = 'XmlFileContentResource'
                    ModuleName = 'xmlcontentdsc'
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

        it "should be able to get class resource - <Name> from <ModuleName> - <TestCaseName>" -TestCases $classTestCases {
            param($Name,$ModuleName, $PendingBecause)

            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $PendingBecause
            }

            $resource = Get-DscResource -Name $Name -Module $ModuleName
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
        }

        it "should be able to get class resource - <Name> - <TestCaseName>" -TestCases $classTestCases {
            param($Name,$ModuleName, $PendingBecause)
            if($IsWindows)
            {
                Set-ItResult -Pending -Because "https://github.com/PowerShell/PSDesiredStateConfiguration/issues/19"
            }
            if($PendingBecause)
            {
                Set-ItResult -Pending -Because $PendingBecause
            }
            $resource = Get-DscResource -Name $Name
            $resource | Should -Not -BeNullOrEmpty
            $resource.Name | Should -Be $Name
        }
    }
}

