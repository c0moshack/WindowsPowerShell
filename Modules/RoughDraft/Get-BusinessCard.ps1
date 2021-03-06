function Get-BusinessCard
{
    <#
    .Synopsis
        Gets a business card 
    .Description
        Gets a business card design on demand.  
        
        Select a font and card text, or put in important information and use an automatic layout.
    .Example
        # Raw Layout
        Get-BusinessCard -TextAlignment Center -FontSize 17 -Font "Verdana" -Text @"
Hiro Protagonist

Music.Movies.Microcode.
"@ |
    Invoke-Item

    .Example
        Get-BusinessCard -TextAlignment Center -FontSize 15 -Font "Lucida Console" -Text @"
James Brundage

Start-Automating
"@ |
    Invoke-Item
    .Notes
    |HideParameterOnline AsJob, AsType, InMemory, OutputUI
    .Link
        Show-Logo
    #>
    [CmdletBinding(DefaultParameterSetName='CardText')]
    param(
    # The font to use for the business card
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
    
    
    # The text for the whole card.  If you enter in a complete card text, all other fields are ignored.
    #|LinesForInput 12
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='CardText',Position=0)]
    [string]$Text,
    
    # The text alignment for the whole card
    [ValidateSet('Left','Center','Right')]
    [string]
    $TextAlignment = 'Left',


    # The text alignment for the whole card
    [ValidateSet('Top','Center','Bottom')]
    [string]
    $VerticalAlignment = 'Center',
                
    # The card font size.
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='CardText',Position=2)]
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=2)]
    [ValidateRange(8,72)]
    [Uint32]$FontSize = 14,
    
    # The the text left position
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='CardText',Position=3)]
    [Double]$TextLeftPercent = 3,
    
    # The the text top position
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='CardText',Position=4)]
    [Double]$TextTopPercent = 3,    
    
    # The person's name
    #|Default John Doe
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=0)]
    [string]$Name,
    
    # The person's title
    #|Default Administrator of Something
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=2)]
    [string]$Title, 
    
    # The company name
    #|Default SomeCompany, Inc
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=3)]
    [string]$Company,       
    
    # One or more phone numbers for the card
    #|Default 206.555.1212 (m)    
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=4)]
    [string[]]$PhoneNumber,
    
    # The email address for the business card
    #|Default john.doe@thatssomecompany.com    
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=5)]
    [string]$Email,
    
    # Contacts on social media networks.  One per line.
    #|Default @somebodyfromsomecompany (twitter)
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=6)]
    [string[]]$SocialMedia,
    
    
    # The URL for a logo 
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=7)]
    [Uri]$Logo,

    # The URL for a background image
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=8)]
    [Uri]$BackgroundImage,    
    
    # The foreground color    
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=8)]
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='CardText',Position=3)]
    [string]$ForegroundColor,

    # The background color
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='AutoLayout',Position=9)]
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='CardText',Position=4)]
    [string]$BackgroundColor,

    
    # The alignment for the name and title
    [ValidateSet('Left','Center','Right')]
    [string]
    $NameAndTitleAlignment = 'Center',
    
    # The alignment for the contact information
    [ValidateSet('Left','Center','Right')]
    [string]
    $ContactInfoAlignment = 'Left',
    
    # The number of dots per inch
    #|Default 72
    [ValidateRange(72, 300)]
    [int]$DotsPerInch = 72,
    
    #If Set, makes a vertical business card
    [Switch]
    $Vertical,
    
    [ValidateSet('Jpeg','Png','Tiff', 'Gif')]    
    [string]
    $AsType = "Png",
    
    [switch]$InMemory,
    
    [Switch]$OutputUi,
    
    [Switch]$Show         
    )
    
    process {
        if (-not $Vertical) {
            $width  = 3 * $DotsPerInch
            $height = 2 * $DotsPerInch
        } else {
            $width  = 2 * $DotsPerInch
            $height = 3 * $DotsPerInch
        }
        
        if (-not $backgroundColor) {
            $backgroundColor = 'White'
        }
        
        if (-not $foregroundColor) {
            $foregroundColor = 'Black'
        }
           
        $dimensions = @{Width=$Width;Height=$height}                     
        $fontInfo = @{FontFamily=$font;FontSize=$fontSize}
        $solidBackground = New-Rectangle -Fill $backgroundColor -Width $width -Height $height                                         
        
        $children = if ($psCmdlet.ParameterSetName -eq 'CardText') {
            $solidBackground 
            $realTop = ($textTopPercent / 100) * $height
            $realLeft = ($textLeftPercent / 100) * $width
           
            New-TextBlock -ZIndex 1 -Foreground $foregroundColor -TextAlignment $textAlignment -VerticalAlignment $VerticalAlignment  -Background Transparent -FontFamily $font -FontSize $fontSize -Text $text -Top $realTop -Left $realLeft -Width ($width - $realLeft) -Height ($height - $realTop)
            if ($backgroundImage) {
                $backgroundImage = New-Image -Source $backgroundImage @dimensions 
            }
        } elseif ($psCmdlet.ParameterSetName -eq 'AutoLayout') {
            $solidBackground 
            if ($backgroundImage) {
                $backgroundImage = New-Image -Source $backgroundImage @dimensions
            }

            New-Grid -Columns 2 -Rows 3 @dimensions -Children {                                
                New-TextBlock @fontinfo -TextWrapping Wrap -Text $Name
                New-TextBlock @fontinfo -TextWrapping Wrap -Row 1 -Text $Title
                New-TextBlock @fontinfo -TextWrapping Wrap -Row 2 -Text $Company
                New-TextBlock @fontinfo -TextWrapping Wrap -Column 1 -Text "$PhoneNumber"
                New-TextBlock @fontinfo -TextWrapping Wrap -Column 1 -Row 1 -Text "$Email"
                New-TextBlock @fontinfo -TextWrapping Wrap -Column 1 -Row 2 -Text "$SocialMedia"
            }            
        }
        
        
        $cardCanvas = 
            New-Canvas -Background $backgroundColor @dimensions             
                        
        $children |
            Add-ChildControl -parent $cardCanvas 
            
        if ($psBoundParameters.Show) {
            New-Window -Content $cardCanvas -SizeToContent WidthAndHeight -Show
        } elseif ($psBoundParameters.InMemory) {
            $as = @{}
            $as."As${AsType}" = $true
            $cardCanvas | Save-Screenshot -InMemory @as 
        } else {
            $as = @{}
            $as."As${AsType}" = $true
            $cardCanvas | Save-Screenshot @as
        }

    }
} 

    