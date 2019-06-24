# How to Create PSDesiredStateConfiguration NuGet package for PoweShell Core
- Modify psm1 file in PSDesiredStateConfiguration module.
 -- Remove the signature from the bottom of the file.
 -- Add your changes.
 -- Get it signed from DSC Azure dev ops pipeline.
     Following is the expected signing settings:
	<file src="__INPATHROOT__\Modules\PSDesiredStateConfiguration\PSDesiredStateConfiguration.psm1" signType="AuthenticodeFormer" dest="__OUTPATHROOT__\Modules\PSDesiredStateConfiguration\PSDesiredStateConfiguration.psm1" />

- Other files under PSDesiredStateConfiguration module doesn’t need to be signed, you can modify them directly.

- Change the version in nuget spec file.

- Check-in these changes in DesiredStateConfiguration repository.

- Create a NuGet package by running following command, it will generate NuGet package (PSDesiredStateConfiguration.6.2.0.nupkg). Get it published by PowerShell team.
	nuget pack .\psdesiredstateconfiguration.nuspec

# Modify PowerShell code to pick up new version of NuGet package.
 - Sync PowerShell/PowerShell repository and change NuGet package version in following files
        src/powershell-unix/powershell-unix.csproj
        src/powershell-win-core/powershell-win-core.csproj

```sh
   <ItemGroup>
-    <PackageReference Include="PSDesiredStateConfiguration" Version="6.0.0-beta.8" />
+    <PackageReference Include="PSDesiredStateConfiguration" Version="6.2.0" />
     <PackageReference Include="PowerShellHelpFiles" Version="1.0.0-*" />
   </ItemGroup>
```

- Send PR to PowerShell team