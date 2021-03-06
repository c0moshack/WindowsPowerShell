function Update-ScriptPalette
{
    param(
    [Parameter(ParameterSetName="Palette",Mandatory=$true,ValueFromPipeline=$true,Position=0)]
    [Hashtable]
    $Palette,    
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Attribute = "#FFADD8E6",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Command = "#FF0000FF",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]    
    $CommandArgument = "#FF8A2BE2",   
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $CommandParameter = "#FF000080",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Comment = "#FF006400",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $GroupEnd = "#FF000000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $GroupStart = "#FF000000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Keyword = "#FF00008B",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $LineContinuation = "#FF000000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $LoopLabel = "#FF00008B",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Member = "#FF000000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $NewLine = "#FF000000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Number = "#FF800080",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Operator = "#FFA9A9A9",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Position = "#FF000000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $StatementSeparator = "#FF000000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $String = "#FF8B0000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Type = "#FF008080",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Unknown = "#FF000000",
    [Parameter(ParameterSetName="Color", ValueFromPipelineByPropertyName=$true)]
    $Variable = "#FFFF4500"        
    )
    
    process {
        if ($psCmdlet.ParameterSetName -eq "Color") {
            $NewScriptPalette= @{}
            foreach ($parameterName in $myInvocation.MyCommand.Parameters.Keys) {
                $variable = Get-Variable -Name $parameterName -ErrorAction SilentlyContinue
                if ($variable -ne $null -and $variable.Value) {
                    if ($variable.Value -is [Collections.Generic.KeyValuePair[System.Management.Automation.PSTokenType,System.Windows.Media.Color]]) {
                        $psise.Options.TokenColors[$variable.Value.Key] = $variable.Value.Value
                    } elseif ($variable.Value -as [Windows.Media.Color]) {                        
                        $psise.Options.TokenColors[$parameterName] = $variable.Value -as [Windows.Media.Color]
                    }
                }
            }        
        } elseif ($psCmdlet.ParameterSetName -eq "Hashtable") {
            Update-ScriptPalette @Palette
        }
    }
}
                                                 
