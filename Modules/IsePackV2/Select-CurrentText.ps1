function Select-CurrentText {
    <#
    .Synopsis
        Returns the currently selected text
    .Description
        Returns the text that is currently selected from within the editor, 
        the output, and the command pane
    .Example
        Select-CurrentText
    #>
    param(
    # If set, ignores selected text in the current file
    [Switch]$NotInEditor,
    # If set, ignores selected text in the output
    [Switch]$NotInOutput,
    # If set, ignosres selected text in the command pane
    [Switch]$NotInCommandPane
    )

    process {
	    $items = if ($Host.Name -eq "Windows PowerShell ISE Host") {
	        if (-not $NotInEditor) { $psise.CurrentFile.Editor.SelectedText }
	        if (-not $NotInOutput) { $psise.CurrentPowerShellTab.Output.SelectedText }
	        if (-not $NotInCommandPane) { 
	            $psise.CurrentPowerShellTab.CommandPane.SelectedText
	        }
	    } elseif ($Host.Name -eq "PowerGUIScriptEditorHost") {
		    [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance.CurrentDocumentWindow.Document.SelectedText
	    }

        $items -ne $null
	}
}