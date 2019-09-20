###########################################################
#
#  'PSDesiredStateConfiguration' logic module
#
###########################################################
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
    CheckSumFileExists = File '{0}' already exists. Please specify -Force parameter to overwrite existing checksum files.
    CreateChecksumFile = Create checksum file '{0}'
    OverwriteChecksumFile = Overwrite checksum file '{0}'
    OutpathConflict = (ERROR) Cannot create directory '{0}'. A file exists with the same name.
    InvalidConfigPath = (ERROR) Invalid configuration path '{0}' specified.
    InvalidOutpath = (ERROR) Invalid OutPath '{0}' specified.
    InvalidConfigurationName = Invalid Configuration Name '{0}' is specified. Standard names may only contain letters (a-z, A-Z), numbers (0-9), and underscore (_). The name may not be null or empty, and should start with a letter.
    InvalidResourceSpecification = Found more than one resource named '{0}'. Please use the module specification to be more specific.
    UnsupportedResourceImplementation = The resource '{0}' implemented as '{1}' is not supported by Invoke-DscResource.
    NoValidConfigFileFound = No valid config files (mof,zip) were found.
    InputFileNotExist=File {0} doesn't exist.
    FileReadError=Error Reading file {0}.
    MatchingFileNotFound=No matching file found.
    CertificateFileReadError=Error Reading certificate file {0}.
    CertificateStoreReadError=Error Reading certificate store for {0}.
    CannotCreateOutputPath=Invalid Configuration name and output path combination :{0}. Please make sure output parameter is a valid path segment.
    ConflictingDuplicateResource=A conflict was detected between resources '{0}' and '{1}' in node '{2}'. Resources have identical key properties but there are differences in the following non-key properties: '{3}'. Values '{4}' don't match values '{5}'. Please update these property values so that they are identical in both cases.
    ConfiguratonDataNeedAllNodes=ConfigurationData parameter need to have property AllNodes.
    ConfiguratonDataAllNodesNeedHashtable=ConfigurationData parameter property AllNodes needs to be a collection.
    AllNodeNeedToBeHashtable=all elements of AllNodes need to be hashtable and has a property 'NodeName'.
    DuplicatedNodeInConfigurationData=There are duplicated NodeNames '{0}' in the configurationData passed in.
    EncryptedToPlaintextNotAllowed=Converting and storing encrypted passwords as plain text is not recommended. For more information on securing credentials in MOF file, please refer to MSDN blog: http://go.microsoft.com/fwlink/?LinkId=393729
    DomainCredentialNotAllowed=It is not recommended to use domain credential for node '{0}'. In order to suppress the warning, you can add a property named 'PSDscAllowDomainUser' with a value of $true to your DSC configuration data for node '{0}'.
    NestedNodeNotAllowed=Defining node '{0}' inside the current node '{1}' is not allowed since node definitions cannot be nested. Please move the definition for node '{0}' to the top level of the configuration '{2}'.
    FailToProcessNode=An exception was raised while processing Node '{0}': {1}
    LocalHostNodeNotAllowed=Defining a 'localhost' node in the configuration '{0}' is not allowed since the configuration already contains one or more resource definitions that are not associated with any nodes.
    InvalidMOFDefinition=Invalid MOF definition for node '{0}': {1}
    RequiredResourceNotFound=Resource '{0}' required by '{1}' does not exist. Please ensure that the required resource exists and the name is properly formed.
    ReferencedManagerNotFound=Download Manager '{0}' referenced by '{1}' does not exist. Please ensure that the referenced download manager exists and the name is properly formed.
    ReferencedResourceSourceNotFound=Resource Repository '{0}' referenced by '{1}' does not exist. Please ensure that the referenced resource repository exists and the name is properly formed.
    DependsOnLinkTooDeep=DependsOn link exceeded max depth limitation '{0}'.
    DependsOnLoopDetected=Circular DependsOn exists '{0}'. Please make sure there are no circular reference.
    FailToProcessConfiguration=Errors occurred while processing configuration '{0}'.
    FailToProcessProperty={0} error processing property '{1}' OF TYPE '{2}': {3}
    NodeNameIsRequired=Node processing is skipped since the node name is empty.
    ConvertValueToPropertyFailed=Cannot convert '{0}' to type '{1}' for property '{2}' in resource '{3}'.
    ResourceNotFound=The term '{0}' is not recognized as the name of a {1}.
    GetDscResourceInputName=The Get-DscResource input '{0}' parameter value is '{1}'.
    ResourceNotMatched=Skipping resource '{0}' as it does not match the requested name.
    InitializingClassCache=Initializing class cache
    LoadingDefaultCimKeywords=Loading default CIM keywords
    GettingModuleList=Getting module list
    CreatingResourceList=Creating resource list
    CreatingResource=Creating resource '{0}'.
    SchemaFileForResource=Schema file name for resource {0}
    UnsupportedReservedKeyword=The '{0}' keyword is not supported in this version of the language.
    UnsupportedReservedProperty=The '{0}' property is not supported in this version of the language.
    MetaConfigurationHasMoreThanOneLocalConfigurationManager=The meta configuration for node '{0}' contain more than one definitions for LocalConfigurationManager which is not allowed.
    MetaConfigurationSettingsMissing=The settings definition for node '{0}' is missing. A default empty settings definition is added for the node.
    ConflictInExclusiveResources=The partial configuration '{0}' and '{1}' have coflicting exclusive resource declarations.
    ReferencedModuleNotExist=The referenced module '{0}' does not exist on the machine. Please use Get-DscResource to find out what exists on the machine.
    ReferencedResourceNotExist=The referenced resource '{0}' does not exist on the machine. Please use Get-DscResource to find out what exists on the machine.
    ReferencedModuleResourceNotExist=The referenced module\resource '{0}' does not exist on the machine. Please use Get-DscResource to find out what exists on the machine.
    DuplicatedResourceInModules=The referenced resource '{0}' exists in module {1} and module {2} on the machine. Please make sure it exists in only one module.
    CannotConvertStringToBool=Cannot convert value "System.String" to type "System.Boolean". Boolean parameters accept only Boolean values and numbers, such as $True, $False, 1 or 0.
    NoModulesPresent=There are no modules present in the system with the given module specification.
    ImportDscResourceWarningForInbuiltResource=The configuration '{0}' is loading one or more built-in resources without explicitly importing associated modules. Add Import-DscResource -ModuleName 'PSDesiredStateConfiguration' to your configuration to avoid this message.
    PasswordTooLong=An error occurred during encryption of a password in node '{0}'. Most likely the password entered is too long to be encrypted using the selected certificate.  Please either use a shorter password or select a certificate with a larger key.
    PsDscRunAsCredentialNotSupport=The 'PsDscRunAsCredential' property is not currently support when using Invoke-DscResource.
    EmbeddedResourcesNotSupported=Embedded resources are not support on Linux or macOS.  Please see https://aka.ms/PSCoreDSC for more details.
'@
}
Set-StrictMode -Off

# In case localized resource is not available we revert back to English as defined in LocalizedData section so ignore the error instead of showing it to user.
Import-LocalizedData  -BindingVariable LocalizedData -FileName PSDesiredStateConfiguration.Resource.psd1 -ErrorAction SilentlyContinue

Import-Module $PSScriptRoot/helpers/DscResourceInfo.psm1

# Set DSC HOME environment variable.
$env:DSC_HOME = "$PSScriptRoot/Configuration"

$script:V1MetaConfigPropertyList = @('ConfigurationModeFrequencyMins', 'RebootNodeIfNeeded', 'ConfigurationMode', 'ActionAfterReboot', 'RefreshMode', 'CertificateID', 'ConfigurationID', 'DownloadManagerName', 'DownloadManagerCustomData', 'RefreshFrequencyMins', 'AllowModuleOverwrite', 'DebugMode', 'Credential')
$script:DirectAccessMetaConfigPropertyList = @('AllowModuleOverWrite', 'CertificateID', 'ConfigurationDownloadManagers', 'ResourceModuleManagers', 'DebugMode', 'RebootNodeIfNeeded', 'RefreshMode', 'ConfigurationAgent')

#################################################################
# Code to determin what version related info is needed
# and fixup the configuration document is it is already generated
#################################################################
function Generate-VersionInfo
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope="Function", Target="*")]
    param(
        [Parameter(Mandatory)]
        $KeywordData,
        [Parameter(Mandatory)]
        [Hashtable]
        $Value
    )

    $SystemProperties = @('ResourceID', 'SourceInfo', 'ModuleName', 'ModuleVersion')
    $HasAdditionalProperty = $false
    foreach ($key in $KeywordData.Keys)
    {
        if (($Value.Contains($key)) -and ($script:V1MetaConfigPropertyList -notcontains $key) -and ($SystemProperties -notcontains $key))
        {
            $HasAdditionalProperty = $true
            break
        }
    }

    if($HasAdditionalProperty)
    {
        Set-PSMetaConfigVersionInfoV2
    }
    else
    {
        $script:PSMetaConfigDocumentInstVersionInfo['MinimumCompatibleVersion'] = ($script:PSMetaConfigDocumentInstVersionInfo['MinimumCompatibleVersion'], "1.0.0" | Measure-Object -Maximum).Maximum
    }

    $script:PSMetaConfigDocumentInstVersionInfo['CompatibleVersionAdditionalProperties'] = @('MSFT_DSCMetaConfiguration:StatusRetentionTimeInDays')
    $script:PSMetaConfigurationProcessed = $true
}

# indicate whether meta configuration is processed before document instance
function Set-PSMetaConfigDocInsProcessedBeforeMeta
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    param()
    $Script:PSMetaConfigDocInsProcessedBeforeMeta = $true
}

function Get-PSMetaConfigurationProcessed
{
    return $script:PSMetaConfigurationProcessed
}

function Get-PSMetaConfigDocumentInstVersionInfo
{
    return $script:PSMetaConfigDocumentInstVersionInfo
}

function Set-PSMetaConfigVersionInfoV2
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    param()
    $script:PSMetaConfigDocumentInstVersionInfo['MinimumCompatibleVersion'] = '2.0.0'
    if($Script:PSMetaConfigDocInsProcessedBeforeMeta) #fixup configuration document instance version info
    {
        [string]$data = Get-MofInstanceText '$OMI_ConfigurationDocument1ref'
        $Script:NoNameNodeInstanceAliases['$OMI_ConfigurationDocument1ref'] = $data -replace 'MinimumCompatibleVersion = "1.0.0"', 'MinimumCompatibleVersion = "2.0.0"'
        Set-PSDefaultConfigurationDocument $Script:NoNameNodeInstanceAliases['$OMI_ConfigurationDocument1ref']
    }
}

