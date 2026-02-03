# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

function DoBuild
{
    Write-Verbose -Verbose -Message "Running DoBuild to layout module at: '${OutDirectory}/${ModuleName}'"
    Copy-Item "${SrcPath}/*" "${OutDirectory}/${ModuleName}" -Recurse
    Copy-Item -Recurse "${HelpPath}/${Culture}" "${OutDirectory}/${ModuleName}"
}

function DoPackage
{
    try {
        $repoName = [guid]::NewGuid().ToString()
        $modulePath = Join-Path $OutDirectory $ModuleName
        $null = Register-PSRepository -Name $repoName -InstallationPolicy Trusted -SourceLocation $OutDirectory

        Write-Verbose -Verbose -Message "Publishing module from: '$modulePath'"
        Publish-Module -Path $modulePath -Repository $repoName

        $nupkgPath = (Get-ChildItem -Path $OutDirectory -Filter "$ModuleName*.nupkg" | Select-Object -First 1).FullName
        Write-Verbose -Verbose -Message "Created package: $nupkgPath"
    }
    finally {
        Unregister-PSRepository -Name $repoName
    }
}
