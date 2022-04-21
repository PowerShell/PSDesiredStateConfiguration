# PSDesiredStateConfiguration module

**NOTE: We are currently NOT accepting PRs for this project**

**PSDesiredStateConfiguration** (DSC) is the PowerShell module that enables writing configuration as code.

The DSC platform was originally built on top of WMI for Windows. Starting in PowerShell 7.1 and working
with internal partner teams
[Azure Guest Configuration](https://docs.microsoft.com/azure/governance/policy/concepts/guest-configuration)
and [Automanage](https://azure.microsoft.com/services/azure-automanage), we started making
DSC cross-platform by enabling `Invoke-DSCResource` to directly use resources without going through
the Local Configuration Manager (LCM).

Our initial cross-platform work to enable partner teams:

- Separated out the DSC parts in the PowerShell engine and moved them as a subsystem into the
  PSDesiredStateConfiguration module
- Remove PSDesiredStateConfiguration module from the PowerShell 7 package. This allows the
  PSDesiredStateConfiguration module to be developed independently of PowerShell and users can mix
  and match versions of PowerShell and PSDesiredStateConfiguration for their environment.
  - This is now available on the PowerShell Gallery: [PSDesiredStateConfiguration 2.x](https://www.powershellgallery.com/packages/PSDesiredStateConfiguration)
- Removing the dependency on MOF: Initially, only support DSC Resources written as PowerShell
  classes. This includes tooling to convert existing script based DSC Resources to be wrapped as
  PowerShell classes.

## Documentation and resources

The documentation for **PSDesiredStateConfiguration** 3.0.0-beta1 is a work-in-progress. We invite the
community to review the documentation and assist us as we work on new documentation during the platform
development.

For more information about DSC v3, see [PowerShell Desired State Configuration Overview](https://docs.microsoft.com/powershell/dsc/overview?view=dsc-3.0)

To download the latest release from the PowerShell Gallery, see [PSDesiredStateConfiguration 3.0.0-beta1](https://www.powershellgallery.com/packages/PSDesiredStateConfiguration/3.0.0-beta1)

## Community Feedback

As we continue this journey to make DSC a cross-platform technology, we invite the community to
share your ideas and open
[issues](https://github.com/PowerShell/PSDesiredStateConfiguration/issues). During the PowerShell
7.3 timeframe, we remain focused on enabling partner teams and will not be accepting public pull
requests.

## Build

### Requirements
- [Any recent PowerShell Core release](https://github.com/PowerShell/powershell/releases) to run the build script
- [.NET Core SDK](https://dotnet.microsoft.com/download/dotnet/thank-you/sdk-6.0.100-preview.4-windows-x64-binaries) of the version specified in `global.json` (`dotnet` should be visible through PATH env var)
- [`PSPackageProject` module](https://www.powershellgallery.com/packages/PSPackageProject) installed from PS Gallery

### Build Process
- Run `build.ps1 -Build -Clean`
- Compiled module will be in `./out/PSDesiredStateConfiguration`

## CI - Continuous Integration
CI pipeline definition is in `.vsts-ci\azure-pipelines-ci.yml` and running Compliance and Pester tests in `test\PSDesiredStateConfiguration.Tests.ps1` on Windows, Linux and Mac. CI builds are not signed.

## Publishing Releases
[The module is released on Powershell Gallery](https://www.powershellgallery.com/packages/PSDesiredStateConfiguration).
For a release the code of this repo is mirrored into an internal repo and `.vsts-ci\azure-pipelines-release.yml` pipeline is run. Release builds are signed.

## EOF