function Get-CompatibleVersionAddtionaPropertiesStr
{
    '{'
    if($script:PSMetaConfigDocumentInstVersionInfo['CompatibleVersionAdditionalProperties'])
    {
        $len = @($script:PSMetaConfigDocumentInstVersionInfo['CompatibleVersionAdditionalProperties']).Length
        foreach ($e in @($script:PSMetaConfigDocumentInstVersionInfo['CompatibleVersionAdditionalProperties']))
        {
                "`"$e`"" + $(if (--$len -gt 0)
                {
                    ', '
                }
                else
                {
                    ''
                }
            )
        }
    }
    '}'
}

###########################################################
# The MOF generation code
###########################################################

#
# This scriptblock takes a type name and a list of properties and produces
# the MOF source text to define an instance of that type
#
function ConvertTo-MOFInstance
{
    param (
        [Parameter(Mandatory)]
        [string]
        $Type,
        [Parameter(Mandatory)]
        [AllowNull()]
        [hashtable]
        $Properties
    )


    # remove ModuleVersion, this will be handled during final validation.
    if($properties.ContainsKey('ModuleName') -and  $properties['ModuleName'] -ieq 'PsDesiredStateConfiguration')
    {
        $script:PsDscModuleVersion = $properties['ModuleVersion']
        $properties.Remove('ModuleVersion')
    }
    if($properties.ContainsKey('PsDscRunAsCredential'))
    {
        $script:PsDscCompatibleVersion = "2.0.0"
    }
    # Look up the property definitions for this keyword.
    $PropertyTypes = [System.Management.Automation.Language.DynamicKeyword]::GetKeyword($Type).Properties

    # and the CIM type name to use since the keyword might be an alias.
    $ResourceName = [System.Management.Automation.Language.DynamicKeyword]::GetKeyword($Type).ResourceName

    if($script:IsMetaConfig -and ($ResourceName -eq 'MSFT_DSCMetaConfigurationV2'))
    {
        Generate-VersionInfo $PropertyTypes $Properties
    }

    #
    # Function to convert .NET datetime object to MOF datetime string format
    # We're not using [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime()
    # because it has known bugs which are not going to be fixed.
    #
    function ConvertTo-MofDateTimeString ([datetime] $d)
    {
        $utcOffset = ($d -$d.ToUniversalTime()).TotalMinutes
        $utcOffsetString = if ($utcOffset -ge 0)
        {
            '+'
        }
        else
        {
            '-'
        }
        $utcOffsetString += ([System.Math]::Abs(($utcOffset)).ToString().PadLeft(3,'0'))
        '{0}{1}' -f
        $d.ToString('yyyyMMddHHmmss.ffffff'),
        $utcOffsetString
    }

    #
    # Utility routine to find if username specified is
    # a domain user.
    #

    function IsDomainUser()
    {
        param(
            [Parameter(Mandatory)]
            [string]
            $UserName
        )
        # if username contains '\' example: domain\username or '@' example: username@mydomain.com
        # it may not be a local user.
        if( -not( $UserName.Contains('\') -or $UserName.Contains('@')))
        {
            # it is a local user
            return $false
        }
        elseif( $UserName.Contains('@'))
        {
            return $true
        }
        else
        {
            # In case of '\', domain name can be local machine.
            $result = $UserName.Split('\')
            if( $result.Count -ge 2)
            {
                $domain = $result[0]
                $localMachineNames = @("localhost","127.0.0.1","::1")
                $isDomainUser = $true
                if( $localMachineNames -icontains $domain)
                {
                    $isDomainUser = $false
                }
                return $isDomainUser
            }
        }
        $true
    }

    #
    # Utility routine to render a property
    # as a string in MOF syntax.
    #
    function stringify ($Value, $asArray = $false, $targetType = [string])
    {
        $result = if ($Value -is [array] -or $asArray)
        {
            '{'
            $len = @($Value).Length
            foreach ($e in $Value)
            {
                '    ' + (stringify $e -targetType $targetType) +
                $(if (--$len -gt 0)
                    {
                        ','
                    }
                    else
                    {
                        ''
                    }
                )
            }
            '}'
        }
        elseif ($Value -is [PSCredential] )
        {
            # If the input object is a PSCredential, turn it into an MSFT_Credential with an encrypted password.
            $clearText = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::GetStringFromSecureString($Value.Password)
            $newValue = @{
                UserName = $Value.UserName
                Password = $clearText
            }
            # Recurse to build the object.
            ConvertTo-MOFInstance MSFT_Credential $newValue
        }
        elseif ($Value -is [System.Collections.Hashtable])
        {
            # Collect the individual strings
            $elementsAsStrings = foreach ($p in $Value.GetEnumerator())
            {
                ConvertTo-MOFInstance MSFT_KeyValuePair @{
                    Key   = $p.Key
                    Value = $p.Value
                }
            }
            # Produce a single formatted string.
            '   ' + ($elementsAsStrings -join ",`n   ") + "`n"
        }
        elseif ($Value -is [ScriptBlock] )
        {
            # Find all $using: variables used in the script and replace them with normal variables
            $scriptText = "$Value"
            # Need to create a new scriptblock so the extent offsets are correct
            $scriptAst = [scriptblock]::Create($scriptText).Ast
            # get the $using: variable asts into an array
            $variables = $scriptAst.FindAll({
                    param ($ast)
                    $ast.GetType().FullName -match 'VariableExpressionAst' -and
                    $ast.Extent.Text -match '^\$using:'
                }
            , $true).ToArray()

            # do the substitutions in reverse order
            [Array]::Reverse($variables)
            $variables | ForEach-Object -Process {
                $start = $_.Extent.StartOffset
                $length = $_.Extent.EndOffset - $start
                $newName = '$' + $_.VariablePath.UserPath
                $scriptText = $scriptText.Remove($start, $length).Insert($start, $newName)
            }

            $completeScript = ''
            # generate assignement statements to set the variable values on the other side
            # using serialized values passed from the local environment
            $varNames = @($variables).VariablePath.UserPath | Sort-Object -Unique
            foreach ($v in $varNames)
            {
                # If the ScriptBlock was defined in a module, then use the module for lookups
                if ($Value.Module)
                {
                    $var = $Value.Module.SessionState.PSVariable.Get($v)
                }
                else
                {
                    # Otherwise look up in the callers context
                    $var = $ExecutionContext.SessionState.Module.GetVariableFromCallersModule($v)
                }

                if ($var)
                {
                    $varValue = $var.Value
                    # Skip null values but preserve empty arrays and strings for type propigation
                    if ($null -ne $varValue)
                    {
                        # Pass strings quoted; amn explicit type check is needed because -is recognizes too many things as strings
                        if ($varValue -is [string])
                        {
                            $completeScript += "`$$v ='" + ($varValue -replace "'", "''") + "'`n"
                        }
                        else
                        {
                            # Serialize everything else
                            $serializedValue = [System.Management.Automation.PSSerializer]::Serialize($varValue) -replace "'", "''"
                            $completeScript += "`$$v = [System.Management.Automation.PSSerializer]::Deserialize('$serializedValue')`n"
                        }
                    }
                }
            }

            # Merge in the actual scriptblock body
            $completeScript += $scriptText

            # Quote the string so it's suitable to embed in the MOF file...
            '"' + ($completeScript -replace '\\', '\\' -replace "[`r]*`n", '\n'  -replace '"', '\"') + '"'
        }
        elseif ($targetType -eq [datetime])
        {
            # If the target is a datetime, convert the argument to a datetime and then render that
            # as a DMTF datetime...
            '"' + (ConvertTo-MofDateTimeString $Value) + '"'
        }
        elseif ($targetType -eq [double])
        {
            # MOF syntax requires reals to always have a decimal point so add
            # so add one if the string representation does contain one.
            [string] $dblAsString = [double] $Value
            if ( -not $dblAsString.Contains('.') )
            {
                $dblAsString += '.0'
            }
            $dblAsString
        }
        elseif ($targetType -eq [char])
        {
            # A char16 is encode as a single quoted character
            "'$Value'"
        }
        elseif ($targetType -eq [int64])
        {
            [int64] $Value
        }
        elseif ($targetType -eq [uint64])
        {
            [uint64] $Value
        }
        elseif ($targetType -eq [bool])
        {
            if($Value -is [string])
            {
                $errorMessage = $LocalizedData.CannotConvertStringToBool
                ThrowError -ExceptionName 'System.ArgumentException' -ExceptionMessage $errorMessage -ExceptionObject $Value -ErrorId 'CannotConvertStringToBool' -ErrorCategory InvalidArgument
            }
            else
            {
                [bool]$Value
            }
        }
        elseif ($targetType -ne [string])
        {
            # Cast the value to the target type...
            $Value -as $targetType
        }
        elseif ($Value -is [string] -and -not $InstanceAliases[$Value] )
        {
            '"' + ($Value -replace '\\', '\\' -replace "`r?`n", '\n'  -replace '"', '\"') + '"'
        }
        elseif ($null -eq $Value)
        {
            'NULL'
        }
        elseif (($targetType -eq [string]) -and  ($Value -isnot [string]))
        {
            # Cast value to string if it is not already a string, this is for covering cases like when a user assign an integer while the
            # CIM property type is string
            '"' + ($Value -replace '\\', '\\' -replace "`r?`n", '\n'  -replace '"', '\"') + '"'
        }
        else
        {
            $Value
        }

        $result -join "`n"
    }

    Write-Debug -Message "        BEGIN MOF GENERATION FOR $Type"

    # Generate the MOF instance alias to use for the current node
    if ( (Get-PSCurrentConfigurationNode) )
    {
        if($null -eq $Script:NodeTypeRefCount[ (Get-PSCurrentConfigurationNode) ])
        {
            $Script:NodeTypeRefCount[ (Get-PSCurrentConfigurationNode) ] =
            New-Object -TypeName 'System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string,int]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
        }

        $MofAliasString = '$' + $ResourceName + ++$Script:NodeTypeRefCount[ (Get-PSCurrentConfigurationNode) ][$ResourceName] + 'ref'
        $InstanceAliases = $Script:NodeInstanceAliases[ (Get-PSCurrentConfigurationNode) ]
    }
    else #  Generate the MOF instance alias to use for the default (unnamed) node.
    {
        $MofAliasString = '$' + $ResourceName + ++$Script:NoNameNodeTypeRefCount[$ResourceName] + 'ref'
        $InstanceAliases = $Script:NoNameNodeInstanceAliases
    }

    # Start generating the MOF source text for this instance
    $result = "instance of $ResourceName as $MofAliasString`n{`n"

    #special case psdesiredstateConfiguration module. Insert '0.0' as module if user hasn't explicilty asked for the version
    if( $Properties.ContainsKey("ModuleName") -and ($Properties["ModuleName"] -ieq 'PsDesiredStateConfiguration'))
    {
        if(-not $Script:ExplicitlyImportedModules.ContainsKey('PsDesiredStateConfiguration'))
        {
            $script:ShowImportDscResourceWarning = $true
        }
    }

    # generate the property definitions
    $oldOFS = $OFS
    $OFS = ' '
    $result += try
    {
        if ($Properties -and $Properties.Count)
        {
            foreach ($p in $Properties.GetEnumerator())
            {
                Write-Debug -Message "          Generating property data for '$($p.Name)' = '$($p.Value)'"
                $targetTypeName = $PropertyTypes[$p.Name].TypeConstraint

                # see if the target type is an array
                $asArray = $p.Name -eq 'DependsOn' -or $targetTypeName -match 'Array'

                # Convert the CIM typename to the appropriate .NET type to use
                # to convert the input object into an appropriately encoded string
                # using the PowerShell type conversion semantics.
                switch -regex ($targetTypeName)
                {
                    # unsigned integer types
                    '^sint[0-9]{1,2}'
                    {
                        $targetType = [int64]
                        break
                    }
                    # Single 16 bit character (note - this type is deprecated and removed in MOFv3
                    '^char16'
                    {
                        $targetType = [char]
                        break
                    }
                    # signed integer types
                    '^uint[0-9]{0,2}'
                    {
                        $targetType = [uint64]
                        break
                    }
                    # reals
                    '^real32|^real64'
                    {
                        $targetType = [double]
                        break
                    }
                    # boolean
                    '^boolean'
                    {
                        $targetType = [bool]
                    }
                    # datetime
                    'datetime'
                    {
                        $targetType = [datetime]
                    }
                    # everything else render directly as a string...
                    default
                    {
                        $targetType = [string]
                    }
                }

                #
                # If the scalar target types is a credential, then we need to encrypt the Password property value
                # before generating the MOF text
                #
                if(($Type -match 'MSFT_Credential') -and $p.Name -match 'Password')
                {
                    # For MSFT_Credential we'll have a password that may need to be encrypted depending
                    # on the availability of a key. This may need to change to the base class of MSFT_WindowCredential
                    # if we're using the class to refer to non-Windows machines where a Domain may be irrelevant.

                    $p.Name + ' = ' + (stringify -value (Get-EncryptedPassword $p.Value) -asArray $asArray -targetType  $targetType ) + ";`n"
                }
                else
                {
                    #embeded instances cannot be null
                    if($null -eq $p.Value -and $PropertyTypes[$p.Name].TypeConstraint -eq 'Instance')
                    {
                        $errorMessage = $LocalizedData.ConvertValueToPropertyFailed -f @('$null', $Type, $p.Name, $ResourceName)
                        $errorMessage += Get-PositionInfo $Properties['SourceInfo']
                        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                        Write-Error -Exception $exception -Message $errorMessage  -Category InvalidArgument -ErrorId FailToProcessProperty
                        Update-ConfigurationErrorCount
                    }
                    if($p.Value -is [PSCredential])
                    {
                        [bool] $PSDscAllowPlainTextPassword = $false
                        [bool] $PSDscAllowDomainUser = $false
                        [bool] $PSDscDomainUser = IsDomainUser -username $p.Value.UserName


                        if($Node -and $selectedNodesData)
                        {
                            if($selectedNodesData -is [array])
                            {
                                foreach($target in $selectedNodesData)
                                {
                                    if($target['NodeName'] -and $target['NodeName'] -eq $Node)
                                    {
                                        $currentNode = $target
                                    }
                                }
                            }
                            else
                            {
                                $currentNode = $selectedNodesData
                            }
                        }
                        # where user need to specify properties for resources not in a node,
                        # they can do it through localhost nodeName in $allNodes
                        elseif($allnodes -and $allnodes.AllNodes)
                        {
                            foreach($target in $allnodes.AllNodes)
                            {
                                if($target['NodeName'] -and $target['NodeName'] -eq 'localhost')
                                {
                                    $currentNode = $target
                                }
                            }
                        }

                        if($currentNode)
                        {
                            # PSDscAllowDomainUser set to true would indicate that we want to allow
                            # domain credential. It takes precedence over PSDscAllowPlainTextPassword behavior
                            if($currentNode['PSDscAllowDomainUser'])
                            {
                                $PSDscAllowDomainUser = $currentNode['PSDscAllowDomainUser']
                            }
                            if($PSDscDomainUser -and (-not $PSDscAllowDomainUser))
                            {
                                if($null -eq $Script:NodeUsingDomainCred)
                                {
                                    $Script:NodeUsingDomainCred = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,bool]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                                }
                                $Script:NodeUsingDomainCred[$currentNode['NodeName']] = $true
                            }
                            # PSDscAllowPlainTextPassword set to true would indicate that we want to allow the
                            # automatic conversion of the encrypted password to plaintext if a certificate or
                            # certificate id is not specified.
                            # if a certid or cert file is specified, it taks precedence over PSDscAllowPlainTextPassword
                            if($currentNode['PSDscAllowPlainTextPassword'])
                            {
                                $PSDscAllowPlainTextPassword = $currentNode['PSDscAllowPlainTextPassword']
                            }

                            $certificateid = $currentNode['CertificateID']

                            if ( -not $certificateid)
                            {
                                # CertificateFile is the public key file
                                $certificatefile = $currentNode['CertificateFile']

                                if (( -not $certificatefile) -and (-not $PSDscAllowPlainTextPassword))
                                {
                                    $errorMessage = $($LocalizedData.EncryptedToPlaintextNotAllowed)
                                    ThrowError -ExceptionName 'System.InvalidOperationException' -ExceptionMessage $errorMessage -ExceptionObject $p -ErrorId 'InvalidPathSpecified' -ErrorCategory InvalidOperation
                                }
                            }

                            if($currentNode['NodeName'] -and ($certificatefile -or $certificateid))
                            {
                                $Script:NodesPasswordEncrypted[$currentNode['NodeName']] = $true
                            }

                            $p.Name + ' = ' + (stringify -value $p.Value -asArray $asArray -targetType  $targetType ) + ";`n"
                        }
                        else
                        {
                            $errorMessage = $($LocalizedData.EncryptedToPlaintextNotAllowed)
                            ThrowError -ExceptionName 'System.InvalidOperationException' -ExceptionMessage $errorMessage -ExceptionObject $p -ErrorId 'InvalidPathSpecified' -ErrorCategory InvalidOperation
                        }
                    }
                    else
                    {
                        if ($targetTypeName -notmatch 'Array' -or $p.Value.Count)
                        {
                            $p.Name + ' = ' + (stringify -value $p.Value -asArray $asArray -targetType  $targetType ) + ";`n"
                        }
                    }
                }
            }
        }
        else
        {
            if ($Type -notmatch 'OMI_ConfigurationDocument')
            {
                "// This instance definition of $Type had no properties`n"
            }
            Write-Debug -Message "          ENCOUNTERED INSTANCE OF TYPE '$Type' WITH NO PROPERTIES"
        }
    }
    catch
    {
        $errorMessage = $_.Exception.Message + (Get-PositionInfo $Properties['SourceInfo'])
        $errorMessage = $LocalizedData.FailToProcessProperty -f @($_.Exception.GetType().FullName, $p.Name, $Type, $errorMessage)
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId FailToProcessProperty
        Update-ConfigurationErrorCount
    }
    finally
    {
        $OFS = $oldOFS
    }

    #
    # Add extra information about Author, GenerationHost, GenerationDate and Name if they are not specified
    #
    if ($Type -match 'OMI_ConfigurationDocument' -and $Properties)
    {
        if (-not $Properties.ContainsKey('Author'))
        {
            $result += " Author = `"$([system.environment]::UserName)`";`n"
        }

        if (-not $Properties.ContainsKey('GenerationDate'))
        {
            $result += " GenerationDate = `"$(Get-Date)`";`n"
        }

        if (-not $Properties.ContainsKey('GenerationHost'))
        {
            $result += " GenerationHost = `"$([system.environment]::MachineName)`";`n"
        }

        # todo: report error is configuration name does't match
        if (-not $Properties.ContainsKey('Name'))
        {
            $result += " Name = `"$(Get-PSTopConfigurationName)`";`n"
        }
    }

    #
    # Append the completed mof instance text to the overall document
    #
    $instanceText = "`n" + $result + "`n};`n"

    #
    # Record and return the alias for that document
    #
    Write-Debug -Message "          Added alias $MofAliasString to InstanceAliases array for node '$(Get-PSCurrentConfigurationNode)'"

    if ( Get-PSCurrentConfigurationNode )
    {
        if($null -eq $Script:NodeInstanceAliases[ (Get-PSCurrentConfigurationNode) ])
        {
            $Script:NodeInstanceAliases[ (Get-PSCurrentConfigurationNode) ] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
            $Script:NodeResourceIdAliases[ (Get-PSCurrentConfigurationNode) ] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
        }

        $Script:NodeInstanceAliases[ (Get-PSCurrentConfigurationNode) ][$MofAliasString] = $instanceText

        if($Properties.ContainsKey('ResourceID'))
        {
            $Script:NodeResourceIdAliases[ (Get-PSCurrentConfigurationNode) ][$Properties['ResourceID']] = $MofAliasString
        }
    }
    else
    {
        $Script:NoNameNodeInstanceAliases[$MofAliasString] = $instanceText

        if($Properties.ContainsKey('ResourceID'))
        {
            $Script:NoNameNodeResourceIdAliases[$Properties['ResourceID']] = $MofAliasString
        }
    }

    # todo: we can check error for duplicated alias in a node and report it here
    # because this can live acrose configurationelement calls
    Write-Debug -Message "        MOF GENERATION COMPLETED FOR $Type"
    $MofAliasString
}

#
#
# Returns the MOF text for the instance that
# corresponds to the aliasId
#
function Get-MofInstanceText
{
    param (
        [Parameter(Mandatory)]
        [string]
        $aliasId
    )

    if ( Get-PSCurrentConfigurationNode )
    {
        $Script:NodeInstanceAliases[ (Get-PSCurrentConfigurationNode) ][$aliasId]
    }
    else
    {
        $Script:NoNameNodeInstanceAliases[$aliasId]
    }
}

#
# Get the position message based on the SourceMetadata
#
function Get-PositionInfo
{
    param(
        [string]
        $sourceMetadata
    )

    $positionMessage = ''
    if ($sourceMetadata)
    {
        $positionMessage = "`nAt"
        $infoItems = $sourceMetadata -split '::'

        # File name may be empty
        if ($infoItems[0])
        {
            $positionMessage += " $($infoItems[0]):$($infoItems[1])"
        }
        else
        {
            $positionMessage += " line:$($infoItems[1])"
        }

        $positionMessage += " char:$($infoItems[2])"
        $positionMessage += "`n+   $($infoItems[3])"
    }

    $positionMessage
}


###################################################################################
#
# A function that implements the 'Node' keyword logic. The Node keyword accumulates
# the resource instances to define for a specific node or nodes. It's passed into the
# configuration statement using the ScriptBlock.InvokeWithContext() method
#
function Node
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPositionalParameters", "", Scope="Function", Target="*")]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        $KeywordData,       # Not used in this function....
        [string[]]
        $Name,              # the list of nodes to process in this call
        [Parameter(Mandatory)]
        [ScriptBlock]
        $Value,             # The scriptblock that generates the configuration in each node.
        [Parameter(Mandatory)]
        $sourceMetadata     # Not used in this function
    )


    if (-not $Name)
    {
        Write-Debug -Message 'The name parameter was empty, no nodes generated'
        return
    }

    Write-Debug -Message "*PROCESSING STARTED FOR NODE SET {$(@($Name) -join ',')} "

    # Save any global level resources and initialize for the resources defined for this node.
    $Script:PSOuterConfigurationNodes.Push( (Get-PSCurrentConfigurationNode) )
    $OldNodeResources = $Script:NodeResources
    $OldNodeKeys = $Script:NodeKeys

    try
    {
        $OuterNode = $Script:PSOuterConfigurationNodes.Peek()
        if(( $OuterNode -eq [string]::Empty) -or
        (($OuterNode -ne [string]::Empty) -and ($Name -contains $OuterNode)))
        {
            #
            # Set up a map from node name to data
            #
            $nodeDataMap = @{}

            #
            # Copy the AllNodes data into the map
            #

            if($script:ConfigurationData)
            {
                $script:ConfigurationData.AllNodes | ForEach-Object -Process {
                    $nodeDataMap[$_.NodeName] = $_
                }
            }

            #
            # Create the SelectedNodes list for this Node statement
            #
            $selectedNodesData = foreach ($nn in $Name)
            {
                # If there is no data for this node, create a dummy node
                # with at least the node name
                if ( -not $nodeDataMap[$nn] )
                {
                    $nodeDataMap[$nn] = @{
                        NodeName = $nn
                    }
                }
                $nodeDataMap[$nn]
            }

            foreach ($Node in $Name)
            {
                if(($OuterNode -ne [string]::Empty) -and ($OuterNode -ne $Node))
                {
                    continue
                }

                Set-PSCurrentConfigurationNode $Node

                if( $Script:NodesInThisConfiguration[$Node] )
                {
                    $Script:NodeResources = $Script:NodesInThisConfiguration[$Node]
                }
                else
                {
                    $Script:NodesInThisConfiguration[$Node] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,[string[]]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                    $Script:NodeResources = $Script:NodesInThisConfiguration[$Node]
                }

                #this for tracking referenced configuration managers
                if( $Script:NodesManagerInThisConfiguration[$Node] )
                {
                    $Script:NodeManager = $Script:NodesManagerInThisConfiguration[$Node]
                }
                else
                {
                    $Script:NodesManagerInThisConfiguration[$Node] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                    $Script:NodeManager = $Script:NodesManagerInThisConfiguration[$Node]
                }

                #this for tracking exclusive resources
                if( $Script:NodesExclusiveResourcesInThisConfiguration[$Node] )
                {
                    $Script:NodeExclusiveResources = $Script:NodesExclusiveResourcesInThisConfiguration[$Node]
                }
                else
                {
                    $Script:NodesExclusiveResourcesInThisConfiguration[$Node] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                    $Script:NodeExclusiveResources = $Script:NodesExclusiveResourcesInThisConfiguration[$Node]
                }

                #this for tracking referenced Resource Module Source
                if( $Script:NodesResourceSourceInThisConfiguration[$Node] )
                {
                    $Script:NodeResourceSource = $Script:NodesResourceSourceInThisConfiguration[$Node]
                }
                else
                {
                    $Script:NodesResourceSourceInThisConfiguration[$Node] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                    $Script:NodeResourceSource = $Script:NodesResourceSourceInThisConfiguration[$Node]
                }

                if(-not $Script:NodeTypeRefCount[$Node])
                {
                    $Script:NodeTypeRefCount[$Node] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string,int]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                    $Script:NodeInstanceAliases[$Node] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string,string]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                    $Script:NodeResourceIdAliases[$Node] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string,string]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                }

                if(-not $script:NodesKeysInThisConfiguration[$Node])
                {
                    $script:NodesKeysInThisConfiguration[$Node] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.HashSet[string]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                }
                $Script:NodeKeys = $script:NodesKeysInThisConfiguration[$Node]

                #
                # Set up the context variable list.
                #
                $variablesToDefine = @(
                    New-Object -TypeName PSVariable -ArgumentList ('SelectedNodes', $selectedNodesData)
                    New-Object -TypeName PSVariable -ArgumentList ('Node', $nodeDataMap[$Node])
                    New-Object -TypeName PSVariable -ArgumentList ('NodeName', $Node)
                )

                # Initialize dictionary to detect duplicate resources
                if ($null -eq $Script:DuplicateResources)
                {
                    $Script:DuplicateResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[System.Collections.Hashtable]]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                }

                if (-not $Script:DuplicateResources.ContainsKey($Name))
                {
                    $Script:DuplicateResources[$Name] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[System.Collections.Hashtable]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                }

                try
                {
                    # Evaluate the node's business logic scriptblock
                    Write-Debug -Message "*$Node : NODE PROCESSING STARTED FOR THIS NODE."
                    $Value.InvokeWithContext($functionsToDefine, $variablesToDefine)
                }
                catch [System.Management.Automation.MethodInvocationException]
                {
                    # Write the unwrapped exception message
                    $pscmdlet.CommandRuntime.WriteError((Get-InnerMostErrorRecord $_))
                    Update-ConfigurationErrorCount
                }

                # Display warning if domain credential is used in the configuration.
                if($Script:NodeUsingDomainCred.ContainsKey($Node)  -and $Script:NodeUsingDomainCred[$Node])
                {
                    $nameMessage = $LocalizedData.DomainCredentialNotAllowed -f @($Node, $Node)
                    $UserWarningPreference = $WarningPreference
                    if($null -ne $ArgsToBody['WarningAction'])
                    {
                        $UserWarningPreference = $ArgsToBody['WarningAction']
                    }
                    Write-Warning -Message $nameMessage -WarningAction $UserWarningPreference
                }

                # Validate make sure all of the required resources are defined
                # if so, add the DependsOn fields for all resources
                ValidateNodeResources
                #
                #  Fixup ModuleVersion
                #
                Update-ModuleVersion $Script:NodeResources $Script:NodeInstanceAliases[$Node] $Script:NodeResourceIdAliases[$Node]

                # Validate make sure all of the referenced download managers are defined
                ValidateNodeManager

                # Validate make sure all of the referenced resource source are defined
                ValidateNodeResourceSource

                # Validate make sure no conflict between exclusive resources
                # also validate exclusive resource exist
                ValidateNodeExclusiveResources

                # Validate make sure all of the required resources are defined
                ValidateNoCircleInNodeResources

                Write-Debug -Message "*$Node : NODE PROCESSING COMPLETED FOR THIS NODE. configuration errors encountered so far: $(Get-ConfigurationErrorCount)"
            }
        }
        else
        {
            $errorMessage = $LocalizedData.NestedNodeNotAllowed -f @(($Name -join ','), (Get-PSCurrentConfigurationNode), $Script:PSConfigurationName)
            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId NestedNodeNotAllowed
            Update-ConfigurationErrorCount
        }
    }
    catch
    {
        $errorMessage = $_.Exception.Message + (Get-PositionInfo $sourceMetadata)
        $errorMessage = $LocalizedData.FailToProcessNode -f @($Node, $errorMessage)
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId FailToProcessNode
        Update-ConfigurationErrorCount
    }
    finally
    {
        Set-PSCurrentConfigurationNode  ($Script:PSOuterConfigurationNodes.Pop())
        $Script:NodeResources = $OldNodeResources
        $Script:NodeKeys = $OldNodeKeys
        Write-Debug -Message "*NODE STATEMENT PROCESSING COMPLETED. Configuration errors encountered so far: $(Get-ConfigurationErrorCount)"
    }
}

