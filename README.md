# PSDesiredStateConfiguration module

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
