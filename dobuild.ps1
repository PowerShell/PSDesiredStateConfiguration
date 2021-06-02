# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#####################################################
# Do NOT edit anything outside the DoBuild function.
# You can define functions inside the scope of DoBuild.
#####################################################

<#
.DESCRIPTION
Implement build and packaging of the package and place the output $OutDirectory/$ModuleName
#>
function DoBuild
{
    Write-Verbose -Verbose -Message "Starting DoBuild"
    Write-Verbose -Verbose -Message "Make sure that 'nuget' and 'dotnet' are visible through PATH"
    
    Write-Verbose -Verbose -Message "Copying module files to '${OutDirectory}/${ModuleName}'"
    # copy psm1 and psd1 files
    copy-item "${SrcPath}/*" "${OutDirectory}/${ModuleName}" -Recurse

    $smaPackageVersionToUse = "7.2.0-preview.6" # 7.2.0-preview.6 - is the first SMA version that has DSC subsystem changes
    $subsystemCodePath = Resolve-Path "${SrcPath}/../DscSubsystem"
    Write-Verbose -Verbose -Message "Subsystem code path ${subsystemCodePath}"

    if ( Test-Path $subsystemCodePath )
    {
        Write-Verbose -Verbose -Message "Building assembly and copying to '${OutDirectory}/${ModuleName}'"
        
        Push-Location $subsystemCodePath

        $PackageReferencesPath = Join-Path $subsystemCodePath "PackageReferences"

        nuget install System.Management.Automation -OutputDirectory ./PackageReferences -PreRelease -Version $smaPackageVersionToUse -DependencyVersion Ignore -ExcludeVersion
        dotnet publish

        $subsystemBinPath = Join-Path (Get-ChildItem -Recurse "publish" -Directory) "Microsoft.PowerShell.DscSubsystem.dll"
        if (Test-Path $subsystemBinPath)
        {
            Copy-Item $subsystemBinPath "${OutDirectory}/${ModuleName}"
        }
        else
        {
            Write-Error -Message "dotnet build failed - $subsystemBinPath not found"
        }

        Pop-Location
    }
    else {
        Write-Error -Message "No code to build in '$subsystemCodePath'"
    }

    Write-Verbose -Verbose -Message "Ending DoBuild"
}
