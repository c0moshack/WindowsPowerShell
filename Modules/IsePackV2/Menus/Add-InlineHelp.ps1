{
	New-UniformGrid -MinWidth 250 -Columns 2 {
	"Synopsis" 
    New-TextBox -Name Synopsis
	"Description"
	New-TextBox -Name Description
	"Examples"
    Edit-StringList -Name Examples
	" "
    New-Button "OK" -IsDefault -On_Click {
	   $parent | Set-UIValue -passThru 
	   $parent.Tag = New-Object PSObject $parent.Tag
	   $parent
    }
} -show | ForEach-Object {
$strStart  =@"
<#
.Synopsis
    $($_.Synopsis)
.Description
    $($_.Description)    
"@    

foreach ($ex in $_.Examples) {
    if (-not $ex) { continue} 
    $strStart += @"

.Example
    $ex

"@        
}

$strStart+@"
#>
"@
    }
        $strStart  
} |
	Add-Member NoteProperty ShortcutKey "Alt + H" -PassThru