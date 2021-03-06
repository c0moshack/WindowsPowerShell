function Update-Icicle
{
    <#
    .Synopsis
        
    .Description

    #>
    param(
    [Parameter(Mandatory=$true,Position=0,ParameterSetName='UpdateIcicleNow')]
    [string]
    $Name,

    # The script block used to update the icicle
    [Parameter(Mandatory=$true,Position=1,ParameterSetName='UpdateIcicleWithScript')]
    [ScriptBlock]
    $ScriptBlock,

    [Parameter(ValueFromPipeline=$true,ParameterSetName='UpdateIcicleWithScript')]
    [PSObject]
    $Data
    )


    


    if ($PSCmdlet.ParameterSetName -eq 'UpdateIcicleNow') {
        $sub = Get-EventSubscriber -SourceIdentifier "${name}FirstUpdate" -ErrorAction SilentlyContinue
        if ($sub) {
            $sub.SourceObject.Stop()
            $sub.SourceObject.Start()
        }
    } elseif ($PSCmdlet.ParameterSetName -eq 'UpdateIcicleWithScript') {
        Get-Icicle -IcicleName $Name | 
            ForEach-Object {
                $_.Control.InvokeScript($ScriptBlock,$Data)
            }
    }
} 