#
# Utility used to track the number of errors encountered while processing the configuration
#
function Update-ConfigurationErrorCount
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param()

    $Script:PSConfigurationErrors++
}

function Get-ConfigurationErrorCount
{
    [OutputType([int])]
    param()

    $Script:PSConfigurationErrors
}

function Get-ComplexResourceQualifier
{
    [OutputType([string])]
    param()

   # walk the call stack to get at all of the enclosing configuration resource IDs
    $stackedConfigs = @(Get-PSCallStack |
        Where-Object -FilterScript { ($null -ne $_.InvocationInfo.MyCommand) -and ($_.InvocationInfo.MyCommand.CommandType -eq 'Configuration') })

    $complexResourceQualifier = $null
    # keep all but the top-most
    if(@($stackedConfigs).Length -ge 3)
    {
        $stackedConfigs = $stackedConfigs[1..(@($stackedConfigs).Length - 2)]
        # and build the complex resource ID suffix.
        $complexResourceQualifier = ( $stackedConfigs | foreach-Object -Process { '[' + $_.Command + ']' + $_.InvocationInfo.BoundParameters['InstanceName'] } ) -join '::'
    }

    return $complexResourceQualifier
 }

#
# A function to set the document text for default (unnamed) node
#
function Set-PSDefaultConfigurationDocument
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param (
        [Parameter()]
        [string]
        $documentText = ''
    )

    $Script:PSDefaultConfigurationDocument = $documentText
}

#
# Get the text associated with the default (unnamed) node.
#
function Get-PSDefaultConfigurationDocument
{
    [OutputType([string])]
    param()

    return $Script:PSDefaultConfigurationDocument
}

##################################################
#
# Returns the name of the configuration currently being configured
#
function Get-PSTopConfigurationName
{
    [OutputType([string])]
    param()

    return $Script:PSTopConfigurationName
}

function Set-PSTopConfigurationName
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param (
        [Parameter()]
        [string]
        $Name
    )

    $Script:PSTopConfigurationName = $Name
}

##################################################
#
# Returns the name of the node currently being configured
#
function Get-PSCurrentConfigurationNode
{
    [OutputType([string])]
    param()

    return $Script:PSCurrentConfigurationNode
}

function Set-PSCurrentConfigurationNode
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param (
        [Parameter()]
        [string]
        $nodeName
    )

    $Script:PSCurrentConfigurationNode = $nodeName
}

#################################################

function Set-NodeResources
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [string]
        $resourceId,
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]]
        $requiredResourceList
    )

    if ($null -eq $Script:NodeResources)
    {
        $Script:NodeResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,[string[]]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    }
    $Script:NodeResources[$resourceId] = $requiredResourceList
}

function Test-NodeResources
{
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]

        [string]
        $resourceId
    )

    if ( -not $Script:NodeResources)
    {
        $false
    }
    else
    {
        $Script:NodeResources.ContainsKey($resourceId)
    }
}

#
# update a mapping of a partial configuration resource and the managers it referenced
#
function Set-NodeManager
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [string]
        $resourceId,
        [Parameter(Mandatory)]
        [AllowNull()]
        [string[]]
        $referencedManagers
    )

    if ($null -eq $Script:NodeManager)
    {
        $Script:NodeManager = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    }
    $Script:NodeManager[$resourceId] = $referencedManagers
}

#
#
#
function Test-NodeManager
{
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]

        [string]
        $resourceId
    )

    if ( -not $Script:NodeManager)
    {
        $false
    }
    else
    {
        $Script:NodeManager.ContainsKey($resourceId)
    }
}

#
# update a mapping of a partial configuration resource and the managers it referenced
#
function Set-NodeResourceSource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [string]
        $resourceId,
        [Parameter(Mandatory)]
        [AllowNull()]
        [string[]]
        $referencedResourceSources
    )

    if ($null -eq $Script:NodeResourceSource)
    {
        $Script:NodeResourceSource = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    }
    $Script:NodeResourceSource[$resourceId] = $referencedResourceSources
}

#
#
#
function Test-NodeResourceSource
{
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]

        [string]
        $resourceId
    )

    if ( -not $Script:NodeResourceSource)
    {
        $false
    }
    else
    {
        $Script:NodeResourceSource.ContainsKey($resourceId)
    }
}

#
# update a mapping of a partial configuration resource and the managers it referenced
# resource format can be moduleName\* moduleName\resourceName and resourceName
# this is validated during mof generation/cananic stage
#
function Set-NodeExclusiveResources
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [string]
        $resourceId,
        [Parameter(Mandatory)]
        [AllowNull()]
        [string[]]
        $exclusiveResource
    )

    $Script:NodeExclusiveResources[$resourceId] = $exclusiveResource
    return $exclusiveResource
}


function Add-NodeKeys
{
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [string]
        $ResourceKey,
        [parameter(Mandatory)]
        [string]
        $keywordName
    )

    if ($null -eq $Script:NodeKeys)
    {
        $Script:NodeKeys = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.HashSet[string]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    }

    if( -not $Script:NodeKeys.ContainsKey($keywordName))
    {
        $Script:NodeKeys[$keywordName] = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    }

    if(-not $Script:NodeKeys[$keywordName].Contains($ResourceKey))
    {
        $null = $Script:NodeKeys[$keywordName].Add($ResourceKey)
    }

}

###########################################################
#
# A function to verify there's no duplicate conflicting resources in the configuration
#
# Conflict detecting algorithm works by going through all previuosly visited resources of same type and checking whether previously visited
# resource contains any properties which currently analyzed resource does not have or whether
# they have same properties but with different values. If that's the case, we mark that either key or non-key properties don't match.
# After that we check whether currently analyzed resource contains properties which the previously analyzed resource did not have at all. If that's the case we mark that
# non-key properties don't match (since all key properties were covered in the first phase).
#
# Once we processed all previous resources, we return error about duplicate conflicting resources if and only if key properties match and non key properties don't match.
#
###########################################################
function Test-ConflictingResources
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param (
        [string]
            $keyword,
        [parameter(Mandatory)]
        [Hashtable]
            $properties,
        [Parameter(Mandatory)]
            $keywordData
    )
    $resourceID = $properties['ResourceID']
    $sourceInfo = $properties['SourceInfo']

    $nonConflictingKeywords = @("PartialConfiguration", "WaitForAny", "WaitForSome", "WaitForAll")
    if ($keyword -in $nonConflictingKeywords)
    {
        return
    }

    # Get name of the current node
    $currentNodeName = Get-PSCurrentConfigurationNode
    if (-not $currentNodeName)
    {
        $currentNodeName = 'localhost'
    }

    # Initialize $Script:DuplicateResources if not already initialized
    if ($null -eq $Script:DuplicateResources)
    {
        $Script:DuplicateResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[System.Collections.Hashtable]]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    }

    if (-not $Script:DuplicateResources.ContainsKey($currentNodeName))
    {
        $Script:DuplicateResources[$currentNodeName] = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[System.Collections.Hashtable]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    }

    if ( -not $Script:DuplicateResources[$currentNodeName].ContainsKey($keyword))
    {
        $Script:DuplicateResources[$currentNodeName][$keyword] = New-Object 'System.Collections.Generic.List[System.Collections.Hashtable]'
    }

    # Find if current resource is duplicate and conflicting.
    foreach($resource in $Script:DuplicateResources[$currentNodeName][$keyword])
    {
        $keyPropertiesMatch = $true
        $nonKeyPropertiesMatch = $true
        $unmatchedNonKeyPropertiesNames = ""
        $unmatchedNonKeyPropertiesCurrentValues = ""
        $unmatchedNonKeyPropertiesPreviousValues = ""

        # For every property in previously analyzed resource
        foreach($property in $resource.Keys)
        {
            $nonConflictingProperties = @("DependsOn", "ResourceID", "SourceInfo", "ModuleVersion")
            if ($property -in $nonConflictingProperties)
            {
                continue
            }

            # If currently analyzed resource does not have the property
            if ( -not $properties.ContainsKey($property))
            {
                $nonKeyPropertiesMatch = $false
                $unmatchedNonKeyPropertiesNames += $property.ToString() + ';'
                # Calling ToString() explicitly so that the value is not converted to Boolean/Integer
                if ($resource[$property])
                {
                    $unmatchedNonKeyPropertiesPreviousValues += $resource[$property].ToString() + ';'
                }
                else
                {
                    $unmatchedNonKeyPropertiesPreviousValues = $unmatchedNonKeyPropertiesPreviousValues.ToString() + 'NULL;'
                }
                $unmatchedNonKeyPropertiesCurrentValues = $unmatchedNonKeyPropertiesCurrentValues.ToString() + 'NULL;'
            }
            # If currently analyzed resource has property, but with different value
            elseif ( $resource[$property] -ne $properties[$property] )
            {
                # If it's a key property
                if ($keywordData.Properties[$property].IsKey)
                {
                    $keyPropertiesMatch = $false
                    break
                }
                # If it's a non-key property
                else
                {
                    $nonKeyPropertiesMatch = $false
                    $unmatchedNonKeyPropertiesNames += $property.ToString() + ';'
                    if ($resource[$property])
                    {
                        $unmatchedNonKeyPropertiesPreviousValues += $resource[$property].ToString() + ';'
                    }
                    else
                    {
                        $unmatchedNonKeyPropertiesPreviousValues = $unmatchedNonKeyPropertiesPreviousValues.ToString() + 'NULL;'
                    }

                    if ($properties[$property])
                    {
                        $unmatchedNonKeyPropertiesCurrentValues += $properties[$property].ToString() + ';'
                    }
                    else
                    {
                        $unmatchedNonKeyPropertiesCurrentValues = $unmatchedNonKeyPropertiesCurrentValues.ToString() + 'NULL;'
                    }
                }
            }
        }

        if ($keyPropertiesMatch)
        {
            foreach($property in $properties.Keys)
            {
                # If previously analyzed resource does not have property
                if ((-not $resource.containsKey($property)) -and ($property -ne "ModuleVersion"))
                {
                    $nonKeyPropertiesMatch = $false
                    $unmatchedNonKeyPropertiesNames += $property.ToString() + ';'
                    $unmatchedNonKeyPropertiesPreviousValues = $unmatchedNonKeyPropertiesPreviousValues.ToString() + 'NULL;'
                    if ($properties[$property])
                    {
                        $unmatchedNonKeyPropertiesCurrentValues += $properties[$property].ToString() + ';'
                    }
                    else
                    {
                        $unmatchedNonKeyPropertiesCurrentValues = $unmatchedNonKeyPropertiesCurrentValues.ToString() + 'NULL;'
                    }
                }
            }
        }

        # If resource is duplicate and conflicting we should return error
        if ($keyPropertiesMatch -and (-not $nonKeyPropertiesMatch))
        {
            $unmatchedNonKeyPropertiesNames = $unmatchedNonKeyPropertiesNames.Substring(0, $unmatchedNonKeyPropertiesNames.Length-1)
            $unmatchedNonKeyPropertiesPreviousValues = $unmatchedNonKeyPropertiesPreviousValues.Substring(0, $unmatchedNonKeyPropertiesPreviousValues.Length-1)
            $unmatchedNonKeyPropertiesCurrentValues = $unmatchedNonKeyPropertiesCurrentValues.Substring(0, $unmatchedNonKeyPropertiesCurrentValues.Length-1)

            $previousResourceIdentifier = $resource["ResourceID"] + " (" + $resource["SourceInfo"] + ")"
            $currentResourceIdentifier = $resourceID + " (" + $sourceInfo + ")"
            $errorMessage = $LocalizedData.ConflictingDuplicateResource -f @($previousResourceIdentifier, $currentResourceIdentifier, $currentNodeName, $unmatchedNonKeyPropertiesNames, $unmatchedNonKeyPropertiesPreviousValues, $unmatchedNonKeyPropertiesCurrentValues)
            $exception = New-Object System.InvalidOperationException $errorMessage
            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ConflictingDuplicateResource
            Update-ConfigurationErrorCount
        }
    }

    $Script:DuplicateResources[$currentNodeName][$keyword].Add($properties)

}

#################################################
#
# A function to get the innermost error record.
#
function Get-InnerMostErrorRecord
{
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    $exception = $ErrorRecord.Exception
    while ($exception.InnerException -and $exception.InnerException.ErrorRecord)
    {
        $exception = $exception.InnerException
        $ErrorRecord = $exception.ErrorRecord
    }
    $ErrorRecord
}

###########################################################
#
# A function to set up all of the module-scoped state variables.
#
function Initialize-ConfigurationRuntimeState
{
    param (
        [Parameter()]
        [string]
        $ConfigurationName = ''
    )

    # The overall name of the configuration being processed
    [string] $Script:PSConfigurationName = $ConfigurationName

    # The ModuleVersion used for PsDesiredStateConfiguration module.
    [string] $Script:PsDscModuleVersion = "0.0"

    # The compatibility version for the document..
    [string] $Script:PsDscCompatibleVersion = "1.0.0"

    # The list of modules explicitly imported using import-dscresorce
    $Script:ExplicitlyImportedModules = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,String]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the current configuration, this contains the name of the node currently being processed
    [string] $Script:PSCurrentConfigurationNode = ''

    # For the current node, this contains a map of resource instance to resource prerequisites (DependsOn resources).
    [System.Collections.Generic.Dictionary[string,string[]]] `
    $Script:NodeResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,[string[]]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the current node, this contains a map of partial configuration instance to configuration managers.
    [System.Collections.Generic.Dictionary[string,string]] `
    $Script:NodeManager = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the current node, this contains a map of partial configuration instance to Resource Source.
    [System.Collections.Generic.Dictionary[string,string]] `
    $Script:NodeResourceSource = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the current node, this contains a map of partial configuration instance to its exclusive resources.
    [System.Collections.Generic.Dictionary[string,string[]]] `
    $Script:NodeExclusiveResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For all nodes except the unnamed node, this contains the per-node per-type reference counter used to generate the CIM aliases for each instance
    [System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string,int]]] `
    $Script:NodeTypeRefCount = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, System.Collections.Generic.Dictionary[string,int]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For all nodes except the unnamed node, this maps the node name to the node's table of alias to mof text mappings.
    [System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,string]]] `
    $Script:NodeInstanceAliases = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,string]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For all nodes except the unnamed node, this maps the node name to the node's table of resourceID to mof text mappings.
    [System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,string]]] `
    $Script:NodeResourceIdAliases = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,string]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For all nodes except the unnamed node, this maps the node name to the node's map of resource instance to resource prerequisites
    [System.Collections.Generic.Dictionary[string,object]] `
    $Script:NodesInThisConfiguration = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,object]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For all nodes except the unnamed node, this maps the node name to the node's map of partial configuration resource instance to  reference resource source.
    [System.Collections.Generic.Dictionary[string,object]] `
    $Script:NodesResourceSourceInThisConfiguration = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,object]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For all nodes except the unnamed node, this maps the node name to the node's map of partial configuration resource instance to  reference configuraiton manager.
    [System.Collections.Generic.Dictionary[string,object]] `
    $Script:NodesManagerInThisConfiguration = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,object]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For all nodes except the unnamed node, this maps the node name to the node's map of resource instance to exclusive resource
    [System.Collections.Generic.Dictionary[string,object]] `
    $Script:NodesExclusiveResourcesInThisConfiguration = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,object]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the unnamed (default) node, this contains a map of resource instance to resource prerequisites (required resources).
    [System.Collections.Generic.Dictionary[String,String[]]] `
    $Script:NoNameNodesResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,String[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the unnamed (default) node, this contains a map of partial configuration resource instance to  reference configuration manager.
    [System.Collections.Generic.Dictionary[String,String]] `
    $Script:NoNameNodeManager = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,String[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the unnamed (default) node, this contains a map of partial configuration resource instance to  reference resource source.
    [System.Collections.Generic.Dictionary[String,String]] `
    $Script:NoNameNodeResourceSource = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,String[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the unnamed (default) node, this contains a map of partial configuration resource instance to its exclusive resources.
    [System.Collections.Generic.Dictionary[String,String[]]] `
    $Script:NoNameNodeExclusiveResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,String[]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the unnamed (default) node, this contains the per-node per-type reference counter used to generate the CIM aliases for each instance
    [System.Collections.Generic.Dictionary[String,int]] `
    $Script:NoNameNodeTypeRefCount = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,int]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the unnamed (default) node, this maps the node name to the node's table of alias to mof text mappings.
    # Alias to mof text mapping for the unnamed node.
    [System.Collections.Generic.Dictionary[string,string]] `
    $Script:NoNameNodeInstanceAliases = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the unnamed (default) node, this maps the node name to the node's table of resourceId to mof text mappings.
    # Alias to mof text mapping for the unnamed node.
    [System.Collections.Generic.Dictionary[string,string]] `
    $Script:NoNameNodeResourceIdAliases = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    #dictionary to save whether a node has encrypted password
    [System.Collections.Generic.Dictionary[string,bool]] `
    $Script:NodesPasswordEncrypted = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,bool]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For all nodes, contain information about node using domain credential or not
    [System.Collections.Generic.Dictionary[string,bool]] `
    $Script:NodeUsingDomainCred = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,bool]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    [System.Collections.Generic.Stack[String]] $Script:PSOuterConfigurationNodes = New-Object -TypeName 'System.Collections.Generic.Stack[String]'

    # The number of errors that have occurred while processing this configuration.
    [int] $Script:PSConfigurationErrors = 0

    # Set up a variable to hold a top-level OMI_ConfigurationDocument value
    # which will be used by all nodes if it's present.
    [string]    $Script:PSDefaultConfigurationDocument = ''


    # Set up a hastable to hold user specified info for OMI_ConfigurationDocument value for meta config
    # we will need update it last after processing meta config to figure out what V2 property it uses
    [hashtable]    $script:PSMetaConfigDocumentInstVersionInfo = @{}

    [bool] $Script:PSMetaConfigDocInsProcessedBeforeMeta = $false
    [bool] $script:PSMetaConfigurationProcessed = $false

    # For all nodes except the unnamed node, this maps the node name to the node's map of keys of resources.
    [System.Collections.Generic.Dictionary[string,object]] `
    $script:NodesKeysInThisConfiguration = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,object]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the current node, this contains keys of resource instances.
    [System.Collections.Generic.Dictionary[string,System.Collections.Generic.HashSet[string]]] `
    $Script:NodeKeys = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.HashSet[string]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the unnamed (default) node, this contains keys of resource instances.
    [System.Collections.Generic.Dictionary[String,System.Collections.Generic.HashSet[string]]] `
    $Script:NoNameNodeKeys = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,System.Collections.Generic.HashSet[string]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # For the current configuration, $Script:DuplicateResources["Type"] contains list with properties of all resources of the specific type
    [System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[System.Collections.Hashtable]]]] `
    $Script:DuplicateResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[System.Collections.Hashtable]]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

    # Show Import-DscResource warning if in-build resources are used in the Configuration without Import-DscResource statement.
    [bool] $script:ShowImportDscResourceWarning = $false
}

#
# Then call it to enact the default state.  This happens
# only once during the module load. Thereafter the
# configuration function is responsible for resetting state.
#
Initialize-ConfigurationRuntimeState

