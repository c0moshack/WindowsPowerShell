$rootDrive = "$env:USERPROFILE\Documents\Git\PowerShell"

#Restore-MDTPersistentDrive -ErrorAction SilentlyContinue | Out-Null
New-PSDrive -Name Scripts -PSProvider FileSystem -Root $rootDrive -ErrorAction SilentlyContinue

$ScriptsRoot = ";$rootDrive"
if(($env:Path -split ';') -notcontains $ScriptsRoot) {
    $env:Path += $ScriptsRoot
}

Set-Location Scripts:

Get-ChildItem Scripts:\Programming\GitHub\PowerShell\LoadedScripts -Recurse | %{ Unblock-File $_.FullName }
# Load all scripts
Get-ChildItem (Join-Path ('Scripts:') \LoadedScripts\) | Where `
    { $_.Name -notlike '__*' -and $_.Name -like '*.ps1'} | ForEach `
    { . $_.FullName }


If (Test-IsAdmin -eq True) {
	$Host.UI.RawUI.BackgroundColor = "darkred"
	$Host.UI.RawUI.ForegroundColor = "white"
	cls
}

Function Import-CustomLibrary {
	Import-Module "D:\Documents\Visual Studio 2010\Projects\PowerShellModules\PowerShellModules\bin\Debug\PowerShellModules.dll"
}

Function Get-SCCM {
	Import-Module 'C:\Program Files (x86)\SCCM\AdminConsole\bin\ConfigurationManager.psd1'
	Set-Location NG4:
}

