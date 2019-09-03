&$PSScriptRoot/build.ps1 -Build -Clean
Write-Verbose -Message "Updating signing.xml ..." -Verbose
$files = @(Get-ChildItem $PSScriptRoot/out/*.ps* -Recurse | Select-Object -ExpandProperty FullName)
&$PSScriptRoot/tools/releaseBuild/generatePackgeSigning.ps1 -AuthenticodeFiles $files -path $PSScriptRoot/tools/releaseBuild/signing.xml -rootPath $PSScriptRoot/out/
Write-Verbose -Message "Done ..." -Verbose
# Make sure the file ends with an empty line
Add-Content -value '' -Path $PSScriptRoot/tools/releaseBuild/signing.xml
