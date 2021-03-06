function Send-Printer
{
    <#
    .Synopsis
        Sends a image to the printer    
    .Description
        
    #>
    [CmdletBinding(DefaultParameterSetName='FilePath')]
    param(
    
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='FilePath')]
    [Alias('Fullname')]
    [string]
    $FilePath,

    [Switch]
    $Landscape,

    # The number of copies to make
    [Uint32]
    $CopyCount = 1,

    # If set, then the image will not be printed in color
    [Switch]
    $BlackAndWhite
    )

    begin {
    
    }
    process {
    
        $printDoc = New-Object Drawing.Printing.PrintDocument    
        $printDoc.DefaultPageSettings.Landscape = $Landscape
        
        if ($psCmdlet.ParameterSetName -eq 'FilePath') {
            $resolvedFile = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($FilePath)
            if (-not $resolvedFile) { return }

            $bmp =  try { 
                [Drawing.Bitmap]::FromFile("$resolvedFile")
            } catch {
            }

            if (-not $bmp) {
                $bmp = try {
                    Get-Thumbnail -FilePath $resolvedFile
                } catch {
                }
            }

            if (-not $bmp) { 
            return
            }

            $script:Bmp = $bmp


            
            $printDoc.PrinterSettings.Copies = $CopyCount
            $printDoc.DefaultPageSettings.Color = -not $BlackAndWhite
            $printDoc.add_PrintPage({
                    
                $e = $_
                
                
                
                
                $newWidth = $bmp.Width * 100 / $bmp.HorizontalResolution
                $newHeight = $bmp.height * 100 / $bmp.VerticalResolution
                if ($Landscape) {
                    $widthFactor = $newWidth / $e.PageSettings.PrintableArea.height
                    $HeightFactor = $newHeight / $e.PageSettings.PrintableArea.Width
                } else {
                    $widthFactor = $newWidth / $e.PageSettings.PrintableArea.Width
                    $HeightFactor = $newHeight / $e.PageSettings.PrintableArea.Height
                }
                $widthMargin = 0
                $heightMargin = 0
                if ($widthFactor -ge 1 -or $HeightFactor -ge 1) {
                    if ($widthFactor -gt $HeightFactor) {
                        $newWidth = $newWidth / $widthFactor 
                        $newHeight = $newHeight / $widthFactor 

                    } else {
                        $newWidth = $newWidth / $HeightFactor
                        $newHeight = $newHeight / $HeightFactor
                        

                    }               
                }
                    
                if ($Landscape) {
                    $heightMargin = (($e.PageSettings.PrintableArea.Height - $newHeight) / 2) / 2
                } else {
                    $widthMargin = (($e.PageSettings.PrintableArea.Width - $newWidth) / 2) / 2
                    
                }
                    
                    
                    


                    $h = $e.PageSettings.PrintableArea.Height
                    $m =  ($e.PageSettings.PrintableArea.Height - $h) / 2
                    $e.Graphics.DrawImage($bmp, 
                        ($e.PageSetting.HardMarginX + $widthMargin), 
                        ($e.PageSetting.HardMarginY + $heightMargin), 
                        $newWidth, 
                        $newHeight);
                                    

            })

            
            
            $bmp.Dispose()
            $printDoc.Print()
        }
    }
} 
