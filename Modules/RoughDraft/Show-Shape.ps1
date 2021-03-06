function Show-Shape {
    <#
    .Synopsis
        Shows shapes
    .Description
        Shows shapes
    .Example
        Show-Shape "Red" "Circle"    
    #>
    [OutputType([IO.FileInfo], [byte[]])]
    param(
    # The type of shape
    [Parameter(Mandatory=$true,Position=1)]
    [ValidateSet("Circle", "Square", "Rectangle", "Ellipse")] 
    [string]
    $Shape,
    
    # The width of the shape.  By default, 175 pixels
    [Parameter(Position=2)]
    [Double]$Width = 175,

    # The width of the shape.  By default, 175 pixels
    [Parameter(Position=3)]
    [Double]$Height = 175,
        
    # The colors used in the shape.  More than one color will make a gradient.
    [Parameter(Mandatory=$true,Position=0)]
    [string[]]
    $Color = "#012456", 
    
    
    # The anchor points used in the shape.
    [string[]]
    $Points = @(30,30,60,60),
        
    # The rotation of the image
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=8)]
    [Double]$Rotation,
    
    # The Horizontal Skew Angle
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=16)]
    [Double]$SkewAngleHorizontal,
    # The Skew Angle 
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=17)]
    [Double]$SkewAngleVertical,
    
    # The type of image to create
    [ValidateSet('Jpeg','Png','Tiff', 'Gif')]    
    [string]
    $AsType = "Png",

    # The starting point of the gradient
    [string]$GradientStartPoint,

    # The ending point of the gradient
    [string]$GradientEndPoint,

    # A list of gradient stop percents.  If this list is not provided, the gradient stops will be evenly distributed.
    [ValidateRange(0,100)]
    [Uint32[]]$GradientStopPercent,

    # The gradient radius's X value  
    [string]$GradientRadiusX,

    # The gradient radius's y value
    [string]$GradientRadiusY,

    # The gradient radius's center value
    [string]$GradientCenter,
    
    # The top of the shape inside of an image
    [Double]$Top,

    # The left location of the shape inside of an image
    [Double]$Left,

    # The row within a grid that the shape will occupy.
    [int]$Row,

    # The column within a grid that the shape will occupy.
    [int]$Column,

    # The number of rows within a grid that a shape will occupy.
    [int]$RowSpan,

    # The number of columns within a grid that a shape will occupy.
    [int]$ColumnSpan,


    # If set, the shape will be shown
    [switch]$Show,

    # If set, the shape will be displayed in a background job
    [switch]$AsJob,

    # If set, the shape will be displayed in memory
    [switch]$InMemory,
    
    # If provided, the shape will have a name.
    [string]$Name,

    # If set, outputs the UI Element instead of a screenshot.
    [switch]$OutputUI
        
    
    )
    
    process {
        

        $fill = 
            if ($color.Count) {
                $stops = 
                    if ($GradientStopPercent) {
                        for ($i = 0 ; $i -lt $color.Count; $i++) {
                        
                            $n = $GradientStopPercent[$i]   
                            New-GradientStop -Color $color[$i] -Offset $n
                        }
                    } else {
                        $stopAmount = 1 / $Color.Count
                        $n = 0 
                        for ($i = 0 ; $i -lt $color.Count; $i++) {
                            New-GradientStop -Color $color[$i] -Offset $n
                            $n += $stopAmount

                        }
                    }
                
                if ($GradientCenter -or $GradientRadiusX -or $GradientRadiusY) {
                    $radialParameters = @{GradientStops= $stops}
                    if ($GradientRadiusX) {
                        $radialParameters.RadiusX = $GradientRadiusX
                    } 
                    if ($GradientRadiusY) {
                        $radialParameters.RadiusY = $GradientRadiusY
                    }                      
                    if ($GradientCenter) {
                        $radialParameters.Center = $GradientCenter

                    }
                    New-RadialGradientBrush @radialParameters

                } else {
                    $linearParameters = @{GradientStops= $stops}
                    if ($GradientStartPoint) {
                        $linearParameters += @{StartPoint=$GradientStartPoint}
                    } 
                    if ($GradientEndPoint) {
                        $linearParameters += @{EndPoint=$GradientEndPoint}
                    }
                    New-LinearGradientBrush @linearParameters 
                    
                }
            } else {
                "$Color"
            }
 

        $shapeParameters= @{
            Fill = $fill
        }
        
        if ($shape -eq 'ellipse' -or
            $shape -eq 'circle') {
            $shapeCmd = $executionContext.SessionState.InvokeCommand.GetCommand("New-Ellipse", "All")
            
            $shapeParameters.Width = $width
            
            
             
            $shapeParameters.Height = $height
            
        } elseif ($shape -eq 'square' -or
            $shape -eq 'Rectangle'
            ) {
            $shapeCmd = $executionContext.SessionState.InvokeCommand.GetCommand("New-Rectangle", "All")

            
            $shapeParameters.Width = $width
            
            $shapeParameters.Height = $Height
            
        } elseif ($shape -eq 'polygon') {
            $shapeCmd = $executionContext.SessionState.InvokeCommand.GetCommand("New-Polygon", "All")
            $shapeParameters.Width = $width
            
            $shapeParameters.Height = $Height

            
        } elseif ($shape -eq 'polyline') {
            
        }
    
        
        
        
        if ($Rotation) {
            $shapeParameters.LayoutTransform = New-RotateTransform -Angle $rotation -CenterX $HorizontalCenter -CenterY $VerticalCenter            
        } elseif ($SkewAngleVertical) {
            $shapeParameters.LayoutTransform = New-SkewTransform -AngleX $SkewAngleHorizontal -AngleY $SkewAngleVertical -CenterX $HorizontalCenter -CenterY $VerticalCenter            
        }
        if (-not $shapeCmd) { return  }
        $text = "$shape $color ($width*$height)"

        if ($outputUI) {       
            & $shapeCmd @shapeParameters
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

            
            & $shapeCmd @shapeParameters | 
                Save-Screenshot @screenShotParameters
        }
    }
} 