# make sure configuration data format:
# 1. Is a hashtable
# 2. Has a collection AllNodes
# 3. Allnodes is an collection of Hashtable
# 4. Each element of Allnodes has NodeName
# 5. We will copy values from NodeName="*" to all node if they don't exist
function ValidateUpdate-ConfigurationData
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope="Function", Target="*")]
    param (
        [Parameter()]
        [hashtable]
        $ConfigurationData
    )

    if( -not $ConfigurationData.ContainsKey('AllNodes'))
    {
        $errorMessage = $LocalizedData.ConfiguratonDataNeedAllNodes
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ConfiguratonDataNeedAllNodes
        return $false
    }

    if($ConfigurationData.AllNodes -isnot [array])
    {
        $errorMessage = $LocalizedData.ConfiguratonDataAllNodesNeedHashtable
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ConfiguratonDataAllNodesNeedHashtable
        return $false
    }

    $nodeNames = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    foreach($Node in $ConfigurationData.AllNodes)
    {
        if($Node -isnot [hashtable] -or -not $Node.NodeName)
        {
            $errorMessage = $LocalizedData.AllNodeNeedToBeHashtable
            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ConfiguratonDataAllNodesNeedHashtable
            return $false
        }

        if($nodeNames.Contains($Node.NodeName))
        {
            $errorMessage = $LocalizedData.DuplicatedNodeInConfigurationData -f $Node.NodeName
            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId DuplicatedNodeInConfigurationData
            return $false
        }

        if($Node.NodeName -eq '*')
        {
            $AllNodeSettings = $Node
        }
        [void] $nodeNames.Add($Node.NodeName)
    }

    if($AllNodeSettings)
    {
        foreach($Node in $ConfigurationData.AllNodes)
        {
            if($Node.NodeName -ne '*')
            {
                foreach($nodeKey in $AllNodeSettings.Keys)
                {
                    if(-not $Node.ContainsKey($nodeKey))
                    {
                        $Node.Add($nodeKey, $AllNodeSettings[$nodeKey])
                    }
                }
            }
        }

        $ConfigurationData.AllNodes = @($ConfigurationData.AllNodes | Where-Object -FilterScript {
                $_.NodeName -ne '*'
            }
        )
    }

    return $true
}

##############################################################
#
# Checks to see if a module defining composite resources should be reloaded
# based the last write time of the schema file. Returns true if the file exists
# and the last modified time was either not recorded or has change.
#
function Test-ModuleReloadRequired
{
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [string]
        $SchemaFilePath
    )

    if (-not $SchemaFilePath -or  $SchemaFilePath -notmatch '\.schema\.psm1$')
    {
        # not a composite res
        return $false
    }

    # If the path doesn't exist, then we can't reload it.
    # Note: this condition is explicitly not an error for this function.
    if ( -not (Test-Path $SchemaFilePath))
    {
        if ($schemaFileLastUpdate.ContainsKey($SchemaFilePath))
        {
            $schemaFileLastUpdate.Remove($SchemaFilePath)
        }
        return $false
    }

    # If we have a modified date, then return it.
    if ($schemaFileLastUpdate.ContainsKey($SchemaFilePath))
    {
        if ( (Get-Item $SchemaFilePath).LastWriteTime -eq $schemaFileLastUpdate[$SchemaFilePath] )
        {
            return $false
        }
        else
        {
            return $true
        }
    }

    # Otherwise, record the last write time and return true.
    $script:schemaFileLastUpdate[$SchemaFilePath] = (Get-Item $SchemaFilePath).LastWriteTime
    $true
}
# Holds the schema file to lastwritetime mapping.
[System.Collections.Generic.Dictionary[string,DateTime]] $script:schemaFileLastUpdate =
New-Object -TypeName 'System.Collections.Generic.Dictionary[string,datetime]'

###########################################################
# Configuration keyword implementation
###########################################################
#
# Implements the 'configuration' keyword logic that accumulates and writes
# out the generated DSC MOF files
#
function Configuration
{
    # suppress global:ConfigurationData
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Scope="Function", Target="*")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSProvideCommentHelp", "", Scope="Function", Target="*")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPositionalParameters", "", Scope="Function", Target="*")]
    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=517195')]
    param (
        # there are extra [] around Tuple arguments
        [System.Collections.Generic.List[System.Tuple[[string[]], [Microsoft.PowerShell.Commands.ModuleSpecification[]], [Version]]]]
        $ResourceModuleTuplesToImport,
        $OutputPath = '.',
        $Name,
        [scriptblock]
        $Body,
        [hashtable]
        $ArgsToBody,
        [hashtable]
        $ConfigurationData = @{
            AllNodes = @()
        },
        [string]
        $InstanceName = ''
    )


    function ConvertModuleDefnitionToModuleInfo
    {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPositionalParameters", "", Scope="Function", Target="*")]
        param(
            [Microsoft.PowerShell.Commands.ModuleSpecification[]]$moduleToImport,
            [Version]$moduleVersion = $null
        )

        if (-not $moduleToImport) {
            return $null
        }

        $moduleToImport | Foreach-Object -Process {
            $versionToUse = $_.Version
            if( [string]::IsNullOrEmpty($versionToUse))
            {
                $versionToUse = $_.RequiredVersion
            }
            $Script:ExplicitlyImportedModules[ $_.Name ] = $versionToUse
        }
        $moduleInfos = Get-Module -ListAvailable -FullyQualifiedName $moduleToImport | Sort-Object -Property Version -Descending

        return $moduleInfos
    }

    if ( $IsMacOS -or $IsLinux ) {
        Write-Warning -Message $LocalizedData.EmbeddedResourcesNotSupported
    }

    try
    {
        Write-Debug -Message "BEGIN CONFIGURATION '$Name' PROCESSING: OutputPath: '$OutputPath'"

        if ($Name -inotmatch  '^[a-z][a-z0-9_]*$')
        {
            $errorId = 'InvalidConfigurationName'
            $errorMessage = $($LocalizedData.InvalidConfigurationName) -f ${Name}
            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId $errorId
        }

        $script:IsMetaConfig = $false
        foreach($attri in $Body.Attributes)
        {
            if ($attri.GetType() -eq [System.Management.Automation.DscLocalConfigurationManagerAttribute])
            {
                $script:IsMetaConfig = $true
                $Script:PSMetaConfigDocInsProcessedBeforeMeta = $false
                $script:PSMetaConfigurationProcessed = $false
                break
            }
        }

        # True if this is the top-most level of the configuration statement.
        #
        [bool] $topLevel = $false

        if ($Script:PSConfigurationName -eq '')
        {
            Write-Debug -Message "  $Name : TOP-LEVEL CONFIGURATION STARTED"
            $topLevel = $true
            Set-PSTopConfigurationName $Name
            #
            # Define a dictionary to hold the "driver" functions that will be created for each CIM class/keyword.
            # This dictionary is passed into the body scriptblock, defining these functions in the body scope
            # which simplifies cleanup.
            #
            $script:functionsToDefine = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,ScriptBlock]'([System.StringComparer]::OrdinalIgnoreCase)

            if($null -eq $ConfigurationData)
            {
                $ConfigurationData = @{
                    AllNodes = @()
                }
            }

            $dataValidated = ValidateUpdate-ConfigurationData $ConfigurationData

            if (-not $dataValidated)
            {
                Update-ConfigurationErrorCount
                Write-Debug -Message 'ConfigurationData validation failed'
                return
            }
            else
            {
                $script:ConfigurationData = $ConfigurationData
            }

            if($OutputPath -eq '.' -or $null -eq $OutputPath -or $OutputPath -eq '')
            {
                $OutputPath = ".\$Name"
            }

            # Load the default CIM keyword/function definitions set, populating the function collection
            # with the default functions.
            [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::LoadDefaultCimKeywords($functionsToDefine)

            # Set up the rest of the configuration runtime state.
            Initialize-ConfigurationRuntimeState $Name

            # Create the output directory only if it does not exist.
            # If it exists then the document MOF files will overwrite
            # any existing MOF files with the same name but otherwise
            # leave contents of existing directory alone.
            $ConfigurationOutputDirectory = "$OutputPath"
            if (!(Test-Path $ConfigurationOutputDirectory))
            {
                $mkdirError = $null
                New-Item -ErrorVariable mkdirError -ItemType Directory -Force -Path $ConfigurationOutputDirectory  > $null 2> $null
                if (! $?)
                {
                    Update-ConfigurationErrorCount
                }

                if ($mkdirError)
                {
                    $errorId = 'InvalidOutputPath'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                    $errorMessage = $($LocalizedData.CannotCreateOutputPath) -f ${ConfigurationOutputDirectory}
                    $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                    $ErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $exception, $errorId, $errorCategory, $null
                    Write-Error $ErrorRecord
                    foreach ($e in $mkdirError)
                    {
                        Write-Error -Exception $e.Exception
                        Update-ConfigurationErrorCount
                    }
                }
            }

            #
            # Add the utility functions used by the resource implementation functions.
            #
            $functionsToDefine.Add('Get-MofInstanceText',                ${function:Get-MofInstanceText} )
            $functionsToDefine.Add('ConvertTo-MOFInstance',              ${function:ConvertTo-MOFInstance} )
            $functionsToDefine.Add('Update-ConfigurationErrorCount',     ${function:Update-ConfigurationErrorCount} )
            $functionsToDefine.Add('Get-ConfigurationErrorCount',        ${function:Get-ConfigurationErrorCount} )
            $functionsToDefine.Add('Set-PSDefaultConfigurationDocument', ${function:Set-PSDefaultConfigurationDocument} )
            $functionsToDefine.Add('Get-PSDefaultConfigurationDocument', ${function:Get-PSDefaultConfigurationDocument} )
            $functionsToDefine.Add('Get-PSCurrentConfigurationNode',     ${function:Get-PSCurrentConfigurationNode} )
            $functionsToDefine.Add('Set-NodeResources',                  ${function:Set-NodeResources} )
            $functionsToDefine.Add('Test-NodeResources',                 ${function:Test-NodeResources} )
            $functionsToDefine.Add('Set-NodeManager',                    ${function:Set-NodeManager} )
            $functionsToDefine.Add('Test-NodeManager',                   ${function:Test-NodeManager} )
            $functionsToDefine.Add('Set-NodeResourceSource',             ${function:Set-NodeResourceSource} )
            $functionsToDefine.Add('Test-NodeResourceSource',            ${function:Test-NodeResourceSource} )
            $functionsToDefine.Add('Set-NodeExclusiveResources',         ${function:Set-NodeExclusiveResources} )
            $functionsToDefine.Add('Add-NodeKeys',                       ${function:Add-NodeKeys} )
            $functionsToDefine.Add('Test-ConflictingResources',          ${function:Test-ConflictingResources} )
            $functionsToDefine.Add('Set-PSMetaConfigDocInsProcessedBeforeMeta', ${function:Set-PSMetaConfigDocInsProcessedBeforeMeta} )
            $functionsToDefine.Add('Get-PSMetaConfigDocumentInstVersionInfo', ${function:Get-PSMetaConfigDocumentInstVersionInfo} )
            $functionsToDefine.Add('Get-PSMetaConfigurationProcessed', ${function:Get-PSMetaConfigurationProcessed} )
            $functionsToDefine.Add('Set-PSMetaConfigVersionInfoV2', ${function:Set-PSMetaConfigVersionInfoV2})

            #
            # Add the node keyword implementation function which must be module qualified even though
            # it's not exported from the module because the parsing logic always adds the module name
            # to the command call.
            #
            $functionsToDefine.Add('PSDesiredStateConfiguration\node',   ${function:Node})

            Write-Debug -Message "    $Name : $($functionsToDefine.Count) type handler functions loaded."
            Write-Debug -Message "  $Name TOP-LEVEL INITIALIZATION COMPLETED"
        }
        else
        {
            Write-Debug -Message "  $Name : NESTED CONFIGURATION STARTED"
        }

        #
        # Load all of the required resource definition modules
        #

        foreach ($tuple in $ResourceModuleTuplesToImport)
        {
            $res = $tuple.Item1
            $modulesInfo = ConvertModuleDefnitionToModuleInfo -moduleToImport $tuple.Item2 -moduleVersion $tuple.Item3

            if (-not $modulesInfo) {
                # Module name is not specified. Try to load resource from all available modules.
                $modulesInfo = Get-Module -ListAvailable
            }

            foreach ($mod in $modulesInfo) {

                $null = ImportClassResourcesFromModule -Module $mod -Resources $res -functionsToDefine $functionsToDefine
                $dscResourcesPath = Join-Path -Path $mod.ModuleBase -ChildPath 'DscResources'
                if(Test-Path $dscResourcesPath)
                {
                    foreach($requiredResource in $res)
                    {
                        if ($requiredResource.Contains('*')) {
                            # we historically resolve wildcards by Get-Item File System rules.
                            # We don't support wildcards resolutions for Friendly names.
                            foreach ($resource in Get-ChildItem -Path $dscResourcesPath -Directory -Name -Filter $requiredResource)
                            {
                                $null = ImportCimAndScriptKeywordsFromModule -Module $mod -Resource $resource -functionsToDefine $functionsToDefine
                            }
                        } else {
                            # ImportCimAndScriptKeywordsFromModule takes care about resolving $requiredResources names to ClassNames or FriendlyNames.
                            $null = ImportCimAndScriptKeywordsFromModule -Module $mod -Resource $requiredResource -functionsToDefine $functionsToDefine
                        }
                    }
                }
                elseif ($moduleInfos.Count -eq 1)
                {
                    $modules.Add($moduleInfos)
                }
            }
        }

        if (-not (Get-PSCurrentConfigurationNode))
        {
            # A dictionary maps a resourceId to its list of required resources list for any resources
            # defined outside of a node statement
            $Script:NodeResources = $Script:NoNameNodesResources
            $Script:NodeKeys = $Script:NoNameNodeKeys
            $Script:NodeManager = $Script:NoNameNodeManager
            $Script:NodeExclusiveResources = $Script:NoNameNodeExclusiveResources
            $Script:NodeResourceSource = $Script:NoNameNodeResourceSource

        }
        else
        {
            $Script:NodeResources = $Script:NodesInThisConfiguration[(Get-PSCurrentConfigurationNode)]
            $Script:NodeManager = $Script:NodesManagerInThisConfiguration[(Get-PSCurrentConfigurationNode)]
            $Script:NodeResourceSource = $Script:NodesResourceSourceInThisConfiguration[(Get-PSCurrentConfigurationNode)]
            $Script:NodeExclusiveResources = $Script:NodesExclusiveResourcesInThisConfiguration[(Get-PSCurrentConfigurationNode)]
        }

        #
        # Evaluate the configuration statement body which will generate the resource definitons
        # for this configuration.
        #
        Write-Debug -Message "  $Name : Evaluating configuration statement body..."
        try
        {
            $variablesToDefine = @(
                #
                # Figure out the "type" of this resource, with is the name of the driver function that was called.
                #
                New-Object -TypeName PSVariable -ArgumentList ('ConfigurationData', $script:ConfigurationData )
                New-Object -TypeName PSVariable -ArgumentList ('MyTypeName', $ExecutionContext.SessionState.Module.GetVariableFromCallersModule('MyInvocation').Value.MyCommand.Name)
                New-Object -TypeName PSVariable -ArgumentList ('IsMetaConfig', $script:IsMetaConfig)
                New-Object -TypeName PSVariable -ArgumentList ('V1MetaConfigPropertyList', $script:V1MetaConfigPropertyList)
                if($script:ConfigurationData)
                {
                    New-Object -TypeName PSVariable -ArgumentList ('AllNodes', $script:ConfigurationData.AllNodes)
                }
            )

            $variablesToDefine += foreach ($key in $ArgsToBody.Keys)
            {
                #
                # we need to process dependsOn seperately to
                # 1. combined depends on with possible upper level configuration statement (composite resource case
                # 2. in case of 1, we also need to fix up the dependson to append the suffix of ::$complexResourceQualifier similar in func:Test-DependsOn in CimDSCParser
                #
                if($key -ne 'DependsOn')
                {
                    New-Object -TypeName PSVariable -ArgumentList ($key, $ArgsToBody[$key])
                }
            }

            if($DependsOn -or $ArgsToBody['DependsOn'])
            {
                $complexResourceQualifier = Get-ComplexResourceQualifier
                if($complexResourceQualifier)
                {
                    $updatedDependsOn = foreach($DependsOnVar in @($ArgsToBody['DependsOn']))
                    {
                        if($DependsOnVar)
                        {
                            "$DependsOnVar::$complexResourceQualifier"
                        }
                    }
                    $DependsOn = @($DependsOn) + @($updatedDependsOn)
                }
                else
                {
                    $DependsOn = @($DependsOn) + @($ArgsToBody['DependsOn'])
                }

                $variablesToDefine += New-Object -TypeName PSVariable -ArgumentList('DependsOn', $DependsOn)
            }

            $null = $Body.InvokeWithContext($functionsToDefine, $variablesToDefine)
        }
        catch [System.Management.Automation.MethodInvocationException]
        {
            Write-Debug -Message "  $Name : Top level exception: $($_ | Out-String)"
            # Write the unwrapped exception message
            $pscmdlet.CommandRuntime.WriteError((Get-InnerMostErrorRecord $_))
            Update-ConfigurationErrorCount
        }

        #
        # write the generated files to disk and return the resulting files to stdout.
        #

        if( $topLevel )
        {
            if($Script:NoNameNodeInstanceAliases.Count -gt 0)
            {
                if ($Script:NodeInstanceAliases.ContainsKey('localhost'))
                {
                    $errorMessage = $LocalizedData.LocalHostNodeNotAllowed -f "$Name"
                    $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                    Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId LocalHostNodeNotAllowed
                    Update-ConfigurationErrorCount
                }

                #
                # Fixup DependsOn
                #
                ValidateNoNameNodeResources
                Update-DependsOn $Script:NoNameNodesResources $Script:NoNameNodeInstanceAliases $Script:NoNameNodeResourceIdAliases


                Write-Debug -Message "  $Name : Evaluation completed, validating the generated resource set."
                ValidateNodeResources
                Write-Debug -Message "  $Name Validation completed."

                #
                #  Fixup ModuleVersion
                #
                Update-ModuleVersion $Script:NoNameNodesResources $Script:NoNameNodeInstanceAliases $Script:NoNameNodeResourceIdAliases

                Write-Debug -Message "  $Name : Evaluation completed, validating the generated resource set has no circle."
                ValidateNoCircleInNodeResources
                Write-Debug -Message "  $Name Validation circle completed."

                if($script:IsMetaConfig)
                {
                    # Validate make sure all of the referenced download managers are defined
                    Write-Debug -Message "  $Name : Evaluation completed, validating the generated resource set reference download manager."
                    ValidateNodeManager
                    Write-Debug -Message "  $Name Validation completed."

                    # Validate make sure all of the referenced resource source are defined
                    Write-Debug -Message "  $Name : Evaluation completed, validating the generated resource set reference resource source."
                    ValidateNodeResourceSource
                    Write-Debug -Message "  $Name Validation completed."

                    # Validate make sure new conflict between exclusive resources
                    Write-Debug -Message "  $Name : Evaluation completed, validating no conflict between exclusive resources."
                    ValidateNodeExclusiveResources
                    Write-Debug -Message "  $Name Validation completed."

                    Write-MetaConfigFile $Name 'localhost' $Script:NoNameNodeInstanceAliases
                }
                else
                {
                    Update-ConfigurationDocumentRef $Script:NoNameNodesResources $Script:NoNameNodeInstanceAliases $Script:NoNameNodeResourceIdAliases $Name
                    #
                    # Write the mof instance texts to files
                    #
                    Write-NodeMOFFile $Name 'localhost' $Script:NoNameNodeInstanceAliases
                }

                # If no script-level $ConfigurationData variable is set, this code
                # tries to get it first, from a global PowerShell ConfigurationData variable,
                # then if that doesn't work it trys the environment
                # variable $ENV:ConfigurationData when is expected to contain a JSON string
                # that will be converted to objects.
                #
                if (-not $script:ConfigurationData)
                {
                    $script:ConfigurationData = try
                    {
                        if ($global:ConfigurationData)
                        {
                            $global:ConfigurationData
                        }
                        elseif ($ENV:ConfigurationData)
                        {
                            $ENV:ConfigurationData | ConvertFrom-Json
                        }
                        else
                        {
                            @()
                        }
                    }
                    catch
                    {
                        Write-Error $_
                        Update-ConfigurationErrorCount
                        @()
                    }
                }
            }

            if($script:ShowImportDscResourceWarning)
            {
                $message = $LocalizedData.ImportDscResourceWarningForInbuiltResource -f @(Get-PSTopConfigurationName)
                $ImportDscResourceWarningPreference = $WarningPreference
                if($null -ne $ArgsToBody['WarningAction'])
                {
                    $ImportDscResourceWarningPreference = $ArgsToBody['WarningAction']
                }
                Write-Warning -Message $message -WarningAction $ImportDscResourceWarningPreference
            }

            #
            # write using the top-level hashtable
            #
            foreach($mofNode in $Script:NodeInstanceAliases.Keys)
            {
                #
                # Fixup DependsOn
                #
                Update-DependsOn $Script:NodesInThisConfiguration[$mofNode] $Script:NodeInstanceAliases[$mofNode] $Script:NodeResourceIdAliases[$mofNode]

                if($script:IsMetaConfig)
                {
                    Write-MetaConfigFile $Name $mofNode $Script:NodeInstanceAliases[$mofNode]
                }
                else
                {
                    Update-ConfigurationDocumentRef $Script:NodesInThisConfiguration[$mofNode] $Script:NodeInstanceAliases[$mofNode] $Script:NodeResourceIdAliases[$mofNode] $Name
                    #
                    # Write the mof instance texts to files
                    #
                    Write-NodeMOFFile $Name $mofNode $Script:NodeInstanceAliases[$mofNode]
                }
            }

            if ($Script:PSConfigurationErrors -gt 0)
            {
                $errorMessage = $LocalizedData.FailToProcessConfiguration -f "$Name"
                ThrowError -ExceptionName 'System.InvalidOperationException' -ExceptionMessage $errorMessage -ExceptionObject "$Name" -ErrorId 'FailToProcessConfiguration' -ErrorCategory InvalidOperation
            }
        }
    }
    finally
    {
        if($topLevel)
        {
            Write-Debug -Message "  CONFIGURATION $Name : DOING TOP-LEVEL CLEAN UP"
            [System.Management.Automation.Language.DynamicKeyword]::Reset()
            [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ClearCache()

            Initialize-ConfigurationRuntimeState
        }
        Write-Debug -Message "END CONFIGURATION '$Name' PROCESSING. OutputPath: '$OutputPath'"
    }
}
Export-ModuleMember -Function Configuration

