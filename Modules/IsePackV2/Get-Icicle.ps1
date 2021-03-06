function Get-Icicle
{
    <#
    .Synopsis
        Gets icicles
    .Description
    
    .Example
    #>
    param(
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('Name')]
    [string]$IcicleName,

    [Switch]$Available
    )

    process {
        if (-not ($Available -or $Loaded)) {
            if ($psBoundParameters.IcicleName) {
                $psISE.CurrentPowerShellTab.HorizontalAddOnTools + $psISE.CurrentPowerShellTab.VerticalAddOnTools |
                    Where-Object { $_.Control.InvokeScript -and ($_.Name -like $IcicleName)} |
                    Sort-Object Name

            } else {
                $psISE.CurrentPowerShellTab.HorizontalAddOnTools + $psISE.CurrentPowerShellTab.VerticalAddOnTools |
                    Where-Object { $_.Control.InvokeScript } |
                    Sort-Object Name

            }
        } elseif ($Available) {
            if (-not $script:AvailableModules) {
                $script:availableModules= Get-Module -ListAvailable 
            }
            $script:availableModules | 
                Split-Path |
                Get-ChildItem -Filter Icicles | 
                Get-ChildItem -Filter *.icicle.ps1
        }

        
    }


}
 
