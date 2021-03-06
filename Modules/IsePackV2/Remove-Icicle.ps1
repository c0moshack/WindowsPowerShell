function Remove-Icicle
{
    <#
    .Synopsis
        Removes an icicle
    .Description
        Removes an icicle.  Icicles are little apps for the PowerShell ISE.
    .Example
        Get-Icicle | Remove-Icicle
        # Hides all icicles
    .Link
        Show-Icicle
    .Link
        Get-Icicle
    .Link
        Add-Icicle
    .Link
        Remove-Icicle
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param(
    # The Icicle that will be hidden.
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateScript({
        $_.GetType().Fullname -eq 'Microsoft.PowerShell.Host.ISE.ISEAddOnTool' -or
        $_.GetType().Fullname -eq 'Windows.Control'
    })]
    [PSObject]
    $Icicle
    )
    
    process {
        if ($psCmdlet.ShouldProcess($Icicle.Name)) {
            $Icicle.IsVisible = $false

            $namesToRemove = 'RegularUpdate', 'FirstUpdate', 'IseFileschange', 'IseFileCollectionChange', 'IseVerticalAddOnsChanged', 'IseHorizontalAddOnsChanged', 'IseScriptView', 'SyncIse'

            foreach ($ntr in $namesToRemove) {
                Get-EventSubscriber -SourceIdentifier "$($icicle.Name)$ntr" -ErrorAction SilentlyContinue | 
                    Unregister-Event
            }
            if ($psise.CurrentPowerShellTab.HorizontalAddOnTools -contains $Icicle) {
                $null = $psise.CurrentPowerShellTab.HorizontalAddOnTools.Remove($Icicle)
            } elseif ($psise.CurrentPowerShellTab.VerticalAddOnTools -contains $Icicle) {
                $null = $psise.CurrentPowerShellTab.VerticalAddOnTools.Remove($Icicle)
            }
        }
        
    }
}