function Update-ModuleVersion
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[String,String[]]]
        $NodeResources,

        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[string,string]]
        $NodeInstanceAliases,

        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[string,string]]
        $NodeResourceIdAliases
    )

    $moduleVersionValue = '0.0'

    # explicit import-dscresource with version for psdesiredstateconfiguration module was not done.
    if( $Script:ExplicitlyImportedModules.ContainsKey('PsDesiredStateConfiguration') -and
        (-not [string]::IsNullOrEmpty($Script:ExplicitlyImportedModules['PsDesiredStateConfiguration'])))
    {
        $moduleVersionValue= $script:PsDscModuleVersion
    }
    # generating compatible document.
    elseif($script:PsDscCompatibleVersion -eq '1.0.0')
    {
        $moduleVersionValue='1.0'
    }

    foreach($resourceId in $NodeResources.keys)
    {
        $alias = $NodeResourceIdAliases[$resourceId]
        $instanceText = $NodeInstanceAliases[$alias]
        $curlyPosition = $instanceText.LastIndexOf('}')
        if(($curlyPosition -gt 0) -and ($instanceText -imatch 'ModuleName[\s]*=[\s]*["]PsDesiredStateConfiguration["]') -and
          ($instanceText -inotmatch 'ModuleVersion[\s]*='))
        {
            $first = $instanceText.Substring(0, $curlyPosition)

            $moduleVersionstring = "ModuleVersion = "
            $moduleVersionstring += "`"$moduleVersionValue`"" + ";"
            $NodeInstanceAliases[$alias] = $first + $moduleVersionstring + "`r`n};"
        }
    }
}

function Update-DependsOn
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[String,String[]]]
        $NodeResources,

        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[string,string]]
        $NodeInstanceAliases,

        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[string,string]]
        $NodeResourceIdAliases
    )

    foreach($resourceId in $NodeResources.keys)
    {
        $alias = $NodeResourceIdAliases[$resourceId]
        $needAdd = $false
        $instanceText = $NodeInstanceAliases[$alias]
        if($NodeResources[$resourceId])
        {
            $curlyPosition = $instanceText.LastIndexOf('}')
            if(($curlyPosition -gt 0) -and ($instanceText -notmatch 'dependsOn[\s]*='))
            {
                $needAdd = $true
                $first = $instanceText.Substring(0, $curlyPosition)

                $dependsOn = "DependsOn = {`r`n"
                $len = @($NodeResources[$resourceId]).Length
                $dependsOn += foreach ($resourceId in $NodeResources[$resourceId])
                {
                    '    ' + "`"$($resourceId -replace '\\', '\\' -replace '"', '\"')`"" +
                    $(if (--$len -gt 0)
                        {
                            ",`r`n"
                        }
                        else
                        {
                            ''
                        }
                    )
                }
                $dependsOn += '};'
            }
        }

        if($needAdd)
        {
            $NodeInstanceAliases[$alias] = $first + $dependsOn + "`r`n};"
        }
    }
}

#
# add a reference to each resource to point to the OMI_ConfigurationDocument
# so it can be differiencated after merging of partical configurations
#
function Update-ConfigurationDocumentRef
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[String,String[]]]
        $NodeResources,

        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[string,string]]
        $NodeInstanceAliases,

        [Parameter(Mandatory)]
        [System.Collections.Generic.Dictionary[string,string]]
        $NodeResourceIdAliases,

        [Parameter(Mandatory)]
        [string]
        $ConfigurationName
    )

    foreach($resourceId in $NodeResources.keys)
    {
        $alias = $NodeResourceIdAliases[$resourceId]
        $instanceText = $NodeInstanceAliases[$alias]
        $needAdd = $false
        $curlyPosition = $instanceText.LastIndexOf('}')
        if($curlyPosition -gt 0)
        {
            $needAdd = $true
            $first = $instanceText.Substring(0, $curlyPosition).TrimEnd()

            $ConfigurationNameRef = "`r`n ConfigurationName = `"$ConfigurationName`";"
        }

        if($needAdd)
        {
            $NodeInstanceAliases[$alias] = $first + $ConfigurationNameRef + "`r`n};"
        }
    }
}

function ImportClassResourcesFromModule
{
    param (
        [Parameter(Mandatory)]
        [PSModuleInfo]
        $Module,

        [Parameter(Mandatory)]
        [System.Collections.Generic.List[string]]
        $Resources,

        [System.Collections.Generic.Dictionary[string, scriptblock]]
        $functionsToDefine
    )

    $resourcesFound = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportClassResourcesFromModule($Module, $Resources, $functionsToDefine)
    return ,$resourcesFound
}

function ImportCimAndScriptKeywordsFromModule
{
    param (
        [Parameter(Mandatory)]
        $Module,

        [Parameter(Mandatory)]
        $resource,

        $functionsToDefine
    )

    trap
    {
        continue
    }

    $SchemaFilePath = $null
    $oldCount = $functionsToDefine.Count

    $keywordErrors = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Exception]'

    $foundCimSchema = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportCimKeywordsFromModule(
    $Module, $resource, [ref] $SchemaFilePath, $functionsToDefine, $keywordErrors)

    foreach($ex in $keywordErrors)
    {
        Write-Error -Exception $ex
        if($ex.InnerException)
        {
            Write-Error -Exception $ex.InnerException
        }
    }

    $functionsAdded = $functionsToDefine.Count - $oldCount
    Write-Debug -Message "  $Name : PROCESSING RESOURCE FILE: Added $functionsAdded type handler functions from  '$SchemaFilePath'"

    $SchemaFilePath = $null
    $oldCount = $functionsToDefine.Count

    $foundScriptSchema = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportScriptKeywordsFromModule(
    $Module, $resource, [ref] $SchemaFilePath, $functionsToDefine )

    $functionsAdded = $functionsToDefine.Count - $oldCount
    Write-Debug -Message "  $Name : PROCESSING RESOURCE FILE: Added $functionsAdded type handler functions from  '$SchemaFilePath'"

    if ($foundScriptSchema -and $SchemaFilePath)
    {
        $resourceDirectory = Split-Path $SchemaFilePath
        if($null -ne $resourceDirectory)
        {
            Import-Module -Force: (Test-ModuleReloadRequired $SchemaFilePath) -Verbose:$false -Name $resourceDirectory -Global -ErrorAction SilentlyContinue
        }
    }

    return $foundCimSchema -or $foundScriptSchema
}

#
# A function to write the MOF instance texts of a node to files as meta config
#
function Write-MetaConfigFile
{
    # nodeConfigurationDocument incorrectly shows up as unused
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Target="", Scope="Function")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPositionalParameters", "", Scope="Function", Target="*")]
    param(
        [string]
        $ConfigurationName,

        [string]
        $mofNode,

        [System.Collections.Generic.Dictionary[string,string]]
        $mofNodeHash

    )

    # Set up prefix for both the configuration and metaconfiguration documents.
    $nodeDoc = "/*`n@TargetNode='$mofNode'`n" + "@GeneratedBy=$([system.environment]::UserName)`n@GenerationDate=$(Get-Date)`n@GenerationHost=$([system.environment]::MachineName)`n*/`n"
    $nodeConfigurationDocument = $null
    [int]$nodeDocCount = 0
    $resourceManagers = $null
    $resourceManagersCount = 0
    $reportManagers = $null
    $reportManagersCount = 0
    $downloadManagers = $null
    $downloadManagersCount = 0
    $localConfigManager = $null
    $partialConfiguratons = $null
    $partialConfigurationCount = 0

    foreach($mofTypeName in $mofNodeHash.Keys)
    {
        if($mofTypeName -match 'OMI_ConfigurationDocument')
        {
            $nodeConfigurationDocument = $mofNodeHash[$mofTypeName]
        }

        if($mofTypeName -match 'MSFT_WebDownloadManager' -or $mofTypeName -match 'MSFT_FileDownloadManager')
        {
            $r = $mofNodeHash[$mofTypeName] -match '\$\w*'
            if($r)
            {
                if($downloadManagersCount++ -gt 0)
                {
                    $downloadManagers += ",`n"
                }
                $downloadManagers += '  ' + $Matches[0]
            }
        }

        if($mofTypeName -match 'MSFT_WebResourceManager' -or $mofTypeName -match 'MSFT_FileResourceManager')
        {
            $r = $mofNodeHash[$mofTypeName] -match '\$\w*'
            if($r)
            {
                if($resourceManagersCount++ -gt 0)
                {
                    $resourceManagers += ",`n"
                }
                $resourceManagers += '  ' +$Matches[0]
            }
        }

        if($mofTypeName -match 'MSFT_OaaSReportManager' -or $mofTypeName -match 'MSFT_WebReportManager')
        {
            $r = $mofNodeHash[$mofTypeName] -match '\$\w*'
            if($r)
            {
                if($reportManagersCount++ -gt 0)
                {
                    $reportManagers += ",`n"
                }
                $reportManagers += '  ' +$Matches[0]
            }
        }

        #MSFT_PartialConfiguration
        if($mofTypeName -match 'MSFT_PartialConfiguration')
        {
            $r = $mofNodeHash[$mofTypeName] -match '\$\w*'
            if($r)
            {
                if($partialConfigurationCount++ -gt 0)
                {
                    $partialConfiguratons += ",`n"
                }
                $partialConfiguratons += '  ' +$Matches[0]
            }
        }

        if($mofTypeName -notmatch 'MSFT_DSCMetaConfiguration')
        {
            $nodeDoc += $mofNodeHash[$mofTypeName]
        }
        else
        {
            if($null -eq $localConfigManager)
            {
                # save the localConfigManager which need to be fixed up to add additional manager info as embedded resources
                $localConfigManager = $mofNodeHash[$mofTypeName] -replace 'MSFT_DSCMetaConfigurationV2', 'MSFT_DSCMetaConfiguration'
            }
            else
            {
                $errorMessage = $LocalizedData.MetaConfigurationHasMoreThanOneLocalConfigurationManager -f @($mofNode)
                $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId InvalidMOFDefinition
                Update-ConfigurationErrorCount
                return
            }
        }

        $nodeDocCount++
    }

    if($null -eq $localConfigManager)
    {
        # Print verbose message that empty settings definition is added.
        $emptySettingVerboseMessage = $LocalizedData.MetaConfigurationSettingsMissing -f @($mofNode)
        Write-Verbose -Message $emptySettingVerboseMessage

        # Assign default settings
        $localConfigManager = "`ninstance of MSFT_DSCMetaConfiguration as `$MSFT_DSCMetaConfiguration1ref `n{`n};"
    }

    # fixup to add embedded instances
    $nodeDoc += Update-LocalConfigManager $localConfigManager $resourceManagers $reportManagers $downloadManagers $partialConfiguratons


    $nodeOutfile = "$ConfigurationOutputDirectory/$($mofNode).meta.mof"

    # add/update OMI_ConfigurationDocument of meta config
    if ($nodeDoc -notmatch 'OMI_ConfigurationDocument')
    {
        if (Get-PSDefaultConfigurationDocument)
        {
            Write-Debug -Message "  ${ConfigurationName}: Adding OMI_ConfigurationDocument from $(Get-PSDefaultConfigurationDocument)"
            $nodeDoc += Get-PSDefaultConfigurationDocument
        }
        else
        {
            Write-Debug -Message "  ${ConfigurationName}: Adding missing OMI_ConfigurationDocument element to the document"
            if($Script:NodesPasswordEncrypted[$mofNode])
            {
                $nodeDoc += "`ninstance of OMI_ConfigurationDocument`n{`n Version=`"2.0.0`";`n MinimumCompatibleVersion = `"$($script:PSMetaConfigDocumentInstVersionInfo['MinimumCompatibleVersion'])`";`n CompatibleVersionAdditionalProperties= $(Get-CompatibleVersionAddtionaPropertiesStr);`n Author=`"$([system.environment]::UserName)`";`n GenerationDate=`"$(Get-Date)`";`n GenerationHost=`"$([system.environment]::MachineName)`";`n ContentType=`"PasswordEncrypted`";`n Name=`"$(Get-PSTopConfigurationName)`";`n};"
            }
            else
            {
                $nodeDoc += "`ninstance of OMI_ConfigurationDocument`n{`n Version=`"2.0.0`";`n MinimumCompatibleVersion = `"$($script:PSMetaConfigDocumentInstVersionInfo['MinimumCompatibleVersion'])`";`n CompatibleVersionAdditionalProperties= $(Get-CompatibleVersionAddtionaPropertiesStr);`n Author=`"$([system.environment]::UserName)`";`n GenerationDate=`"$(Get-Date)`";`n GenerationHost=`"$([system.environment]::MachineName)`";`n Name=`"$(Get-PSTopConfigurationName)`";`n};"
            }
        }
    }

    # Fix up newlines to be CRLF
    $nodeDoc = $nodeDoc -replace "`n", "`r`n"

    # todo: meta configuration might not be verifiable currently
    $errMsg = Test-MofInstanceText $nodeDoc
    if($errMsg)
    {
        $errorMessage = $LocalizedData.InvalidMOFDefinition -f @($mofNode, $errMsg)
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId InvalidMOFDefinition
        Update-ConfigurationErrorCount
        $nodeOutfile = "$ConfigurationOutputDirectory/$($mofNode).meta.mof.error"
    }

    if($nodeDocCount -gt 0)
    {
        # Write to a file only if no error was generated or we are writing to .mof.error file
        if ($Script:PSConfigurationErrors -eq 0 -or $nodeOutfile.EndsWith('mof.error'))
        {
            $nodeDoc > $nodeOutfile
            Get-ChildItem $nodeOutfile
        }
    }
}

# fixup localConfigmanager to have embedded instance
function Update-LocalConfigManager
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Scope="Function")]
    param(
        [string]
        $localConfigManager,
        [string]
        $resourceManagers,
        [string]
        $reportManagers,
        [string]
        $downloadManagers,
        [string]
        $partialConfigurations
    )

    $curlyPostion = $localConfigManager.LastIndexOf('}')
    if($curlyPostion -gt 0)
    {
        $first = $localConfigManager.Substring(0, $curlyPostion)
        if($resourceManagers)
        {
            $first += "  ResourceModuleManagers = {`n" + $resourceManagers + "  `n };`n"
        }

        if($reportManagers)
        {
            $first += "  ReportManagers = {`n" + $reportManagers + "  `n };`n"
        }

        if($downloadManagers)
        {
            $first += "  ConfigurationDownloadManagers = {`n" + $downloadManagers + "  `n };`n"
        }

        #PartialConfigurations
        if($partialConfigurations)
        {
            $first += "  PartialConfigurations = {`n" + $partialConfigurations + "  `n };`n"
        }

        $first += "};`n"

        $first
    }
}

