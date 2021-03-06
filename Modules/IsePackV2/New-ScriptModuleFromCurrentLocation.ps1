function New-ScriptModuleFromCurrentFile {
    <#
    .Synopsis
        Creates a new basic script module (.PSM1) from location of the current file
    .Description
        Creates a new basic script module (.PSM1) from location of the current file
        All .ps1 files in the same directory as the current file will be included in 
        the module.
        
        Does not overwrite existing modules at this location.

    .Example
        New-ScriptModuleFromCurrentFile
    #>
    param()
	
	process {
		$currentScriptPath = Get-CurrentScriptPath
        if (-not $currentScriptPath)  { return }
	    $location = Split-Path $currentScriptPath 
	    $locationName = Split-Path $location -Leaf
	    $text = ""
	    Get-ChildItem $location -Filter *.ps1 | ForEach-Object {
	        $text += ('. $psScriptRoot\' + $_.Name + [Environment]::NewLine)
	    }
        Get-Item $pwd
	    $modulePath = Join-Path $location "$locationName.psm1"
	    if (Test-Path -ErrorAction SilentlyContinue $modulePath) {
            Write-Warning "Module already exists, so won't overwrite file"
            $text                        
	        return
	    }
	    [IO.File]::WriteAllText($modulePath, $text)
		Edit-Script -File $modulePath
	}
}