function Show-Icicle
{
    <#
    .Synopsis
        Shows an icicle
    .Description
        Shows an icicle.  Icicles are little apps for the PowerShell ISE.
    .Example
        Get-Icicle | Shows-Icicle
        # Shows all icicles
    .Link
        Hide-Icicle
    .Link
        Get-Icicle
    .Link
        Add-Icicle
    .Link
        Remove-Icicle
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]    
    [OutputType([Nullable])]
    param(
    # The Icicle that will be hidden.    
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]        
    [ValidateScript({$_ -as 'Microsoft.PowerShell.Host.ISE.ISEAddOnTool'})]
    $Icicle,

    # If set, will output the icicle
    [Switch]
    $PassThru
    )
    
    process {
        
        if ($psCmdlet.ShouldProcess($icicle.Name)) { 
            $isHorizontal = $psise.CurrentPowerShellTab.HorizontalAddOnTools | Where-Object {
                $_.Name -eq $Icicle.Name
            }

            
            
            if ($isHorizontal -and ($psise.CurrentVisibleHorizontalTool.Name -ne $Icicle.Name)) {
                $c= 0
                foreach ($addontool in $psise.CurrentPowerShellTab.HorizontalAddOnTools) {
                    if ($addOnTool.Name -eq $Icicle.Name) {
                        break
                    }
                    $c++
                }
                if ($c -ne $psise.CurrentPowerShellTab.HorizontalAddOnTools.Count) {
                    $psise.CurrentPowerShellTab.HorizontalAddOnTools.RemoveAt($c)
                    $psise.CurrentPowerShellTab.HorizontalAddOnTools.Add($Icicle)
                }
            } elseif (($psise.CurrentVisibleVerticalTool.Name -ne $Icicle.Name)) {
                $c= 0
                foreach ($addontool in $psise.CurrentPowerShellTab.VerticalAddOnTools) {
                    if ($addOnTool.Name -eq $Icicle.Name) {
                        break
                    }
                    $c++
                }
                if ($c -ne $psise.CurrentPowerShellTab.VerticalAddOnTools.Count) {
                    $psise.CurrentPowerShellTab.VerticalAddOnTools.RemoveAt($c)
                    $psise.CurrentPowerShellTab.VerticalAddOnTools.Add($Icicle)
                } 
            }
            

            $Icicle.IsVisible = $true
            
            if ($PassThru) {
                $Icicle
            }
        }
    }
}