function Get-MofInstanceName
{
    param(
        [string]
        $mofInstance
    )
}
#
# A function to write the MOF instance texts of a node to files
#
function Write-NodeMOFFile
{
    param(
        [string]
        $ConfigurationName,

        [string]
        $mofNode,

        [System.Collections.Generic.Dictionary[string,string]]
        $mofNodeHash
    )

    # Set up prefix for both the configuration and metaconfiguration documents.
    $nodeDoc = "/*`n@TargetNode='$mofNode'`n" + "@GeneratedBy=$([system.environment]::UserName)`n@GenerationDate=$(Get-Date)`n@GenerationHost=$([system.environment]::MachineName)`n*/`n"
    $nodeMetaDoc = $nodeDoc
    $nodeConfigurationDocument = $null
    [int]$metaDocCount = 0
    [int]$nodeDocCount = 0

    foreach($mofTypeName in $mofNodeHash.Keys)
    {
        if($mofTypeName -match 'MSFT_DSCMetaConfiguration')
        {
            $tempMetaDoc = $mofNodeHash[$mofTypeName]
            $metaDocCount++
            break
        }
    }

    foreach($mofTypeName in $mofNodeHash.Keys)
    {
        if(($mofTypeName -notmatch 'MSFT_DSCMetaConfiguration'))
        {
            if(($metaDocCount -gt 0) -and ($tempMetaDoc -match [regex]::Escape($mofTypeName)))
            {
                $nodeMetaDoc += $mofNodeHash[$mofTypeName]
            }
            else
            {
                if($mofTypeName -match 'OMI_ConfigurationDocument')
                {
                    $nodeConfigurationDocument = $mofNodeHash[$mofTypeName]
                }
                $nodeDoc += $mofNodeHash[$mofTypeName]
                $nodeDocCount++
            }
        }
    }

    $nodeMetaDoc += $tempMetaDoc

    $nodeOutfile = "$ConfigurationOutputDirectory/$($mofNode).mof"
    if($metaDocCount -gt 0)
    {
        $nodeMetaOutfile = "$ConfigurationOutputDirectory/$($mofNode).meta.mof"
        # this meta config uses v1 schema so will not have v2 properties
        if ($nodeConfigurationDocument)
        {
            Write-Debug -Message "  ${ConfigurationName}: Adding OMI_ConfigurationDocument from the current node '$mofNode': $nodeConfigurationDocument"
            $nodeMetaDoc += $nodeConfigurationDocument
        }
        elseif (Get-PSDefaultConfigurationDocument)
        {
            Write-Debug -Message "  ${ConfigurationName}: Adding OMI_ConfigurationDocument from $(Get-PSDefaultConfigurationDocument)"
            $nodeMetaDoc += Get-PSDefaultConfigurationDocument
        }
        else
        {
            Write-Debug -Message "  ${ConfigurationName}: Adding missing OMI_ConfigurationDocument element to the document"
            if($Script:NodesPasswordEncrypted[$mofNode])
            {
                $nodeMetaDoc += "`ninstance of OMI_ConfigurationDocument`n{`n Version=`"2.0.0`";`n MinimumCompatibleVersion = `"1.0.0`";`n CompatibleVersionAdditionalProperties= $(Get-CompatibleVersionAddtionaPropertiesStr);`n Author=`"$([system.environment]::UserName)`";`n GenerationDate=`"$(Get-Date)`";`n GenerationHost=`"$([system.environment]::MachineName)`";`n ContentType=`"PasswordEncrypted`";`n Name=`"$(Get-PSTopConfigurationName)`";`n};"
            }
            else
            {
                $nodeMetaDoc += "`ninstance of OMI_ConfigurationDocument`n{`n Version=`"2.0.0`";`n MinimumCompatibleVersion = `"1.0.0`";`n CompatibleVersionAdditionalProperties= $(Get-CompatibleVersionAddtionaPropertiesStr);`n Author=`"$([system.environment]::UserName)`";`n GenerationDate=`"$(Get-Date)`";`n GenerationHost=`"$([system.environment]::MachineName)`";`n Name=`"$(Get-PSTopConfigurationName)`";`n};"
            }
        }
    }

    if ($nodeDoc -notmatch 'OMI_ConfigurationDocument')
    {
        if (Get-PSDefaultConfigurationDocument)
        {
            Write-Debug -Message "  ${ConfigurationName}: Adding OMI_ConfigurationDocument from $(Get-PSDefaultConfigurationDocument)"
            $nodeDoc += Get-PSDefaultConfigurationDocument
        }
        else
        {
            Write-Debug -Message "  ${ConfigurationName}: Adding missing OMI_ConfigurationDocument element to the document"
            if($Script:NodesPasswordEncrypted[$mofNode])
            {
                if($nodeDoc.Contains("PsDscRunAsCredential"))
                {
                    $nodeDoc += "`ninstance of OMI_ConfigurationDocument`n
                    {`n Version=`"2.0.0`";`n
                        MinimumCompatibleVersion = `"2.0.0`";`n
                        CompatibleVersionAdditionalProperties= {`"Omi_BaseResource:ConfigurationName`"};`n
                        Author=`"$([system.environment]::UserName)`";`n
                        GenerationDate=`"$(Get-Date)`";`n
                        GenerationHost=`"$([system.environment]::MachineName)`";`n
                        ContentType=`"PasswordEncrypted`";`n
                        Name=`"$(Get-PSTopConfigurationName)`";`n
                    };"
                }
                else
                {
                    $nodeDoc += "`ninstance of OMI_ConfigurationDocument`n
                    {`n Version=`"2.0.0`";`n
                        MinimumCompatibleVersion = `"1.0.0`";`n
                        CompatibleVersionAdditionalProperties= {`"Omi_BaseResource:ConfigurationName`"};`n
                        Author=`"$([system.environment]::UserName)`";`n
                        GenerationDate=`"$(Get-Date)`";`n
                        GenerationHost=`"$([system.environment]::MachineName)`";`n
                        ContentType=`"PasswordEncrypted`";`n
                        Name=`"$(Get-PSTopConfigurationName)`";`n
                    };"
                }
            }
            else
            {
                if($nodeDoc.Contains("PsDscRunAsCredential"))
                {
                    $nodeDoc += "`ninstance of OMI_ConfigurationDocument`n
                    {`n Version=`"2.0.0`";`n
                        MinimumCompatibleVersion = `"2.0.0`";`n
                        CompatibleVersionAdditionalProperties= {`"Omi_BaseResource:ConfigurationName`"};`n
                        Author=`"$([system.environment]::UserName)`";`n
                        GenerationDate=`"$(Get-Date)`";`n
                        GenerationHost=`"$([system.environment]::MachineName)`";`n
                        Name=`"$(Get-PSTopConfigurationName)`";`n
                    };"
                }
                else
                {
                    $nodeDoc += "`ninstance of OMI_ConfigurationDocument`n
                    {`n Version=`"2.0.0`";`n
                        MinimumCompatibleVersion = `"1.0.0`";`n
                        CompatibleVersionAdditionalProperties= {`"Omi_BaseResource:ConfigurationName`"};`n
                        Author=`"$([system.environment]::UserName)`";`n
                        GenerationDate=`"$(Get-Date)`";`n
                        GenerationHost=`"$([system.environment]::MachineName)`";`n
                        Name=`"$(Get-PSTopConfigurationName)`";`n
                    };"
                }
            }
        }
    }
    # Fix up newlines to be CRLF
    $nodeDoc = $nodeDoc -replace "`n", "`r`n"

    $errMsg = Test-MofInstanceText $nodeDoc
    if($errMsg)
    {
        $errorMessage = $LocalizedData.InvalidMOFDefinition -f @($mofNode, $errMsg)
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId InvalidMOFDefinition
        Update-ConfigurationErrorCount
        $nodeOutfile = "$ConfigurationOutputDirectory/$($mofNode).mof.error"
    }

    if($nodeDocCount -gt 0)
    {
        # Write to a file only if no error was generated or we are writing to .mof.error file
        if ($Script:PSConfigurationErrors -eq 0 -or $nodeOutfile.EndsWith('mof.error'))
        {
            $nodeDoc > $nodeOutfile
            Get-ChildItem $nodeOutfile
        }
    }

    if($nodeMetaDoc -match 'MSFT_DSCMetaConfiguration' -and $Script:PSConfigurationErrors -eq 0)
    {
        $nodeMetaDoc = $nodeMetaDoc -replace "`n", "`r`n"
        $nodeMetaDoc > $nodeMetaOutfile
        Get-ChildItem $nodeMetaOutfile
    }
}

#
# A function to make sure that only valid resources are referenced within a node. It
# operates off of the $Script:NodeResources dictionary. An empty dictionary is not
# considered an error since this function is called at both the node level and the configuration
# level.
# This function also expand the dependsOn to composite resources
#
function ValidateNodeResources
{
    Write-Debug -Message "          Validating resource set for node: $(Get-PSCurrentConfigurationNode)"
    $newNodeResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,[string[]]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    if ($Script:NodeResources)
    {
        foreach ($resourceId in $Script:NodeResources.Keys)
        {
            Write-Debug -Message "            Checking node $resourceId"
            $newDependsOn = foreach ($requiredResource in $Script:NodeResources[$resourceId])
            {
                # Skip resources that have no DependsOn.
                if ($requiredResource)
                {
                    Write-Debug -Message "             > Checking for required node $requiredResource"

                    if (-not $Script:NodeResources.ContainsKey($requiredResource))
                    {
                        Write-Debug -Message "             > trying expand for required node $requiredResource"
                        $expandedDependsOn = foreach($rId in $Script:NodeResources.keys)
                        {
                            if($rId.EndsWith($requiredResource, [System.StringComparison]::InvariantCultureIgnoreCase))
                            {
                                $rId
                            }
                        }


                        if(-not $expandedDependsOn)
                        {
                            $errorMessage = $LocalizedData.RequiredResourceNotFound -f @($requiredResource, $resourceId)
                            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId RequiredResourceNotFound
                            Update-ConfigurationErrorCount
                        }
                        else
                        {
                            $expandedDependsOn
                        }
                    }
                    else
                    {
                        $requiredResource
                    }
                }
            }

            if($newDependsOn)
            {
                $newNodeResources[$resourceId] = $newDependsOn
            }
        }

        if($newNodeResources)
        {
            foreach($id in $newNodeResources.keys)
            {
                $Script:NodeResources[$id] = $newNodeResources[$id]
            }
        }
    }
    Write-Debug -Message "          Validation complete for node: $(Get-PSCurrentConfigurationNode)"
}

#
# A function to make sure that only valid resources are referenced within the resource without node.
# This function also expand the dependsOn to composite resources
#
function ValidateNoNameNodeResources
{
    Write-Debug -Message '          Validating resource set for resources in the default configuration'
    $newNodeResources = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,[string[]]]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    if ($Script:NoNameNodesResources)
    {
        foreach ($resourceId in $Script:NoNameNodesResources.Keys)
        {
            Write-Debug -Message "            Checking node $resourceId"
            $newDependsOn = foreach ($requiredResource in $Script:NoNameNodesResources[$resourceId])
            {
                # Skip resources that have no DependsOn.
                if ($requiredResource)
                {
                    Write-Debug -Message "             > Checking for required node $requiredResource"

                    if (-not $Script:NoNameNodesResources.ContainsKey($requiredResource))
                    {
                        Write-Debug -Message "             > trying expand for required node $requiredResource"
                        $expandedDependsOn = foreach($rId in $Script:NoNameNodesResources.keys)
                        {
                            if($rId.EndsWith($requiredResource, [System.StringComparison]::InvariantCultureIgnoreCase))
                            {
                                $rId
                            }
                        }


                        if(-not $expandedDependsOn)
                        {
                            $errorMessage = $LocalizedData.RequiredResourceNotFound -f @($requiredResource, $resourceId)
                            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId RequiredResourceNotFound
                            Update-ConfigurationErrorCount
                        }
                        else
                        {
                            $expandedDependsOn
                        }
                    }
                    else
                    {
                        $requiredResource
                    }
                }
            }

            if($newDependsOn)
            {
                $newNodeResources[$resourceId] = $newDependsOn
            }
        }

        if($newNodeResources)
        {
            foreach($id in $newNodeResources.keys)
            {
                $Script:NoNameNodesResources[$id] = $newNodeResources[$id]
            }
        }
    }
    Write-Debug -Message '          Validation complete for default resources.'
}

#
# A function to make sure that only valid Manager are referenced within a node. It
# operates off of the $Script:NodeManager dictionary.
# An empty dictionary is not
# considered an error since this function is called at both the node level and the configuration
# level.
#
function ValidateNodeManager
{
    Write-Debug -Message "          Validating manager set for node: $(Get-PSCurrentConfigurationNode)"
    if ($Script:NodeManager)
    {
        foreach ($resourceId in $Script:NodeManager.Keys)
        {
            Write-Debug -Message "            Checking node $resourceId"
            $refManagers = $Script:NodeManager[$resourceId]
            # Skip partial configuration that have no Manager.
            if ($refManagers)
            {
                Write-Debug -Message "             > Checking for required manager $refManagers"

                foreach ($refManager in $refManagers)
                {
                    if (-not  $Script:NodeResources.ContainsKey($refManager))
                    {
                        $errorMessage = $LocalizedData.ReferencedManagerNotFound -f @($refManager, $resourceId)
                        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ReferencedManagerNotFound
                        Update-ConfigurationErrorCount
                    }
                }
            }
        }
    }
    Write-Debug -Message "          Validation complete for node: $(Get-PSCurrentConfigurationNode)"
}

#
# A function to make sure that only valid resource source are referenced within a node. It
# operates off of the $Script:NodeResourceSource dictionary.
# An empty dictionary is not
# considered an error since this function is called at both the node level and the configuration
# level.
#
function ValidateNodeResourceSource
{
    Write-Debug -Message "          Validating resource source set for node: $(Get-PSCurrentConfigurationNode)"
    if ($Script:NodeResourceSource)
    {
        foreach ($resourceId in $Script:NodeResourceSource.Keys)
        {
            Write-Debug -Message "            Checking node $resourceId"
            $refResourceSources = $Script:NodeResourceSource[$resourceId]
            # Skip partial configuration that have no Manager.
            if ($refResourceSources)
            {
                Write-Debug -Message "             > Checking for required manager $refManagers"

                foreach ($refResourceSource in $refResourceSources)
                {
                    if (-not  $Script:NodeResources.ContainsKey($refResourceSource))
                    {
                        $errorMessage = $LocalizedData.ReferencedResourceSourceNotFound -f @($refResourceSource, $resourceId)
                        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ReferencedResourceSourceNotFound
                        Update-ConfigurationErrorCount
                    }
                }
            }
        }
    }
    Write-Debug -Message "          Validation complete for node: $(Get-PSCurrentConfigurationNode)"
}

