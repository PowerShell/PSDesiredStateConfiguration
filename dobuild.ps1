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
    
    Write-Verbose -Verbose -Message "Copying module files to '${OutDirectory}/${ModuleName}'"
    # copy psm1 and psd1 files
    copy-item "${SrcPath}/*" "${OutDirectory}/${ModuleName}" -Recurse

    # copy help
    # Write-Verbose -Verbose -Message "Copying help files to '${OutDirectory}/${ModuleName}'"
    # copy-item -Recurse "${HelpPath}/${Culture}" "${OutDirectory}/${ModuleName}"

    $subsystemCodePath = Resolve-Path "${SrcPath}\..\DscSubsystem"
    $subsystemBinPath = "bin/Debug/net6.0/publish/Microsoft.PowerShell.DscSubsystem.dll"
    Write-Verbose -Verbose -Message "Subsystem code path ${subsystemCodePath}"

    if ( Test-Path $subsystemCodePath )
    {
        Write-Verbose -Verbose -Message "Building assembly and copying to '${OutDirectory}/${ModuleName}'"
        
        Push-Location $subsystemCodePath
        $result = dotnet publish
        if (Test-Path $subsystemBinPath)
        {
            Copy-Item $subsystemBinPath "${OutDirectory}/${ModuleName}"
        }
        else
        {
            Write-Error "dotnet build failed - $subsystemBinPath not found - $result"
        }

        Pop-Location
    }
    else {
        Write-Verbose -Verbose -Message "No code to build in '$subsystemCodePath'"
    }

    ## Add build and packaging here
    Write-Verbose -Verbose -Message "Ending DoBuild"
}
