function Format-Image
{
    <#
    .Synopsis
        Formats an image at various resolutions
    .Description
        Resizes an image into various resolutions and image formats.      
    #>
    param(
    # The path to the image
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('Fullname')]
    [string]
    $ImagePath,
    
    # The resolutions requested.     
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        $x, $y = $_ -split "x"
        if (0, 1 -notcontains $y.Count) { 
            throw "Not a resolution"
        }
        if (0, 1 -notcontains $x.Count) { 
            throw "Not a resolution"
        }
        if (-not ($x -as [Uint32]) -and ($y -as [Uint32])) {
            throw "Not a resolution"
        }
        return $true
    })]
    [string[]]
    $Resolution,

    # The JPEG Quality
    [Parameter(ParameterSetName='Jpeg')]
    [int]$JpegQuality = 100,

    # The dots per inch
    [Alias('DPI')]
    [int]$DotsPerInch = 96,
        
    [ValidateSet('Jpeg','jpg','Png','Tiff', 'Gif')]    
    [string]
    $AsType = "Png",    
    # The output path.  If this is not set, it will be saved to a randomly named file in the
    # current directory.
    [string]$OutputPath,

    [Switch]$DoNotPreserveAspectRatio


    )

    process {
        $resolvedImagePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($ImagePath)
        
        $imageFile = Get-Item "$resolvedImagePath"        

        $nameMinusExtension = $imageFile.Name.Substring(0, $ImageFile.Name.Length - $imageFile.Extension.Length)
        foreach ($res in $Resolution) {
            if (-not $res) { continue }

            # Loop thru each potential image size
            $w, $h = $res -split "x"
            if (-not $psBoundParameters.OutputPath) {
                if (-not $psBoundParameters.AsType) {
                    $ASType = $imageFile.Extension.TrimStart(".")
                }
                $outputPath = Join-Path $imageFile.Directory "${nameMinusExtension}_${res}.${asType}"
            }

            #region Actual Resize

            $image = New-Object -ComObject Wia.ImageFile
            $image.LoadFile($imageFile.FullName)
            $filter = New-Object -ComObject Wia.ImageProcess
            $index = $filter.Filters.Count + 1
            $scale = $filter.FilterInfos.Item("Scale").FilterId                    
            
            $filter.Filters.Add($scale)
            $filter.Filters.Item($index).Properties.Item("PreserveAspectRatio") = "$(-not $DoNotPreserveAspectRatio)"
            
            $filter.Filters.Item($index).Properties.Item("MaximumWidth") = $w
            $filter.Filters.Item($index).Properties.Item("MaximumHeight") = $h
            $image = $filter.Apply($image.PSObject.BaseObject)

            $image.SaveFile($OutputPath)

            #endregion Actual Resize

            Get-Item -ErrorAction SilentlyContinue -LiteralPath $OutputPath
            
        }
    }
} 