#
# A function to make sure that exclusive resources among partial configurations do not conflict with each other
# it is already of format modulename\resourcName or modulename\* or resourceName
# It also validate they exist
function ValidateNodeExclusiveResources
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Target="", Scope="Function")]
    param()

    Write-Debug -Message "          Validating exclusive resources for node: $(Get-PSCurrentConfigurationNode)"
    if ($Script:NodeExclusiveResources)
    {
        # map will be of format {moduleName, {Id=ResourceId; ContainsAll = $true/$false; Resources=@('r1','r2'...)}}
        $ModuleBasedExclusiveResourceMap = @{}
        # map for resource that doesn't have module
        $NoModuleExclusiveResourceMap = @{}

        foreach ($resourceId in $Script:NodeExclusiveResources.Keys)
        {
            Write-Debug -Message "            Checking node $resourceId"

            # Remove duplicate entries from exclusive Resource array
            $exclusiveResourceList = $Script:NodeExclusiveResources[$resourceId] | Select-Object -Unique

            foreach($refResource in $exclusiveResourceList)
            {
                $resourceSegs = $refResource -split '\\'

                if($resourceSegs.Length -eq 2)
                {
                    if($null -eq $ModuleBasedExclusiveResourceMap[$resourceSegs[0]])
                    {
                        $ModuleBasedExclusiveResourceMap[$resourceSegs[0]] = @{
                            Id = $resourceId
                        }
                        if($resourceSegs[1] -eq '*')
                        {
                            $ModuleBasedExclusiveResourceMap[$resourceSegs[0]]['ContainsAll'] = $true
                        }
                        else
                        {
                            $ModuleBasedExclusiveResourceMap[$resourceSegs[0]]['ContainsAll'] = $false
                            $ModuleBasedExclusiveResourceMap[$resourceSegs[0]]['Resources'] = @($resourceSegs[1])
                        }
                    }
                    else
                    {
                        # 'Module\Resource' in PartialConfiguration1 conflicts with 'Module\*' in PartialConfiguration2
                        # or 'Module\*' in PartialConfiguration1 conflicts with 'Module\Resource' in PartialConfiguration2
                        if(($resourceSegs[1] -eq '*') -or $ModuleBasedExclusiveResourceMap[$resourceSegs[0]]['ContainsAll'])
                        {
                            $errorMessage = $LocalizedData.ConflictInExclusiveResources -f @($ModuleBasedExclusiveResourceMap[$resourceSegs[0]]['Id'], $resourceId)
                            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ConflictInExclusiveResources
                            Update-ConfigurationErrorCount
                            break
                        }
                        # 'Module\Resource' in PartialConfiguration1 conflicts with 'Module\Resource' in PartialConfiguration2
                        # or 'Module\Resource' in PartialConfiguration1 conflicts with 'Resource' in PartialConfiguration2
                        elseif($ModuleBasedExclusiveResourceMap[$resourceSegs[0]]['Resources'] -icontains $resourceSegs[1] `
                                    -or $null -ne $NoModuleExclusiveResourceMap[$resourceSegs[1]])
                        {
                            $errorMessage = $LocalizedData.ConflictInExclusiveResources -f @($ModuleBasedExclusiveResourceMap[$resourceSegs[0]]['Id'], $resourceId)
                            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ConflictInExclusiveResources
                            Update-ConfigurationErrorCount
                            break
                        }
                        else
                        {
                            $ModuleBasedExclusiveResourceMap[$resourceSegs[0]]['Resources'] += @($resourceSegs[1])
                        }
                    }
                }
                else # no module name, normally means binary resource
                {
                    if($null -eq $NoModuleExclusiveResourceMap[$refResource])
                    {
                        $resourceFound = $false
                        $ModuleBasedExclusiveResourceMap.GetEnumerator() | ForEach-Object {
                            if($_.Value.Resources -icontains $refResource) {
                                $resourceFound = $true
                                $ConflictingPartialConfigurationId = $_.Value.Id
                            }
                        }

                        # 'Resource' in PartialConfiguration1 conflicts with 'Module\Resource' in PartialConfiguration2
                        if($resourceFound){
                            $errorMessage = $LocalizedData.ConflictInExclusiveResources -f @($ConflictingPartialConfigurationId, $resourceId)
                            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ConflictInExclusiveResources
                            Update-ConfigurationErrorCount
                            break
                        }

                        $NoModuleExclusiveResourceMap[$refResource] = @{
                            Id = $resourceId
                        }
                    }
                    # 'Resource' in PartialConfiguration1 conflicts with 'Resource' in PartialConfiguration2
                    else
                    {
                        $errorMessage = $LocalizedData.ConflictInExclusiveResources -f @($NoModuleExclusiveResourceMap[$refResource]['Id'], $resourceId)
                        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId ConflictInExclusiveResources
                        Update-ConfigurationErrorCount
                        break
                    }
                }
            }
        }
    }
    Write-Debug -Message "          Validation complete for node: $(Get-PSCurrentConfigurationNode)"
}

#
# A function to make sure that only valid resources are referenced within a node. It
# operates off of the $Script:NodeResources dictionary. An empty dictionary is not
# considered an error since this function is called at both the node level and the configuration
# level.
# it uses Tarjan strongly connected component algorithms
#
function ValidateNoCircleInNodeResources
{
    Write-Debug -Message "          Validating resource set for node: $(Get-PSCurrentConfigurationNode)"
    [int] $script:CircleIndex = 0
    [System.Collections.Generic.Stack[string]] $script:resourceIdStack =
    New-Object -TypeName 'System.Collections.Generic.Stack[string]'
    [hashtable] $script:resourceIndex = @{}
    [hashtable] $script:resourceLowIndex = @{}
    [int] $script:ComponentDepth = 0
    [int] $script:MaxComponentDepth = 1024

    if ($Script:NodeResources)
    {
        foreach ($resourceId in $Script:NodeResources.Keys)
        {
            if($null -ne ($Script:NodeResources[$resourceId]) -and $Script:NodeResources[$resourceId].Contains($resourceId))
            {
                $errorMessage = $LocalizedData.DependsOnLoopDetected -f "$resourceId->$resourceId"
                $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
                Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId DependsOnLoopDetected
                Update-ConfigurationErrorCount
            }

            if($null -eq $resourceIndex[$resourceId])
            {
                $script:ComponentDepth = 0
                StrongConnect($resourceId)
            }
        }
    }
    Write-Debug -Message "          Validation circular reference completed for node: $(Get-PSCurrentConfigurationNode)"
}

function StrongConnect
{
    param ([string]$resourceId)

    $script:resourceIndex[$resourceId] = $script:CircleIndex
    $script:resourceLowIndex[$resourceId] = $script:CircleIndex
    $script:CircleIndex++
    $script:ComponentDepth++
    if($script:ComponentDepth -gt $script:MaxComponentDepth)
    {
        $errorMessage = $LocalizedData.DependsOnLinkTooDeep -f $script:MaxComponentDepth
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId DependsOnLinkTooDeep
        Update-ConfigurationErrorCount
    }

    $script:resourceIdStack.Push($resourceId)

    foreach ($requiredResource in $Script:NodeResources[$resourceId])
    {
        Write-Debug -Message "             > Checking for required node $requiredResource"
        #$requiredResource is not visited yet
        if($null -ne ($requiredResource) -and ($null -eq $script:resourceIndex[$requiredResource]))
        {
            StrongConnect($requiredResource)
            $script:resourceLowIndex[$resourceId] = [math]::Min($script:resourceLowIndex[$resourceId], $script:resourceLowIndex[$requiredResource])
        }
        elseif($script:resourceIdStack -Contains $requiredResource)
        {
            $script:resourceLowIndex[$resourceId] = [math]::Min($script:resourceLowIndex[$resourceId], $script:resourceIndex[$requiredResource])
        }
    }

    if($script:resourceIndex[$resourceId] -eq $script:resourceLowIndex[$resourceId])
    {
        $resourceCount = 0
        $circularLinks = ''
        do
        {
            $a = $script:resourceIdStack.Pop()
            $circularLinks += "->$a"
            $resourceCount++
        }
        while($a -ne $resourceId)

        if($resourceCount -gt 1)
        {
            $errorMessage = $LocalizedData.DependsOnLoopDetected -f $circularLinks
            $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
            Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId DependsOnLoopDetected
            Update-ConfigurationErrorCount
        }
    }
}

#
# Returns any validation error messages
#
function Test-MofInstanceText
{
    param (
        [Parameter(Mandatory)]
        $instanceText
    )

    # Ignore empty instances...
    if ( $instanceText)
    {
        try
        {
            [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ValidateInstanceText($instanceText)
        }
        catch [System.Management.Automation.MethodInvocationException]
        {
            # Return the exception message from the inner most ErrorRecord
            $ErrorRecord = Get-InnerMostErrorRecord $_
            $ErrorRecord.Exception.Message
        }
    }
}

#
# Encrypt a password using CMS
#
function Get-EncryptedPassword
{
    param (
        [Parameter()]
        $Value = $null
    )

    if($Node -and $selectedNodesData)
    {
        if($selectedNodesData -is [array])
        {
            foreach($target in $selectedNodesData)
            {
                # Node name should be exactly the same as one defined in AllNodes
                # -eq does case in sensitive comparison
                if($target['NodeName'] -and $target['NodeName'] -eq $Node)
                {
                    $currentNode = $target
                }
            }
        }
        else
        {
            $currentNode = $selectedNodesData
        }
    }
    # where user need to specify properties for resources not in a node,
    # they can do it through localhost nodeName in $allNodes
    elseif($allnodes -and $allnodes.AllNodes)
    {
        foreach($target in $allnodes.AllNodes)
        {
            if($target['NodeName'] -and $target['NodeName'] -eq 'localhost')
            {
                $currentNode = $target
            }
        }
    }

    if($currentNode)
    {
        # if Certificate is provided, it override PSDscAllowPlainTextPassword : bug 565167
        # CertificateID is currently assumed to be the 'thumbprint' from the certificate
        # Protect-CmsMessage [-To] takes actual cert, path to cert file, path to a directory contains cert, thumbprint or subject name of cert
        # we only support cert file and thumbprint as before now
        $certificateid = $currentNode['CertificateID']

        # If there is no certificateid defined, just return the original value...
        if ( -not $certificateid)
        {
            # CertificateFile is the public key file
            $certificatefile = $currentNode['CertificateFile']

            if ( -not $certificatefile)
            {
                return $Value
            }
            else
            {
                $CmsMessageRecipient = $certificatefile
            }
        }
        else
        {
            $CmsMessageRecipient = $certificateid
        }
    }

    if($CmsMessageRecipient -and $Value -is [string])
    {
        # Encrypt using the public key
        $encMsg = Protect-CmsMessage -To $CmsMessageRecipient -Content $Value

        # Reverse bytes for unmanaged decryption
        #[Array]::Reverse($encbytes)

        #$encMsg = $encMsg -replace '-----BEGIN CMS-----',''
        #$encMsg = $encMsg -replace "`n",''
        #$encMsg = $encMsg -replace '-----END CMS-----',''

        return $encMsg
    }
    else
    {
        # passwords should be some type of string so this is probably an error but pass
        # back the incoming value. Also if there is no key, then we just pass through the
        # password as is.

        $Value
    }
}


#
# Retrieve a public key that can be used for encryption. Matching on thumbprint
#
function Get-PublicKeyFromStore
{
    param(
        [Parameter(Mandatory)]
        [string]
        $certificateid
    )

    $cert = $null

    foreach($certIndex in Get-ChildItem -Path cert:\LocalMachine\My)
    {
        if($certIndex.Thumbprint -match $certificateid)
        {
            $cert = $certIndex
            break
        }
    }

    if(-not $cert)
    {
        $errorMessage = $($LocalizedData.CertificateStoreReadError) -f $certificateid
        ThrowError -ExceptionName 'System.InvalidOperationException' -ExceptionMessage $errorMessage -ExceptionObject $certificateid -ErrorId 'InvalidPathSpecified' -ErrorCategory InvalidOperation
    }
    else
    {
        $cert
    }
}

#
# Retrieve a public key that can be used for encryption. Certificate loaded from
# a certificate file
#
function Get-PublicKeyFromFile
{
    param(
        [Parameter(Mandatory)]
        [string]
        $certificatefile
    )

    try
    {
        $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2

        if($cert)
        {
            $cert.Import($certificatefile)
            $cert
        }
    }
    catch
    {
        $errorMessage = $($LocalizedData.CertificateFileReadError) -f $certificatefile
        ThrowError -ExceptionName 'System.InvalidOperationException' -ExceptionMessage $errorMessage -ExceptionObject $certificatefile -ErrorId 'InvalidPathSpecified' -ErrorCategory InvalidOperation
    }
}


###########################################################
#
#  Checksum generation functions.
#
###########################################################

#-----------------------------------------------------------------------------------------------------
# New-DscChecksum cmdlet is used to create corresponding checksum files for a specified file or folder
#-----------------------------------------------------------------------------------------------------
function New-DscChecksum
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSProvideCommentHelp", "", Scope="Function", Target="*")]
    [CmdletBinding(SupportsShouldProcess = $true, HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=403986')]
    param(
        [Parameter(Mandatory)]
        [Alias('ConfigurationPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutPath = $null,

        [switch]
        $Force
    )

    # Check validity of all configuration paths specified, throw if any of them is invalid
    for ($i = 0 ; $i -lt $Path.Length ; $i++)
    {
        if (!(Test-Path -Path $Path[$i]))
        {
            $errorMessage = $LocalizedData.InvalidConfigPath -f $Path[$i]
            ThrowError -ExceptionName 'System.ArgumentException' -ExceptionMessage $errorMessage -ExceptionObject $Path[$i] -ErrorId 'InvalidConfigurationPath' -ErrorCategory InvalidArgument
        }
    }

    # If an OutPath is specified, handle its creation and error conditions
    if ($OutPath)
    {
        # If and invalid path syntax is specified in $Outpath, throw
        if(([System.IO.Path]::InvalidPathChars | ForEach-Object -Process {
                    $OutPath.Contains($_)
                }
        ).IndexOf($true)[0] -ne -1)
        {
            $errorMessage = $LocalizedData.InvalidOutpath -f $OutPath
            ThrowError -ExceptionName 'System.ArgumentException' -ExceptionMessage $errorMessage -ExceptionObject $OutPath -ErrorId 'InvalidOutPath' -ErrorCategory InvalidArgument
        }

        # If the specified $Outpath conflicts with an existing file, throw
        if(Test-Path -Path $OutPath -PathType Leaf)
        {
            $errorMessage = $LocalizedData.OutpathConflict -f $OutPath
            ThrowError -ExceptionName 'System.ArgumentException' -ExceptionMessage $errorMessage -ExceptionObject $OutPath -ErrorId 'InvalidOutPath' -ErrorCategory InvalidArgument
        }

        # IF THE CONTROL REACHED HERE, $OutPath IS A VALID DIRECTORY PATH WHICH HAS NO CONFLICT WITH AN EXISTING FILE

        # If $OutPath doesn't exist, create it
        if(!(Test-Path -Path $OutPath))
        {
            $null = New-Item -Path $OutPath -ItemType Directory
        }

        $OutPath = (Resolve-Path $OutPath).ProviderPath
    }

    # Retrieve all valid configuration files at the specified $Path
    $allConfigFiles = $Path | ForEach-Object  -Process {
        (Get-ChildItem -Path $_ -Recurse | Where-Object -FilterScript {
                $_.Extension -eq '.mof' -or $_.Extension -eq '.zip'
            }
        )
    }

    # If no valid config file was found, log this and return
    if ($allConfigFiles.Length -eq 0)
    {
        Write-Log -Message $LocalizedData.NoValidConfigFileFound

        return
    }

    # IF THE CONTROL REACHED HERE, VALID CONFIGURATION FILES HAVE BEEN FOUND AND WE NEED TO CALCULATE THEIR HASHES

    foreach ($file in $allConfigFiles)
    {
        $fileOutpath = "$($file.FullName).checksum"
        if ($OutPath)
        {
            $fileOutpath = "$OutPath\$($file.Name).checksum"
        }

        # If the Force parameter was not specified and the hash file already exists for the current file, log this, and skip this file
        if (!$Force -and (Get-Item -Path $fileOutpath -ErrorAction SilentlyContinue))
        {
            Write-Log -Message ($LocalizedData.CheckSumFileExists -f $fileOutpath)
            continue
        }

        # Devise appropriate message
        $message = $LocalizedData.CreateChecksumFile -f $fileOutpath
        if (Test-Path -Path $fileOutpath)
        {
            $message = $LocalizedData.OverwriteChecksumFile -f $fileOutpath
        }

        # Finally, if the hash file doesn't exist already or -Force has been specified, then output the corresponding hash file
        if ($pscmdlet.ShouldProcess($message, $null, $null))
        {
            [String]$checksum = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash

            WriteFile -Path $fileOutpath -Value $checksum
        }
    }
}
Export-ModuleMember -Function New-DscChecksum


#------------------------------------
# Utility to throw an error/exception
#------------------------------------
function ThrowError
{
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ExceptionName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ExceptionMessage,

        [System.Object]
        $ExceptionObject,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $errorId,

        [parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorCategory]
        $errorCategory
    )

    $exception = New-Object $ExceptionName $ExceptionMessage
    $ErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $exception, $errorId, $errorCategory, $ExceptionObject
    throw $ErrorRecord
}

#----------------------------------------
# Utility to write WhatIf or Verbose logs
#----------------------------------------
function Write-Log
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $message
    )

    if ($pscmdlet.ShouldProcess($message, $null, $null))
    {
        Write-Verbose -Message $message
    }
}

# WriteFile is a helper function used to write the content to the file
function WriteFile
{
    param(
        [parameter(Mandatory)]
        [string]
        $Value,

        [parameter(Mandatory)]
        [string]
    $Path)

    try
    {
        [system.io.streamwriter]$stream = New-Object -TypeName system.io.StreamWriter -ArgumentList ($Path, $false)
        try
        {
            [void] $stream.Write($Value)
        }
        finally
        {
            if ($stream)
            {
                $stream.Close()
            }
        }
    }
    catch
    {
        $errorMessage = $LocalizedData.FileReadError -f $Path
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId InvalidPathSpecified
        Update-ConfigurationErrorCount
    }
}

#
# ReadEnvironmentFile imports the contents of a
# file as ConfigurationData
#
function ReadEnvironmentFile
{
    param(
        [parameter(Mandatory)]
        [string]
    $FilePath)

    try
    {
        $resolvedPath = Resolve-Path $FilePath
    }
    catch
    {
        $errorMessage = $LocalizedData.FilePathError -f $FilePath
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId InvalidPathSpecified
        Update-ConfigurationErrorCount
    }

    try
    {
        $content = Get-Content $resolvedPath -Raw
        $sb = [scriptblock]::Create($content)
        $sb.CheckRestrictedLanguage($null, $null, $true)
        $sb.Invoke()
    }
    catch
    {
        $errorMessage = $LocalizedData.EnvironmentContentError -f $FilePath
        $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage
        Write-Error -Exception $exception -Message $errorMessage -Category InvalidOperation -ErrorId InvalidEnvironmentContentSpecified
        Update-ConfigurationErrorCount
    }
}

function Get-DSCResourceModules
{
    $listPSModuleFolders = $env:PSModulePath.Split(":")
    $dscModuleFolderList = [System.Collections.Generic.HashSet[System.String]]::new()

    foreach ($folder in $listPSModuleFolders)
    {
        if (!(Test-Path $folder))
        {
            continue
        }

        foreach($moduleFolder in Get-ChildItem $folder -Directory)
        {
            $addModule = $false

            $dscFolders = Get-childitem "$($moduleFolder.FullName)\DscResources","$($moduleFolder.FullName)\*\DscResources" -ErrorAction Ignore
            if($null -ne $dscFolders)
            {
                $addModule = $true
            }

            if(-not $addModule)
            {
                foreach($psd1 in Get-ChildItem -Recurse -Filter "$($moduleFolder.Name).psd1" -Path $moduleFolder.fullname -Depth 2)
                {
                    $containsDSCResource = select-string -LiteralPath $psd1 -pattern '^[^#]*\bDscResourcesToExport\b.*'
                    if($null -ne $containsDSCResource)
                    {
                        $addModule = $true
                    }
                }
            }

            if($addModule)
            {
                $dscModuleFolderList.Add($moduleFolder.Name)
            }
        }
    }

    $dscModuleFolderList
}

###########################################################
#  Get-DSCResource
###########################################################

#
# Gets DSC resources on the machine. Allows to filter on a particular resource.
# It parses all the resources defined in the schema.mof file and also the composite
# resources defined or imported from PowerShell modules
#
function Get-DscResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSProvideCommentHelp", "", Scope="Function", Target="*")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPositionalParameters", "", Scope="Function", Target="*")]
    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=403985')]
    [OutputType('Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo[]')]
    [OutputType('string[]')]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Module,

        [Parameter()]
        [switch]
        $Syntax
    )

    Begin
    {
        $initialized = $false
        $ModuleString = $null
        Write-Progress -Id 1 -Activity $LocalizedData.LoadingDefaultCimKeywords

        $keywordErrors = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Exception]'

        # Load the default Inbox providers (keyword) in cache, also allow caching the resources from multiple versions of modules.
        [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::LoadDefaultCimKeywords($keywordErrors, $true)

        foreach($ex in $keywordErrors)
        {
            Write-Error -Exception $ex
            if($ex.InnerException)
            {
                Write-Error -Exception $ex.InnerException
            }
        }

        Write-Progress -Id 2 -Activity $LocalizedData.GettingModuleList

        $initialized = $true

        if($Module) #Pick from the specified module if there's one
        {
            $moduleSpecificName = [System.Management.Automation.LanguagePrimitives]::ConvertTo($Module,[Microsoft.PowerShell.Commands.ModuleSpecification])
            $modules = Get-Module -ListAvailable -FullyQualifiedName $moduleSpecificName

            if($Module -is [System.Collections.Hashtable])
            {
                $ModuleString = $Module.ModuleName
            }
            elseif($Module -is [Microsoft.PowerShell.Commands.ModuleSpecification])
            {
                $ModuleString = $Module.Name
            }
            else
            {
                $ModuleString = $Module
            }
        }
        else
        {
            $dscResourceModules = Get-DSCResourceModules
            if($null -ne $dscResourceModules) {
                $modules = Get-Module -ListAvailable -Name ($dscResourceModules)
            }
        }

        foreach ($mod in $modules)
        {
            if ($mod.ExportedDscResources.Count -gt 0)
            {
                $null = ImportClassResourcesFromModule -Module $mod -Resources * -functionsToDefine $functionsToDefine
            }

            $dscResources = Join-Path -Path $mod.ModuleBase -ChildPath 'DscResources'
            if(Test-Path $dscResources)
            {
                foreach ($resource in Get-ChildItem -Path $dscResources -Directory -Name)
                {
                    $null = ImportCimAndScriptKeywordsFromModule -Module $mod -Resource $resource -functionsToDefine $functionsToDefine
                }
            }
        }

        $Resources = @()
    }

    Process
    {
        try
        {
            if ($null -ne $Name)
            {
                $nameMessage = $LocalizedData.GetDscResourceInputName -f @('Name', [system.string]::Join(', ', $Name))
                Write-Verbose -Message $nameMessage
            }

            if(!$modules)
            {
                #Return if no modules were found with the required specification
                Write-Warning -Message $LocalizedData.NoModulesPresent
                return
            }

            $ignoreResourceParameters = @('InstanceName', 'OutputPath', 'ConfigurationData') + [System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters

            $patterns = GetPatterns $Name

            Write-Progress -Id 3 -Activity $LocalizedData.CreatingResourceList

            # Get resources for CIM cache
            $keywords = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::GetCachedKeywords() | Where-Object -FilterScript {
                (!$_.IsReservedKeyword) -and ($null -ne $_.ResourceName) -and !(IsHiddenResource $_.ResourceName) -and (![bool]$Module -or ($_.ImplementingModule -like $ModuleString))
            }

            $Resources += $keywords |
            ForEach-Object -Process {
                GetResourceFromKeyword -keyword $_ -patterns $patterns -modules $modules
            } |
            Where-Object -FilterScript {
                $_ -ne $null
            }

            # Get composite resources
            $Resources += Get-Command -CommandType Configuration |
            ForEach-Object -Process {
                GetCompositeResource $patterns $_ $ignoreResourceParameters -modules $modules
            } |
            Where-Object -FilterScript {
                $_ -ne $null -and (![bool]$ModuleString -or ($_.Module -like $ModuleString)) -and
                ($_.Path -and ((Split-Path -Leaf $_.Path) -eq "$($_.Name).schema.psm1"))
            }

            # check whether all resources are found
            CheckResourceFound $Name $Resources
        }
        catch
        {
            if ($initialized)
            {
                [System.Management.Automation.Language.DynamicKeyword]::Reset()
                [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ClearCache()

                $initialized = $false
            }

            throw $_
        }
    }

    End
    {
        $Resources = $Resources | Sort-Object -Property Module, Name
        foreach ($resource in $Resources)
        {
            # return formatted string if required
            if ($Syntax)
            {
                GetSyntax $resource | Write-Output
            }
            else
            {
                Write-Output -InputObject $resource
            }
        }

        if ($initialized)
        {
            [System.Management.Automation.Language.DynamicKeyword]::Reset()
            [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ClearCache()

            $initialized = $false
        }
    }
}

#
# Get DSC resoruce for a dynamic keyword
#
function GetResourceFromKeyword
{
    [OutputType('Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo')]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.Language.DynamicKeyword]
        $keyword,
        [System.Management.Automation.WildcardPattern[]]
        $patterns,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSModuleInfo[]]
        $modules
    )

    $implementationDetail = 'ScriptBased'

    # Find whether $name follows the pattern
    $matched = (IsPatternMatched $patterns $keyword.ResourceName) -or (IsPatternMatched $patterns $keyword.Keyword)
    if ($matched -eq $false)
    {
        $message = $LocalizedData.ResourceNotMatched -f @($keyword.Keyword)
        Write-Verbose -Message ($message)
        return
    }
    else
    {
        $message = $LocalizedData.CreatingResource -f @($keyword.Keyword)
        Write-Verbose -Message $message
    }

    $resource = New-Object -TypeName Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo

    $resource.ResourceType = $keyword.ResourceName

    if ($keyword.ResourceName -ne $keyword.Keyword)
    {
        $resource.FriendlyName = $keyword.Keyword
    }

    $resource.Name = $keyword.Keyword

    $schemaFiles = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::GetFileDefiningClass($keyword.ResourceName)

    if ($schemaFiles.Count)
    {
        # Find the correct schema file that matches module name and version
        # if same module/version is installed in multiple locations, then pick the first schema file.
        foreach ($schemaFileName in $schemaFiles){
            $moduleInfo = GetModule $modules $schemaFileName;
            if ($moduleInfo.Name -eq $keyword.ImplementingModule -and $moduleInfo.Version -eq $keyword.ImplementingModuleVersion){
                break
            }
        }

        # if the class is not a resource we will ignore it except if it is DSC inbox resource.
        if(-not $schemaFileName.StartsWith("$env:windir\system32\configuration",[stringComparison]::OrdinalIgnoreCase))
        {
            $classesFromSchema = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::GetCachedClassByFileName($schemaFileName)
            if($null -ne  $classesFromSchema)
            {
                # check if the resource is proper DSC resource that always derives from OMI_BaseResource.
                $schemaToProcess = $classesFromSchema | ForEach-Object -Process {
                    if(($_.CimSystemProperties.ClassName -ieq $keyword.ResourceName) -and ($_.CimSuperClassName -ieq 'OMI_BaseResource'))
                    {
                        if ([ExperimentalFeature]::IsEnabled("PSDesiredStateConfiguration.InvokeDscResource"))
                        {
                            $_ | Add-Member -MemberType NoteProperty -Name 'ImplementationDetail' -Value $implementationDetail -PassThru
                        }
                        else
                        {
                            $_
                        }
                    }
                }
                if($null -eq  $schemaToProcess)
                {
                    return
                }
            }
        }

        $message = $LocalizedData.SchemaFileForResource -f @($schemaFileName)
        Write-Verbose -Message $message

        $resource.Module = $moduleInfo
        $resource.Path = GetImplementingModulePath $schemaFileName
        $resource.ParentPath = Split-Path $schemaFileName
    }
    else
    {
        $implementationDetail = 'ClassBased'
        $Module = $modules | Where-Object -FilterScript {
            $_.Name -eq $keyword.ImplementingModule -and
            $_.Version -eq $keyword.ImplementingModuleVersion
        }

        if ($Module -and $Module.ExportedDscResources -contains $keyword.Keyword)
        {
            $implementationDetail = 'ClassBased'
            $resource.Module = $Module
            $resource.Path = $Module.Path
            $resource.ParentPath = Split-Path -Path $Module.Path
        }
    }

    if ([system.string]::IsNullOrEmpty($resource.Path) -eq $false)
    {
        $resource.ImplementedAs = [Microsoft.PowerShell.DesiredStateConfiguration.ImplementedAsType]::PowerShell
    }
    else
    {
        $implementationDetail = $null
        $resource.ImplementedAs = [Microsoft.PowerShell.DesiredStateConfiguration.ImplementedAsType]::Binary
    }

    if ($null -ne $resource.Module)
    {
        $resource.CompanyName = $resource.Module.CompanyName
    }

    # add properties
    $keyword.Properties.Values | ForEach-Object -Process {
        AddDscResourceProperty $resource $_
    }

    # sort properties
    $updatedProperties = $resource.Properties | Sort-Object -Property @{
        expression = 'IsMandatory'
        Descending = $true
    }, @{
        expression = 'Name'
        Ascending  = $true
    }
    $resource.UpdateProperties($updatedProperties)
    if ([ExperimentalFeature]::IsEnabled("PSDesiredStateConfiguration.InvokeDscResource"))
    {
        $resource | Add-Member -MemberType NoteProperty -Name 'ImplementationDetail' -Value $implementationDetail
    }

    return $resource
}

