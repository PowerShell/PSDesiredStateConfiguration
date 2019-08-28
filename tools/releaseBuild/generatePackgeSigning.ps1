# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
param(
    [Parameter(Mandatory)]
    [string] $Path,
    [string[]] $AuthenticodeDualFiles,
    [string[]] $AuthenticodeFiles,
    [string[]] $NuPkgFiles,
    [string[]] $MacDeveloperFiles,
    [string[]] $LinuxFiles,
    [Parameter(Mandatory)]
    [string] $rootPath
)

$resolvedRootPath = (Resolve-Path $rootPath).ProviderPath

if ((!$AuthenticodeDualFiles -or $AuthenticodeDualFiles.Count -eq 0) -and
    (!$AuthenticodeFiles -or $AuthenticodeFiles.Count -eq 0) -and
    (!$NuPkgFiles -or $NuPkgFiles.Count -eq 0) -and
    (!$MacDeveloperFiles -or $MacDeveloperFiles.Count -eq 0) -and
    (!$LinuxFiles -or $LinuxFiles.Count -eq 0))
{
    throw "At least one file must be specified"
}

function New-Attribute
{
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [object]$Value,
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]$Element
    )

    $attribute = $signingXml.CreateAttribute($Name)
    $attribute.Value = $value
    $null = $fileElement.Attributes.Append($attribute)
}

function New-FileElement
{
    param(
        [Parameter(Mandatory)]
        [string]$File,
        [Parameter(Mandatory)]
        [string]$SignType,
        [Parameter(Mandatory)]
        [System.Xml.XmlDocument]$XmlDoc,
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]$Job
    )

    if(Test-Path -Path $file)
    {
        $name = Split-Path -Leaf -Path $File
        $fileElement = $XmlDoc.CreateElement("file")
        $src = $file.replace($resolvedRootPath,'__INPATHROOT__\')
        $dest = $file.replace($resolvedRootPath,'__OUTPATHROOT__\')
        New-Attribute -Name 'src' -value $src -Element $fileElement
        New-Attribute -Name 'signType' -value $SignType -Element $fileElement
        New-Attribute -Name 'dest' -value $dest -Element $fileElement
        $null = $job.AppendChild($fileElement)
    }
    else
    {
        Write-Warning -Message "Skipping $SignType; $File because it does not exist"
    }
}

[xml]$signingXml = get-content (Join-Path -Path $PSScriptRoot -ChildPath 'packagesigning.xml')
$job = $signingXml.SignConfigXML.job

foreach($file in $AuthenticodeDualFiles)
{
    New-FileElement -File $file -SignType 'AuthenticodeDual' -XmlDoc $signingXml -Job $job
}

foreach($file in $AuthenticodeFiles)
{
    New-FileElement -File $file -SignType 'AuthenticodeFormer' -XmlDoc $signingXml -Job $job
}

foreach($file in $NuPkgFiles)
{
    New-FileElement -File $file -SignType 'NuGet' -XmlDoc $signingXml -Job $job
}

foreach ($file in $MacDeveloperFiles) {
    New-FileElement -File $file -SignType 'MacDeveloper' -XmlDoc $signingXml -Job $job
}

foreach ($file in $LinuxFiles) {
    New-FileElement -File $file -SignType 'LinuxPack' -XmlDoc $signingXml -Job $job
}

$null = new-item -Path $path -ItemType file -Force
$savePath = (Resolve-Path $Path).ProviderPath
$signingXml.Save($savePath)
#$updateScriptPath = Join-Path -Path $PSScriptRoot -ChildPath 'updateSigning.ps1'
#& $updateScriptPath -SigningXmlPath $path
