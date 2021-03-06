function Stop-Demo {
    <#
    .Synopsis
        Stops any running demos
    .Description
        Stops any demos and closes the demo icicle
    .Example
        Stop-Demo
    #>
    param()
    Get-Icicle -IcicleName Demo | Remove-Icicle -Confirm:$false
} 
