function Switch-Color
{
    <#
    .Synopsis
        Switches a color up
    .Description
        Switches a color up by changing ratios of a given part or inverting the color
    .Example
    #>
    [CmdletBinding(DefaultParameterSetName='Shift')]
    param(
    # A color
    #|Color
    [ValidateScript({
    $_ -like "??????"    
    })]        
    [Parameter(Mandatory=$true,Position=0)]
    [string]
    $Color,
    
    # If set, will invert the color
    [Parameter(Mandatory=$true,ParameterSetName='Invert')]
    [Switch]
    $Invert,
    
    # If set, will skip processing red
    [switch]$SkipRed,
    
    # If set, will skip processing blue
    [switch]$skipBlue,
    # If set, will skip processing green
    [switch]$skipGreen,
    
    # The ratio of change to apply to the color
    #|Default 1 
    [Double]$Ratio = 1
    )
    
    process {
        $redPart = [int]::Parse($color[1..2]-join'', 
            [Globalization.NumberStyles]::HexNumber)
        $greenPart = [int]::Parse($color[3..4]-join '', 
            [Globalization.NumberStyles]::HexNumber)
        $bluePart = [int]::Parse($color[5..6] -join'', 
            [Globalization.NumberStyles]::HexNumber)
        
        $newr = $redPart
        $newB = $bluePart
        $newg = $greenPart
    
        if ($psCmdlet.PArameterSetName -eq 'Invert') {
            if (-not $skipRed) {
                $newr = (255 - $redPart) * $ratio
            }
        
            if (-not $skipGreen) {
                $newg = (255 - $greenPart) * $ratio
                
            }
        
            if (-not $skipBLue) {
                $newb = (255 - $bluePart) * $ratio
                
            }
        } elseif ($psCmdlet.PArameterSetName -eq 'Shift') {
            $newr = $redPart * $ratio
            $newb = $bluePart * $ratio
            $newg = $greenPart * $ratio
        }
        

        if ($newr -gt 255) {
            $newr = 255
        }
        if ($newg -gt 255) {
            $newg = 255
        }
        if ($newb -gt 255) {
            $newb = 255
        }
        "#" + ("{0:x}" -f ([int]$newr)).PadLeft(2, "0") + ("{0:x}" -f ([int]$newg)).PadLeft(2, "0") + ("{0:x}" -f ([int]$newb)).PadLeft(2, "0") 
    }
}