#
# Gets composite resource
#
function GetCompositeResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPositionalParameters", "", Scope="Function", Target="*")]
    [OutputType('Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo')]
    param (
        [System.Management.Automation.WildcardPattern[]]
        $patterns,
        [Parameter(Mandatory)]
        [System.Management.Automation.ConfigurationInfo]
        $configInfo,
        $ignoreParameters,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSModuleInfo[]]
        $modules
    )

    # Find whether $name follows the pattern
    $matched = IsPatternMatched $patterns $configInfo.Name
    if ($matched -eq $false)
    {
        $message = $LocalizedData.ResourceNotMatched -f @($configInfo.Name)
        Write-Verbose -Message ($message)

        return $null
    }
    else
    {
        $message = $LocalizedData.CreatingResource -f @($configInfo.Name)
        Write-Verbose -Message $message
    }

    $resource = New-Object -TypeName Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo

    $resource.ResourceType = $configInfo.Name
    $resource.FriendlyName = $null
    $resource.Name = $configInfo.Name
    $resource.ImplementedAs = [Microsoft.PowerShell.DesiredStateConfiguration.ImplementedAsType]::Composite

    if ($null -ne $configInfo.Module)
    {
        $resource.Module = GetModule $modules $configInfo.Module.Path
        if($null -eq $resource.Module)
        {
            $resource.Module = $configInfo.Module
        }
        $resource.CompanyName = $configInfo.Module.CompanyName
        $resource.Path = $configInfo.Module.Path
        $resource.ParentPath = Split-Path -Path $resource.Path
    }

    # add properties
    $configInfo.Parameters.Values | ForEach-Object -Process {
        AddDscResourcePropertyFromMetadata $resource $_ $ignoreParameters
    }

    $resource | Add-Member -MemberType NoteProperty -Name 'ImplementationDetail' -Value $null
    return $resource
}

#
# Adds property to a DSC resource
#
function AddDscResourceProperty
{
    param (
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]
        $dscresource,
        [Parameter(Mandatory)]
        $property
    )

    $convertTypeMap = @{
        'MSFT_Credential'='[PSCredential]';
        'MSFT_KeyValuePair'='[HashTable]';
        'MSFT_KeyValuePair[]'='[HashTable]'
    }

    $ignoreProperties = @('ResourceId', 'ConfigurationName')
    if ($ignoreProperties -contains $property.Name)
    {
        return
    }

    $dscProperty = New-Object -TypeName Microsoft.PowerShell.DesiredStateConfiguration.DscResourcePropertyInfo
    $dscProperty.Name = $property.Name
    if ($convertTypeMap.ContainsKey($property.TypeConstraint))
    {
        $type = $convertTypeMap[$property.TypeConstraint]
    }
    else
    {
        $Type = [System.Management.Automation.LanguagePrimitives]::ConvertTypeNameToPSTypeName($property.TypeConstraint)
    }

    if ($null -ne $property.ValueMap)
    {
        $property.ValueMap.Keys |
        Sort-Object |
        ForEach-Object -Process {
            $dscProperty.Values.Add($_)
        }
    }

    $dscProperty.PropertyType = $Type
    $dscProperty.IsMandatory = $property.Mandatory

    $dscresource.Properties.Add($dscProperty)
}

#
# Adds property to a DSC resource
#
function AddDscResourcePropertyFromMetadata
{
    param (
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]
        $dscresource,
        [Parameter(Mandatory)]
        [System.Management.Automation.ParameterMetadata]
        $parameter,
        $ignoreParameters
    )

    if ($ignoreParameters -contains $parameter.Name)
    {
        return
    }

    $dscProperty = New-Object -TypeName Microsoft.PowerShell.DesiredStateConfiguration.DscResourcePropertyInfo
    $dscProperty.Name = $parameter.Name

    # adding [] in Type name to keep it in sync with the name returned from LanguagePrimitives.ConvertTypeNameToPSTypeName
    $dscProperty.PropertyType = '[' +$parameter.ParameterType.Name + ']'
    $dscProperty.IsMandatory = $parameter.Attributes.Mandatory

    $dscresource.Properties.Add($dscProperty)
}

#
# Gets syntax for a DSC resource
#
function GetSyntax
{
    [OutputType('string')]
    param (
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]
        $dscresource
    )

    $output  = $dscresource.Name + " [String] #ResourceName`n"
    $output += "{`n"
    foreach ($property in $dscresource.Properties)
    {
        $output += '    '
        if ($property.IsMandatory -eq $false)
        {
            $output += '['
        }

        $output += $property.Name

        $output += ' = ' + $property.PropertyType + ''

        # Add possible values
        if ($property.Values.Count -gt 0)
        {
            $output += '{ ' +  [system.string]::Join(' | ', $property.Values) + ' }'
        }

        if ($property.IsMandatory -eq $false)
        {
            $output += ']'
        }

        $output += "`n"
    }

    $output += "}`n"

    return $output
}

#
# Checks whether a resource is found or not
#
function CheckResourceFound($names, $Resources)
{
    if ($null -eq $names)
    {
        return
    }

    $namesWithoutWildcards = $names | Where-Object -FilterScript {
        [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($_) -eq $false
    }

    foreach ($Name in $namesWithoutWildcards)
    {
        $foundResources = $Resources | Where-Object -FilterScript {
            ($_.Name -eq $Name) -or ($_.ResourceType -eq $Name)
        }
        if ($foundResources.Count -eq 0)
        {
            $errorMessage = $LocalizedData.ResourceNotFound -f @($Name, 'Resource')
            Write-Error -Message $errorMessage
        }
    }
}

#
# Get implementing module path
#
function GetImplementingModulePath
{
    param (
        [Parameter(Mandatory)]
        [string]
        $schemaFileName
    )

    $moduleFileName = ($schemaFileName -replace ".schema.mof$", '') + '.psd1'
    if (Test-Path $moduleFileName)
    {
        return $moduleFileName
    }

    $moduleFileName = ($schemaFileName -replace ".schema.mof$", '') + '.psm1'
    if (Test-Path $moduleFileName)
    {
        return $moduleFileName
    }

    return
}

#
# Gets module for a DSC resource
#
function GetModule
{
    [OutputType('System.Management.Automation.PSModuleInfo')]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSModuleInfo[]]
        $modules,
        [Parameter(Mandatory)]
        [string]
        $schemaFileName
    )

    if($null -eq $schemaFileName)
    {
        return $null
    }

    $schemaFileExt = $null
    if ($schemaFileName -match '.schema.mof')
    {
        $schemaFileExt = ".schema.mof$"
    }

    if ($schemaFileName -match '.schema.psm1')
    {
        $schemaFileExt = ".schema.psm1$"
    }

    if(!$schemaFileExt)
    {
        return $null
    }

    # get module from parent directory.
    # Desired structure is : <Module-directory>/DscResources/<schema file directory>/schema.File
    $validResource = $false
    $schemaDirectory = Split-Path $schemaFileName
    if($schemaDirectory)
    {
        $subDirectory = [System.IO.Directory]::GetParent($schemaDirectory)

        if ($subDirectory -and ($subDirectory.Name -eq 'DscResources') -and $subDirectory.Parent)
        {
            $results = $modules | Where-Object -FilterScript {
                $_.ModuleBase -eq $subDirectory.Parent.FullName
            }

            if ($results)
            {
                # Log Resource is internally handled by the CA. There is no formal provider for it.
                if ($schemaFileName -match 'MSFT_LogResource')
                {
                    $validResource = $true
                }
                else
                {
                    # check for proper resource module
                    foreach ($ext in @('.psd1', '.psm1', '.dll', '.cdxml'))
                    {
                        $resModuleFileName = ($schemaFileName -replace $schemaFileExt, '') + $ext
                        if(Test-Path($resModuleFileName))
                        {
                            $validResource = $true
                            break
                        }
                    }
                }
            }
        }
    }

    if ($results -and $validResource)
    {
        return $results[0]
    }
    else
    {
        return $null
    }
}

#
# Checks whether a resource is hidden or not
#
function IsHiddenResource
{
    param (
        [Parameter(Mandatory)]
        [string]
        $ResourceName
    )

    $hiddenResources = @(
        'OMI_BaseResource',
        'MSFT_KeyValuePair',
        'MSFT_BaseConfigurationProviderRegistration',
        'MSFT_CimConfigurationProviderRegistration',
        'MSFT_PSConfigurationProviderRegistration',
        'OMI_ConfigurationDocument',
        'MSFT_Credential',
        'MSFT_DSCMetaConfiguration',
        'OMI_ConfigurationDownloadManager',
        'OMI_ResourceModuleManager',
        'OMI_ReportManager',
        'MSFT_FileDownloadManager',
        'MSFT_WebDownloadManager',
        'MSFT_FileResourceManager',
        'MSFT_WebResourceManager',
        'MSFT_WebReportManager',
        'OMI_MetaConfigurationResource',
        'MSFT_PartialConfiguration',
        'MSFT_DSCMetaConfigurationV2'
    )

    return $hiddenResources -contains $ResourceName
}

#
# Gets patterns for names
#
function GetPatterns
{
    [OutputType('System.Management.Automation.WildcardPattern[]')]
    param (
        [string[]]
        $names
    )

    $patterns = @()

    if ($null -eq $names)
    {
        return $patterns
    }

    foreach ($Name in $names)
    {
        $patterns += New-Object -TypeName System.Management.Automation.WildcardPattern -ArgumentList @($Name, [System.Management.Automation.WildcardOptions]::IgnoreCase)
    }

    return $patterns
}

#
# Checks whether an input name matches one of the patterns
# $pattern is not expected to have an empty or null values
#
function IsPatternMatched
{
    [OutputType('bool')]
    param (
        [System.Management.Automation.WildcardPattern[]]
        $patterns,
        [Parameter(Mandatory)]
        [string]
        $Name
    )

    if ($null -eq $patterns)
    {
        return $true
    }

    foreach ($pattern in $patterns)
    {
        if ($pattern.IsMatch($Name))
        {
            return $true
        }
    }

    return $false
}

Export-ModuleMember -Function Get-DscResource, Configuration

function Invoke-DscResource
{
    [Experimental("PSDesiredStateConfiguration.InvokeDscResource", "Show")]
    [CmdletBinding(HelpUri = '')]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.PowerShell.Commands.ModuleSpecification]
        $ModuleName,
        [Parameter(Mandatory)]
        [ValidateSet('Get','Set','Test')]
        [string]
        $Method,
        [Parameter(Mandatory)]
        [Hashtable]
        $Property
    )

    $getArguments = @{
        Name = $Name
    }

    if($Property.ContainsKey('PsDscRunAsCredential'))
    {
        $errorMessage = $LocalizedData.PsDscRunAsCredentialNotSupport -f $name
        $exception = [System.ArgumentException]::new($errorMessage,'Name')
        ThrowError -ExceptionName 'System.ArgumentException' -ExceptionMessage $errorMessage -ExceptionObject $exception -ErrorId 'PsDscRunAsCredentialNotSupport,Invoke-DscResource' -ErrorCategory InvalidArgument
    }

    if($ModuleName)
    {
        $getArguments.Add('Module',$ModuleName)
    }

    Write-Debug -Message "Getting DSC Resource $Name"
    $resource = @(Get-DscResource @getArguments -ErrorAction stop)

    if($resource.Count -eq 0)
    {
        throw "unexpected state - no resources found - get-dscresource should have thrown"
    }

    if($resource.Count -ne 1)
    {
        $errorMessage = $LocalizedData.InvalidResourceSpecification -f $name
        $exception = [System.ArgumentException]::new($errorMessage,'Name')
        ThrowError -ExceptionName 'System.ArgumentException' -ExceptionMessage $errorMessage -ExceptionObject $exception -ErrorId 'InvalidResourceSpecification,Invoke-DscResource' -ErrorCategory InvalidArgument
    }

    if ( @($resource.Properties | Where-Object { $_.PropertyType -eq '' }).Count -gt 0 -and ($IsMacOS -or $IsLinux)) {
        Write-Warning -Message $LocalizedData.EmbeddedResourcesNotSupported
    }

    [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo] $resource = $resource[0]
    if($resource.ImplementedAs -ne 'PowerShell')
    {
        $errorMessage = $LocalizedData.UnsupportedResourceImplementation -f $name, $resource.ImplementedAs
        $exception = [System.InvalidOperationException]::new($errorMessage)
        ThrowError -ExceptionName 'System.InvalidOperationException' -ExceptionMessage $errorMessage -ExceptionObject $exception -ErrorId 'UnsupportedResourceImplementation,Invoke-DscResource' -ErrorCategory InvalidOperation
    }

    $resourceInfo = $resource |out-string
    Write-Debug $resourceInfo

    if($resource.ImplementationDetail -eq 'ClassBased')
    {
        Invoke-DscClassBasedResource -Resource $resource -Method $Method -Property $Property
    }
    else
    {
        Invoke-DscScriptBasedResource -Resource $resource -Method $Method -Property $Property
    }
}

# Class to return Test method results for Invoke-DscResource
class InvokeDscResourceTestResult {
    [bool] $InDesiredState
}

# Class to return Set method results for Invoke-DscResource
class InvokeDscResourceSetResult {
    [bool] $RebootRequired
}

function Invoke-DscClassBasedResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Scope="Function")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Scope="Function")]
    param(
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo] $resource,
        [Parameter(Mandatory)]
        [ValidateSet('Get','Set','Test')]
        [string]
        $Method,
        [Hashtable]
        $Property
    )

    $path = $resource.Path
    $type = $resource.ResourceType

    Write-Debug "Importing $path ..."
    $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault2()
    $powershell = [PowerShell]::Create($iss)
    $script = @"
using module $path

Write-Host -Message ([$type]::new | out-string)
return [$type]::new()
"@


    $null= $powershell.AddScript($script)
    $dscType=$powershell.Invoke() | Select-object -First 1
    foreach($key in $Property.Keys)
    {
        $value = $Property.$key
        Write-Debug "Setting $key to $value"
        $dscType.$key = $value
    }
    $info = $dscType | Out-String
    Write-Debug $info

    Write-Debug "calling $type.$Method() ..."
    $global:DSCMachineStatus = $null
    $output = $dscType.$Method()
    return Get-InvokeDscResourceResult -Output $output -Method $Method
}

function Invoke-DscScriptBasedResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Scope="Function")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Scope="Function")]
    param(
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo] $resource,
        [Parameter(Mandatory)]
        [ValidateSet('Get','Set','Test')]
        [string]
        $Method,
        [Hashtable]
        $Property
    )

    $path = $resource.Path
    $type = $resource.ResourceType

    Write-Debug "Importing $path ..."
    Import-module -Scope Local -Name $path -Force -ErrorAction stop

    $functionName = "$Method-TargetResource"

    Write-Debug "calling $name\$functionName ..."
    $global:DSCMachineStatus = $null
    $output = & $type\$functionName @Property
    return Get-InvokeDscResourceResult -Output $output -Method $Method
}

function Get-InvokeDscResourceResult
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Scope="Function")]
    param(
        $Output,
        $Method
    )

    switch($Method)
    {
        'Set' {
            $Output | Foreach-Object -Process {
                Write-Verbose -Message ('output: ' + $_)
            }
            $rebootRequired = if($global:DSCMachineStatus -eq 1) {$true} else {$false}
            return [InvokeDscResourceSetResult]@{
                RebootRequired = $rebootRequired
            }
        }
        'Test' {
            return [InvokeDscResourceTestResult]@{
                InDesiredState = $Output
            }
        }
        default {
            return $Output
        }
    }
}

Export-ModuleMember -Function @(
        'Invoke-DscResource'
    )

###########################################################


###########################################################
#  Aliases
###########################################################
New-Alias -Name 'sacfg' -Value 'Start-DSCConfiguration'
New-Alias -Name 'tcfg' -Value 'Test-DSCConfiguration'
New-Alias -Name 'gcfg' -Value 'Get-DSCConfiguration'
New-Alias -Name 'rtcfg' -Value 'Restore-DSCConfiguration'
New-Alias -Name 'glcm' -Value 'Get-DSCLocalConfigurationManager'
New-Alias -Name 'slcm' -Value 'Set-DSCLocalConfigurationManager'
New-Alias -Name 'pbcfg' -Value 'Publish-DSCConfiguration'
New-Alias -Name 'ulcm' -Value 'Update-DscLocalConfigurationManager'
New-Alias -Name 'upcfg' -Value 'Update-DSCConfiguration'
New-Alias -Name 'gcfgs' -Value 'Get-DscConfigurationStatus'
