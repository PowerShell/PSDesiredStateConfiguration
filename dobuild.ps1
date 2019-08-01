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
    #

    # copy help
    Write-Verbose -Verbose -Message "Copying help files to '${OutDirectory}/${ModuleName}'"
    copy-item -Recurse "${HelpPath}/${Culture}" "${OutDirectory}/${ModuleName}"

    if ( Test-Path "${SrcPath}/code" ) {
        Write-Verbose -Verbose -Message "Building assembly and copying to '${OutDirectory}/${ModuleName}'"
        # build code and place it in the staging location
        try {
            Push-Location "${SrcPath}/code"
            $result = dotnet publish
            copy-item "bin/Debug/netstandard2.0/publish/${ModuleName}.dll" "${OutDirectory}/${ModuleName}"
        }
        catch {
            $result | ForEach-Object { Write-Warning $_ }
            Write-Error "dotnet build failed"
        }
        finally {
            Pop-Location
        }
    }
    else {
        Write-Verbose -Verbose -Message "No code to build in '${SrcPath}/code'"
    }

    ## Add build and packaging here
    Write-Verbose -Verbose -Message "Ending DoBuild"
}
