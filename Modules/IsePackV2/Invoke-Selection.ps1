function Invoke-Selection {
    <#
    .Synopsis
        Invokes the current line in the scripting editor
    .Description
        Invokes the current line in the scripting editor
    .Example
        Invoke-Selection
    #>
    param()
	if ($host.Name -eq "Windows PowerShell ISE Host") {
	    # Um, already a feature here
	} elseif ($Host.Name -eq "PowerGUIScriptEditorHost") {
		$document = $pgse.CurrentDocumentWindow.Document
	    Invoke-Expression $document.SelectedText | 
			Out-Host
	}	
}