Function Get-CustomModules {
	Import-Module "$rootDriveUNC\WinPE_Builder_x86.psm1" -ErrorAction SilentlyContinue
	Import-Module DISM -ErrorAction SilentlyContinue
	Import-Module ActiveDirectory -ErrorAction SilentlyContinue
	Import-Module TrustedPlatformModule -ErrorAction SilentlyContinue
	Import-Module Storage -ErrorAction SilentlyContinue
	Import-Module NetAdapter -ErrorAction SilentlyContinue
	Import-Module BitLocker -ErrorAction SilentlyContinue
}
Function New-Function {
	$newfunction = @"
Function <NAME> {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: $($psise.CurrentFile.DisplayName) 
	    	AUTHOR: $env:username 
	    	LASTEDIT: $(Get-Date) 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[CmdletBinding()]
    [OutputType([psobject})}
    
	Param(
		[Parameter(
		Mandatory=`$true,
		Position=0,
		ValueFromPipeline=`$true,
		ValueFromPipelineByPropertyName=`$true)]
		[string]$<VARIABLE>
	)
    begin {}
	`r`n
    process {}
    `r`n
    end {}
    `r`n
}
"@
	Add-HeaderToScript
	#$PGSE.CurrentDocumentWindow.Document.Insert($newfunction, 10, 1)
     # Uncomment for PowerShell ISE Environment
    $psise.CurrentFile.Editor.InsertText($newfunction) 
}

Function Add-Parameter
{ 
 $paramText = @" 
        [Parameter(
		Mandatory=`$$(IF(($p1 = Read-Host "Is this variable mandatory? Enter true or false") -eq ''){"false"}else{$p1}))]
		[$(IF(($p2 = Read-Host "Type: string,array,int") -eq ''){"string"}else{$p2})]`$$(IF(($p3 = Read-Host "Enter variable name:") -eq ''){"<VARiABLE>"}else{$p3}),
`r`n
"@ 
 #$line = $PGSE.CurrentDocumentWindow.Document.get_CaretLine()
 #$char = $PGSE.CurrentDocumentWindow.Document.get_CaretCharacter()
 #$PGSE.CurrentDocumentWindow.Document.Insert($helpText, $line, $char)
 # Uncomment for PowerShell ISE Environment
 $psise.CurrentFile.Editor.InsertText($paramText) 
} #end function add-help

Function Add-HeaderToScript 
{ 
  <# 
   .Synopsis 
    This function adds header information to a script  
   .Example 
    Add-HeaderToScript 
    Adds header comments to script  
   .Example  
    AH 
    Uses alias to add header comments to script 
   .Notes 
    NAME: Add-HeaderToScript 
    AUTHOR: Ed Wilson, msft 
    LASTEDIT: 09/07/2010 19:37:28 
    KEYWORDS: Scripting Techniques, Windows PowerShell ISE 
    HSG: WES-09-12-10 
   .Link 
    Http://www.ScriptingGuys.com 
 #Requires -Version 2.0 
 #> 
 $header = @" 
# ----------------------------------------------------------------------------- 
# Script: $($psise.CurrentFile.DisplayName)
# Author: Paul Brown
# Date: $(Get-Date) 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------
`r`n 
"@ 
 #$PGSE.CurrentDocumentWindow.Document.Insert($header, 1, 1)
 # Uncomment for PowerShell ISE Environment
 $psise.CurrentFile.Editor.SetCaretPosition(1,1)
 $psise.CurrentFile.Editor.InsertText($header) 
} #end function add-headertoscript

Function Add-Help 
{ 
 $helpText = @" 
<# 
   `t.Synopsis 
    `tThis does that  
   `t.Example 
    `tExample- 
   `t.Parameter  
    `tThe parameter 
   `t.Notes 
    `tNAME: $($psise.CurrentFile.DisplayName) 
    `tAUTHOR: $env:username 
    `tLASTEDIT: $(Get-Date) 
    `tKEYWORDS: 
   `t.Link 
    `thttps://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
`t#Requires -Version 2.0 
`t#> 
"@ 
 #$line = $PGSE.CurrentDocumentWindow.Document.get_CaretLine()
 #$char = $PGSE.CurrentDocumentWindow.Document.get_CaretCharacter()
 #$PGSE.CurrentDocumentWindow.Document.Insert($helpText, $line, $char)
 # Uncomment for PowerShell ISE Environment
 $psise.CurrentFile.Editor.InsertText($helpText) 
} #end function add-help

Function Add-CommentBlock {
$commentblock = @"
###############################################################################
#  
###############################################################################
"@

 #$line = $PGSE.CurrentDocumentWindow.Document.get_CaretLine()
 #$char = $PGSE.CurrentDocumentWindow.Document.get_CaretCharacter()
 #$PGSE.CurrentDocumentWindow.Document.Insert($commentblock, $line, $char)
 # Uncomment for PowerShell ISE Environment
 $psise.CurrentFile.Editor.InsertText($helpText) 
}

Function Speak-Text {
	Param(
		[Parameter(Mandatory=$true)]
		[String]$Text
	)
	
    $Voice = new-object -com "SAPI.SpVoice" -strict
    $Voice.Rate = 0                # Valid Range: -10 to 10, slowest to fastest, 0 default.
    $Voice.Volume = 100
	$Voice.Voice = $($Voice.GetVoices())[1]
	$Voice.Speak($Text) | out-null  # Piped to null to suppress text output.
}

function Get-ProgID {                       
    #.Synopsis            
    #   Gets all of the ProgIDs registered on a system            
    #.Description            
    #   Gets all ProgIDs registered on the system.  The ProgIDs returned can be used with New-Object -comObject            
    #.Example            
    #   Get-ProgID            
    #.Example            
    #   Get-ProgID | Where-Object { $_.ProgID -like "*Image*" }             
    param()            
    $paths = @("REGISTRY::HKEY_CLASSES_ROOT\CLSID")            
    if ($env:Processor_Architecture -eq "amd64") {            
        $paths+="REGISTRY::HKEY_CLASSES_ROOT\Wow6432Node\CLSID"            
    }             
    Get-ChildItem $paths -include VersionIndependentPROGID -recurse |            
    Select-Object @{            
        Name='ProgID'            
        Expression={$_.GetValue("")}                    
    }, @{            
        Name='32Bit'            
        Expression={            
            if ($env:Processor_Architecture -eq "amd64") {            
                $_.PSPath.Contains("Wow6432Node")                
            } else {            
                $true            
            }                        
        }            
    }            
}

Function Set-SpeakerVolume { 
	Param (
		[switch]$min,
		[switch]$max
	)

 	$wshShell = new-object -com wscript.shell
	If ($min)
		{1..50 | % {$wshShell.SendKeys([char]174)}}
	ElseIf ($max)
		{1..50 | % {$wshShell.SendKeys([char]175)} }
	Else
		{$wshShell.SendKeys([char]173)} 
}
