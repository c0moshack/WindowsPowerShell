
$myModule = Get-PSCallStack | 
    Where-Object { $_.InvocationInfo.MyCommand.Module } | 
    Select-Object -First 1 -ExpandProperty InvocationInfo | 
    Select-Object -ExpandProperty MyCommand | 
    Select-Object -ExpandProperty Module

@{
    "Add-ForeachStatemnt" = {Add-ForeachStatement} | 
        Add-Member NoteProperty ShortcutKey "CONTROL + SHIFT + F" -PassThru
    "Add-IfStatement" = {Add-IfStatement} | 
        Add-Member NoteProperty ShortcutKey "CONTROL + SHIFT + I" -PassThru
    "Add-SwitchStatement" = {Add-SwitchStatement} | 
        Add-Member NoteProperty ShortcutKey "CONTROL + SHIFT + S" -PassThru

    "Add-InlineHelp" = & (Join-Path (Split-Path $myModule.Path) Menus\Add-InlineHelp.ps1)
    "Add-Parameter" = {
        Add-SparkplugScreen -Name "Add-Parameter" -Screen {
            New-Grid -Rows 1*, Auto -Columns 2 -ControlName Add-Parameter -Children {
                Get-Input  -Name ParameterToAdd -ColumnSpan 2 @{
                    "Name" = 'NewParameter'
                    "HelpMessage" = 'Every parameter needs a little help'
                    "ParameterSet" = 'NewParameterSet'
                    "FromPipeline" = [bool] |
                        Add-Member NoteProperty CueText 'Accept a object from the pipeline?' -PassThru  
                    "FromPipelineByPropertyName" = [bool] |
                        Add-Member NoteProperty CueText 'Accept a property from an object on the pipeline?' -PassThru
                    "FromRemainingArguments" = [bool] |
                        Add-Member NoteProperty CueText 'Accept a value from remaining arguments?' -PassThru
                    "Position" = [int] | 
                        Add-Member NoteProperty CueText 'The parameter position' -PassThru
                    "Aliases" = [string[]]                    
                } -HideOkCancel -Order 'Name', 'Aliases', 'HelpMessage','ParameterSet','Position','FromPipeline',
                    'FromPipelineByPropertyName',
                    'FromRemainingArguments'
                    
                New-Button -Width 120 -Row 1 -Column 1 -IsDefault "Add-Parameter" -On_Click {
                    Set-UIValue -Ui $parent
                    $parameter = Get-UIValue -Ui $parameterToAdd
                    Invoke-Sparkplug -Command "Add-Parameter" -Parameter $parameter # -InBackground
                }
            }
        } -Update {
            Get-CurrentDocumentEditor 
        } -UpdateFrequency "0:0:1"        
    } |
            Add-Member NoteProperty ShortcutKey "ALT + P" -PassThru 
		"Add-WPKFunction" = {
			Write-WPKFunction
		} | Add-Member NoteProperty ShortcutKey "ALT + W" -PassThru
        "Add-SessionLockdown" = {
            Write-SessionLockdown
        } | Add-Member NoteProperty ShortcutKey "CONTROL + ALT + L" -PassThru
        "Add-RemoteDataCollector" = {
                Select-CurrentText -NotInOutput -NotInCommandPane | 
                Where-Object { 
                    $_ 
                } |
                ForEach-Object { 
                    $sb = [ScriptBlock]::Create($_)
                    if ($sb) { Invoke-Expression "$sb -AsJob" } else {
                        Write-Warning "You need to have a small script selected to write a remote data collector"
                    }
                } 
                
                if ($sb) {
                    Write-RemoteDataCollector -ScriptBlock $sb             
                }
        } | Add-Member NoteProperty ShortcutKey "CONTROL + ALT + R" -PassThru
} 
