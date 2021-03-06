function Show-Logo
{
    <#
    .Synopsis
        Shows a simple text logo
    .Description
        Creates a logo out of any text, with a ton of options.
    .Example
        Show-Logo "A Logo" -FeelingLucky
    .Notes
    |HideParameterOnline Show, AsJob, AsType, InMemory, OutputUI, NoGuid, Row, Column, RowSpan, ColumnSpan, Name, Width, Height, Top, Left     
    #>
    [OutputType([IO.FileInfo], [byte[]])]
    param(
    # The text to show in the logo
    #|Default: Show-Logo
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=0)]
    [string]$Text = "Show-Logo",
    # The font to use for the logo 
    #|Default Kartika        
    #|Options Get-Font | Sort-Object
    [ValidateScript({
    $fonts = Get-Font
    if ($fonts-contains $_) {
        return $true
    } else {
        throw "$_ is not an installed font.  Installed fonts: $fonts"
    }
    })]
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
    [string]$Font = "Kartika",
    # The font size
    #|Default 14
    #|MaxLength 120
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=2)]
    [int]
    $Size = 36,
    # The number of dots per inch
    #|Default 72
    [ValidateRange(72, 300)]
    [int]$DotsPerInch = 72,
    # Changes the font stretching used in the logo.  
    # Not all fonts support font stretching.
    #|Default Normal
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=7)]
    [ValidateSet('Condensed', 'Expanded','ExtraCondensed',
        'ExtraExpanded','Medium','Normal','SemiCondensed',
        'SemiExpanded','UltraCondensed','UltraExpanded')]
    [string]
    $Stretch = "Normal", 
    
    # Changes the font stretching used in the logo.  
    # Not all fonts support font stretching.
    #|Default Normal
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=6)]
    [ValidateSet('Black', 'Bold','DemiBold',
        'ExtraBlack','ExtraBold','ExtraLight','Heavy',
        'Light','Medium','Normal', 'Regular', 'SemiBold', 
        'Thin', 'UltraBlack', 'UltraBold', 'UltraLight')]
    [string]
    $Weight = "Normal",        
    # If set, attempts to use the italic font style
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=11)]
    [switch]$Italic,
    
    # If set, uses the oblique font style.  
    # Oblique slants fonts to the right, like italics, but uses the normal font glyph.  
    # This results text with stronger edges than most italics.
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=12)]
    [switch]$Oblique,
        
    # If set, underlines the logo
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=13)]
    [switch]$Underline,    
    # Overlines the logo
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=14)]
    [switch]$Overline,
    # Strikethrus the lgoo
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=15)]
    [switch]$StrikeThru,    
    # The foreground color
    
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=9)]    
    [string]$ForegroundColor,
    # The background color
    
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=10)]
    [string]$BackgroundColor,
    # The foreground brush
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=21)]
    [string]$ForegroundBrush,
    # The background brush
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=22)]
    [string]$BackgroundBrush,
    
    # The rotation of the image
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=8)]
    [Double]$Rotation,
    
    # The Horizontal Skew Angle
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=16)]
    [Double]$SkewAngleHorizontal,
    # The Skew Angle 
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=17)]
    [Double]$SkewAngleVertical,
    # The horizontal center point of the rotation or the skew.  
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=18)]
    [Double]$HorizontalCenter,        
    # The vertical center point of the rotation or the skew.  
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=19)]
    [Double]$VerticalCenter,
    # The margin surrounding the image
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=20)]
    [int]$Margin,
    # If set, will randomly pick a font and size
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=4)]
    [switch]$FeelingLucky,
    # If set, will randomly pick a font, size, weight, and style
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=5)]
    [switch]$FeelingReallyLucky,
    # If set, will randomly pick a font
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=3)]
    [switch]$RandomFont,
    [ValidateSet('Jpeg','Png','Tiff', 'Gif')]    
    [string]
    $AsType = "Png",
    
    [Double]$Top,
    [Double]$Left,
    [int]$Row,
    [int]$Column,
    [int]$RowSpan,
    [int]$ColumnSpan,
    [switch]$Show,
    [switch]$AsJob,
    [switch]$InMemory,
    [Double]$Width,
    [Double]$Height,
    [string]$Name,
    # If set, outputs the UI Element instead of a screenshot.
    [switch]$OutputUI,
    # If set, omits the guid from the outputted file
    [switch]$NoGuid                 
    )
    
    process {
        #region Feeling Lucky Comes first
        if ($FeelingReallyLucky) {
            $psBoundParameters.Stretch = 
                'Condensed', 'Expanded','ExtraCondensed',
                'ExtraExpanded','Medium','Normal','SemiCondensed',
                'SemiExpanded','UltraCondensed','UltraExpanded' | 
                    Get-Random
                    
            $psBoundParameters.Weight = 
                'Condensed', 'Expanded','ExtraCondensed',
                'ExtraExpanded','Medium','Normal','SemiCondensed',
                'SemiExpanded','UltraCondensed','UltraExpanded' | 
                    Get-Random                                
        
            $Font =  Get-Font | Get-Random
                
            $Size = 12..48 | Get-Random
        } elseif ($feelingLucky) {
            $Font =  Get-Font | Get-Random
            $Size = 12..48 | Get-Random
        } elseif ($RandomFont) {
            $Font =  Get-Font | Get-Random
        }
        
        #endregion


        #region Copy Core UI Parameters
        $coreUIParameters = @{}
        foreach ($parameter in 'Top', 'Left', 'Width', 'Height', 'RowSpan', 
            'ColumnSpan', 'Row','Column', 'Name', 'Show', 'AsJob') {
            if ($psBoundParameters.$parameter) {
                $coreUIParameters.$parameter = $psBoundParameters.$parameter
            }
        }
        #endregion
        
        $textBlockParameters = @{
            Text = $text
            FontFamily = $font
            FontSize = $size           
        }         
        
        
        if ($psBoundParameters.Stretch) {
            $textBlockParameters.FontStretch = $Stretch
        }
        
        if ($psBoundParameters.Weight) {
            $textBlockParameters.FontStretch = $Weight
        }
        
        if ($Italic) {
            $textBlockParameters.FontStyle = "Italic"
        } elseif ($Oblique) {
            $textBlockParameters.FontStyle = "Oblique"
        }
        
        if ($OverLine) {
            $textBlockParameters.TextDecoration = [Windows.TextDecorations]::OverLine   
        } elseif ($Underline) {
            $textBlockParameters.TextDecoration = [Windows.TextDecorations]::Underline
        } elseif ($strikeout) {
            $textBlockParameters.TextDecoration = [Windows.TextDecorations]::Strikethrough
        }
        
        if ($psBoundParameters.foregroundBrush) {
            $textBlockParameters.Foreground = try { 
                [Windows.Markup.XamlReader]::Parse($psBoundParameters.foregroundBrush)
            } catch { 
            }
        } elseif ($psBoundParameters.foregroundColor) {
            $textBlockParameters.Foreground= $psBoundParameters.foregroundColor
        }
        
        if ($psBoundParameters.backgroundBrush) {
            $textBlockParameters.background = try { 
                [Windows.Markup.XamlReader]::Parse($psBoundParameters.backgroundBrush)
            } catch { 
            }
        } elseif ($psBoundParameters.backgroundColor) {
            $textBlockParameters.background= $psBoundParameters.backgroundColor
        }
        
        if ($Rotation) {
            $textBlockParameters.LayoutTransform = New-RotateTransform -Angle $rotation -CenterX $HorizontalCenter -CenterY $VerticalCenter            
        } elseif ($SkewAngleHorizontal -or $SkewAngleVertical) {
            $textBlockParameters.LayoutTransform = New-SkewTransform -AngleX $SkewAngleHorizontal -AngleY $SkewAngleVertical -CenterX $HorizontalCenter -CenterY $VerticalCenter            
        }
        
        
        
        if ($outputUI) {       
            [Windows.Markup.XamlReader]::Parse((New-TextBlock @textblockParameters -OutputXaml))                 
        } else {
            $screenShotParameters = @{}
            $screenShotParameters."As${asType}" = $true
            $safeText = $text -ireplace "[\/\?<>\\\:\*\|`"]", "_"
            $guidText = if ($noGuid) {"" } else {
                ".$([GUID]::NewGuid().ToString().Replace('-',''))"
            }
            $screenShotParameters.OutputPath = "${safeText}${guidText}.${asType}"
            $screenShotParameters.DotsPerInch = $dotsPerInch           
            $screenShotParameters.InMemory = $InMemory
            [Windows.Markup.XamlReader]::Parse((New-TextBlock @textblockParameters -OutputXaml)) | 
                Save-Screenshot @screenShotParameters
        }
    }
}