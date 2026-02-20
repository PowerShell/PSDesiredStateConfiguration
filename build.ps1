# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
param (
    [Parameter(ParameterSetName="build")]
    [switch]
    $Clean,

    [Parameter(ParameterSetName="build")]
    [switch]
    $Build,

    [Parameter(ParameterSetName="publish")]
    [switch]
    $Publish,

    [Parameter(ParameterSetName="build")]
    [switch]
    $Test,

    [Parameter(ParameterSetName="build")]
    [string[]]
    [ValidateSet("Functional","StaticAnalysis")]
    $TestType = @("Functional"),

    [Parameter(ParameterSetName="help")]
    [switch]
    $UpdateHelp,

    [Parameter(ParameterSetName="build")]
    [switch]
    $TestInvokeDscResource
)

# Build configuration
$script:ModuleName = "PSDesiredStateConfiguration"
$script:SrcPath = Join-Path (Join-Path $PSScriptRoot "src") $ModuleName
$script:OutDirectory = Join-Path $PSScriptRoot "out"
$script:Culture = "en-US"
$script:HelpPath = Join-Path $PSScriptRoot "help"

. $PSScriptRoot\dobuild.ps1

if ($Clean -and (Test-Path $OutDirectory))
{
    Remove-Item -Force -Recurse $OutDirectory -ErrorAction Stop -Verbose
}

if (-not (Test-Path $OutDirectory))
{
    $script:OutModule = New-Item -ItemType Directory -Path (Join-Path $OutDirectory $ModuleName)
}
else
{
    $script:OutModule = Join-Path $OutDirectory $ModuleName
}

if ($Build.IsPresent)
{
    DoBuild
}

if ($Publish.IsPresent)
{
    DoPackage
}

if ($Test.IsPresent) {
    Import-Module Pester -MinimumVersion 5.0.0
    Import-Module $PSScriptRoot\out\PSDesiredStateConfiguration\PSDesiredStateConfiguration.psd1

    $testPath = Join-Path $PSScriptRoot "test"
    $config = [PesterConfiguration]::Default
    $config.Run.Path = $testPath
    $config.Run.Exit = $false
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputPath = Join-Path $OutDirectory "testResults.xml"
    $config.Output.Verbosity = "Detailed"

    Write-Verbose -Verbose "Running tests from: $testPath"
    $result = Invoke-Pester -Configuration $config

    if ($result.FailedCount -gt 0) {
        throw "$($result.FailedCount) test(s) failed"
    }
}

if ($UpdateHelp.IsPresent) {
    # Build help using platyPS
    $docsPath = Join-Path $PSScriptRoot "help"
    $markdownDocsPath = Join-Path $docsPath "en-US"
    $outputDocsPath = Join-Path $OutModule "en-US"

    if (-not (Get-Module -ListAvailable platyPS)) {
        Write-Verbose -Verbose "platyPS module not found, installing"
        Install-Module -Force -Name platyPS -Scope CurrentUser
    }

    Import-Module platyPS -Verbose:$false
    if (-not (Test-Path $outputDocsPath)) {
        $null = New-Item -Type Directory -Path $outputDocsPath -Force
    }
    $null = New-ExternalHelp -Path $markdownDocsPath -OutputPath $outputDocsPath -Force
}
