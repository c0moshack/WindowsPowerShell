function Clear-Icicle
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
    )

    process {
        Get-Icicle |
            Remove-Icicle @PSBoundParameters
    }
} 
