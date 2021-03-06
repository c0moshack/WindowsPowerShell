function Write-CommandSplatter
{
    [CmdletBinding(DefaultParameterSetName="Name")]
    param(
    [Parameter(ParameterSetName='Command',Mandatory=$true,ValueFromPipeline=$true)]
    [Management.Automation.CommandInfo]
    $Command,
    
    [Parameter(ParameterSetName='Name',Position=0,Mandatory=$true)]
    [String]
    $Name
    )
    
    process {        
        if ($psCmdlet.ParameterSetName -eq "Command") {
            $Name = $Command.Name   
            $NameWithoutDashes = $Name.Replace("-","")
        } else {
            $NameWithoutDashes = $Name.Replace("-","")
        }
        
@"
    `$${NameWithoutDashes}Parameters = @{}
    foreach (`$parameterName in ((Get-Command $Name | Select-Object -First 1)).Parameters.Keys) {
        `$variable = Get-Variable -Name `$parameterName -ErrorAction SilentlyContinue
        if (`$variable -ne `$null -and `$variable.Value) {
            `$null = `$${NameWithoutDashes}Parameters.Add(`$parameterName, `$variable.Value)
        }
    }
    $Name @${NameWithoutDashes}Parameters
"@
    }
}