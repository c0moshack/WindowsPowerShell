function New-ScriptPalette
{
    param(
    $Attribute = "#FFADD8E6",
    $Command = "#FF0000FF",
    $CommandArgument = "#FF8A2BE2",   
    $CommandParameter = "#FF000080",
    $Comment = "#FF006400",
    $GroupEnd = "#FF000000",
    $GroupStart = "#FF000000",
    $Keyword = "#FF00008B",
    $LineContinuation = "#FF000000",
    $LoopLabel = "#FF00008B",
    $Member = "#FF000000",
    $NewLine = "#FF000000",
    $Number = "#FF800080",
    $Operator = "#FFA9A9A9",
    $Position = "#FF000000",
    $StatementSeparator = "#FF000000",
    $String = "#FF8B0000",
    $Type = "#FF008080",
    $Unknown = "#FF000000",
    $Variable = "#FFFF4500"        
    )
    
    process {
        $NewScriptPalette= @{}
        foreach ($parameterName in $myInvocation.MyCommand.Parameters.Keys) {
            $var = Get-Variable -Name $parameterName -ErrorAction SilentlyContinue
            if ($var -ne $null -and $var.Value) {
                if ($var.Value -is [Collections.Generic.KeyValuePair[System.Management.Automation.PSTokenType,System.Windows.Media.Color]]) {
                    $NewScriptPalette[$parameterName] = $var.Value.Value
                } elseif ($var.Value -as [Windows.Media.Color]) {
                    $NewScriptPalette[$parameterName] = $var.Value -as [Windows.Media.Color]
                }
            }
        }
        $NewScriptPalette    
    }
}
                                                 
