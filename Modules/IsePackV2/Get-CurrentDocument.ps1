function Get-CurrentDocument
{
    [CmdletBinding(DefaultParameterSetName='DocumentObject')]
    param(
    [Parameter(Mandatory=$true,ParameterSetName='GetEditor')]
    [switch]
    $Editor,
    
    [Parameter(Mandatory=$true,ParameterSetName='GetText')]
    [switch]
    $Text,
    
    [Parameter(Mandatory=$true,ParameterSetName='GetPath')]
    [switch]
    $Path
    )
    
    process {
    
        if ($Host.Name -eq 'PowerGUIScriptEditorHost') {
            if ($editor) {
                [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance.CurrentDocumentWindow.Document
            } elseif ($text) {
                [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance.CurrentDocumentWindow.Document.Text
            } elseif ($path) {
                [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance.CurrentDocumentWindow.Document.Path
            } {
                [Quest.PowerGUI.SDK.ScriptEditorFactory]::CurrentInstance.CurrentDocumentWindow
            }
			
		} elseif ($Host.Name -eq 'Windows PowerShell ISE Host') {
            $refresh  =$psise.CurrentFile
            if ($editor) {
                $psise.CurrentFile
            } elseif ($text) {
                $psise.CurrentFile.Editor.Text
            } elseif ($path) {
                $psise.CurrentFile.Editor.FullPath
            }
			
		}	
    }
}