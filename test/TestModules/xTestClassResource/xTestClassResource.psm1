enum Ensure
{
    Absent
    Present
}

class EmbClass
{
    [DscProperty()]
    [string] $EmbClassStr1
}

[DscResource()]
class xTestClassResource
{
    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string] $Value

    [DscProperty()]
    [Ensure] $Ensure

    [DscProperty()]
    [string[]] $sArray

    [DscProperty()]
    [EmbClass] $EmbClassObj

    [DscProperty()]
    [EmbClass[]] $EmbClassObjArray

    [DscProperty()]
    [DateTime] $dateTimeVal;

    [DscProperty()]
    [DateTime[]] $dateTimeArrayVal;

    [DscProperty()]
    [Boolean] $bValue;

    [DscProperty()]
    [Byte] $uInt8Value;

    [DscProperty()]
    [SByte] $sInt8Value;

    [DscProperty()]
    [UInt16] $uInt16Value;

    [DscProperty()]
    [Int16] $sInt16Value;

    [DscProperty()]
    [UInt32] $uInt32Value;

    [DscProperty()]
    [Int32] $sInt32Value;

    [DscProperty()]
    [UInt64] $uInt64Value;

    [DscProperty()]
    [Int64] $sInt64Value;

    [DscProperty()]
    [Single] $Real32Value;

    [DscProperty()]
    [Double] $Real64Value;

    [DscProperty()]
    [Char] $char16Value;

    [DscProperty()]
    [Boolean[]] $bValueArray;

    [DscProperty()]
    [Byte[]] $uInt8ValueArray;

    [DscProperty()]
    [SByte[]] $sInt8ValueArray;

    [DscProperty()]
    [UInt16[]] $uInt16ValueArray;

    [DscProperty()]
    [Int16[]] $sInt16ValueArray;

    [DscProperty()]
    [UInt32[]] $uInt32ValueArray;

    [DscProperty()]
    [Int32[]] $sInt32ValueArray;

    [DscProperty()]
    [UInt64[]] $uInt64ValueArray;

    [DscProperty()]
    [Int64[]] $sInt64ValueArray;

    [DscProperty()]
    [single[]] $Real32ValueArray;

    [DscProperty()]
    [double[]] $Real64ValueArray;

    [DscProperty()]
    [Char[]] $char16ValueArray;

    [void] Set()
    {

        Set-StrictMode -Version Latest

        if ($this.Ensure -eq [Ensure]::Present)
        {
            if ($this.Value -eq "fail")
            {
                Write-Error "Ensure=Present failed for $($this.Name) due to value $($this.Value)"
            }
        }
        elseif ($this.Ensure -eq [Ensure]::Absent)
        {
            if ($this.Value -eq "fail")
            {
                Write-Error "Ensure=Absent failed for $($this.Name) due to value $($this.Value)"
            }
        }
    }

    [bool] Test()
    {
        Write-Debug "Inside Test()" 
        Set-StrictMode -Version Latest

        [bool] $result = $false

        if ($this.value -eq "fail")
        {
            Write-Error "Failing Test-TargetResource because Value is set to 'fail'"
        }
        else
        {
            Write-Verbose "Start of EmbClassObjArray" -Verbose
            foreach ($classObj in  $this.EmbClassObjArray)
            {
               $classObj.EmbClassStr1 | write-Verbose -verbose
            }
            Write-Verbose "End of EmbClassObjArray" -Verbose

            Write-Verbose "Ensure: $($this.Ensure)" -verbose
            Write-Verbose "sArray: $($this.sArray)" -verbose
            Write-Verbose "dateTimeVal: $($this.dateTimeVal)" -verbose
            Write-Verbose "dateTimeArrayVal: $($this.dateTimeArrayVal)" -verbose
            Write-Verbose "bValue: $($this.bValue)" -verbose
            Write-Verbose "uInt8Value: $($this.uInt8Value)" -verbose
            Write-Verbose "sInt8Value: $($this.sInt8Value)" -verbose
            Write-Verbose "uInt16Value: $($this.uInt16Value)" -verbose
            Write-Verbose "sInt16Value: $($this.sInt16Value)" -verbose
            Write-Verbose "uInt32Value: $($this.uInt32Value)" -verbose
            Write-Verbose "sInt32Value: $($this.sInt32Value)" -verbose
            Write-Verbose "uInt64Value: $($this.uInt64Value)" -verbose
            Write-Verbose "sInt64Value: $($this.sInt64Value)" -verbose
            Write-Verbose "Real32Value: $($this.Real32Value)" -verbose
            Write-Verbose "Real64Value: $($this.Real64Value)" -verbose
            Write-Verbose "bValueArray: $($this.bValueArray)" -verbose
            Write-Verbose "char16Value: $($this.char16Value)" -verbose
            Write-Verbose "uInt8ValueArray: $($this.uInt8ValueArray)" -verbose
            Write-Verbose "sInt8ValueArray: $($this.sInt8ValueArray)" -verbose
            Write-Verbose "uInt16ValueArray: $($this.uInt16ValueArray)" -verbose
            Write-Verbose "sInt16ValueArray: $($this.sInt16ValueArray)" -verbose
            Write-Verbose "uInt32ValueArray: $($this.uInt32ValueArray)" -verbose
            Write-Verbose "sInt32ValueArray: $($this.sInt32ValueArray)" -verbose
            Write-Verbose "uInt64ValueArray: $($this.uInt64ValueArray)" -verbose
            Write-Verbose "sInt64ValueArray: $($this.sInt64ValueArray)" -verbose
            Write-Verbose "Real32ValueArray: $($this.Real32ValueArray)" -verbose
            Write-Verbose "Real64ValueArray: $($this.Real64ValueArray)" -verbose
            Write-Verbose "char16ValueArray: $($this.char16ValueArray)" -verbose

            [Single]$f = -1.000003
            [double]$d = -1.234

            $result = ($this.EmbClassObjArray[1].EmbClassStr1 -eq $this.Ensure) -and `
                      ($this.sArray[1] -eq "s2") -and `
                      ($this.dateTimeVal -lt (get-date 2020-12-12)) -and `
                      ($this.dateTimeArrayVal[1] -gt (get-date 2020-08-20)) -and `
                      ($this.bValue -eq $true) -and `
                      ($this.uInt8Value -eq 255) -and `
                      ($this.sInt8Value -eq -128) -and `
                      ($this.uInt16Value -eq 65535) -and `
                      ($this.sInt16Value -eq -32768) -and `
                      ($this.uInt32Value -eq 4294967295) -and `
                      ($this.sInt32Value -eq -2147483648) -and `
                      ($this.uInt64Value -eq 18446744073709551615) -and `
                      ($this.sInt64Value -eq -9223372036854775808) -and `
                      ($this.Real32Value -eq $f) -and `
                      ($this.Real64Value -eq $d) -and `
                      ($this.bValueArray[1] -eq $true) -and `
                      ($this.char16Value -eq 'c') -and `
                      ($this.uInt8ValueArray[1] -eq 254) -and `
                      ($this.sInt8ValueArray[1] -eq -127) -and `
                      ($this.uInt16ValueArray[1] -eq 65534) -and `
                      ($this.sInt16ValueArray[1] -eq -32767) -and `
                      ($this.uInt32ValueArray[1] -eq 4294967294) -and `
                      ($this.sInt32ValueArray[1] -eq -2147483647) -and `
                      ($this.uInt64ValueArray[1] -eq 18446744073709551614) -and `
                      ($this.sInt64ValueArray[1] -eq -9223372036854775807) -and `
                      ($this.Real32ValueArray[1] -eq $f) -and `
                      ($this.Real64ValueArray[1] -eq $d) -and `
                      ($this.char16ValueArray[1] -eq 'd')
        }

        return $result
    }

    [xTestClassResource] Get()
    {
        Write-Debug "Inside Get()"

        if ($this.Value -ne "fail")
        {
            $this.Value = "Inside if"
        }
        else
        {
            $this.Value = "Inside else"
        }

        # initialize properties so that they are not null
        $this.char16Value = "A"
        $this.sArray = [String[]]::new(0)

        $this.EmbClassObj = [EmbClass]::new()
        $this.EmbClassObj.EmbClassStr1 = "TestEmbObjValue"
        
        $EmbObj = [EmbClass]::new()
        $EmbObj.EmbClassStr1 = "TestEmbClassStr1Value"
        $this.EmbClassObjArray = [EmbClass[]]::new(1)
        $this.EmbClassObjArray[0] = $EmbObj

        $this.dateTimeVal = [DateTime]::Now
        $this.dateTimeArrayVal = [DateTime[]]::new(0)
        $this.bValueArray = [Boolean[]]::new(0)
        $this.char16ValueArray = [Char[]]::new(0)

        $this.uInt8ValueArray = [Byte[]]::new(0)
        $this.sInt8ValueArray = [SByte[]]::new(0)
        $this.uInt16ValueArray = [UInt16[]]::new(0)
        $this.sInt16ValueArray = [Int16[]]::new(0)
        $this.uInt32ValueArray = [UInt32[]]::new(0)
        $this.sInt32ValueArray = [Int32[]]::new(0)
        $this.uInt64ValueArray = [UInt64[]]::new(0)
        $this.sInt64ValueArray = [Int64[]]::new(0)

        $this.Real32ValueArray = [single[]]::new(0)
        $this.Real64ValueArray = [double[]]::new(0)

        return $this
    }
}

