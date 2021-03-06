function Invoke-Line {
    <#
    .Synopsis
        Invokes the current line in the ISE
    .Description
        Invokes the curreent line in the Windows PowerShell Integrated Scripting Environment
    .Example
        Invoke-Line
    #>
    param()
    $document = Get-CurrentDocument -Editor
	if ($host.Name -eq "Windows PowerShell ISE Host") {

		$endOfLine = $document.GetLineLength($document.CaretLine) + 1
	} elseif ($Host.Name -eq "PowerGUIScriptEditorHost") {
		$endOfLine = $document.Lines[$document.CaretLine].Length
	}
	
    Invoke-Expression $document.SelectedText | 
		Out-Host
}
