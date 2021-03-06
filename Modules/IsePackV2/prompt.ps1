$global:DefaultPromptColor = $Host.UI.RawUI.ForegroundColor


if ($PSVersionTable.PSVersion -ge '3.0') {
    $defaultPromptHash = "21Ny9HAq2ZLp8S/qI5RdcQ=="
$global:DefaultPromptStatus = @({
"PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1))" 
# .Link
# http://go.microsoft.com/fwlink/?LinkID=225750
# .ExternalHelp System.Management.Automation.dll-help.xml
})

$global:PromptStatus = $global:DefaultPromptStatus 


} elseif ($PSVersionTable.PSVersion -ge '2.0') {
    $defaultPromptHash = "HEYStcKFSSj9jrfqnb9f+A=="
$global:DefaultPromptStatus = @({
    $(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + 'PS ' + $(Get-Location) + $(if ($nestedpromptlevel -ge 1) { '>>' }) 
}, '>')

$global:PromptStatus = $global:DefaultPromptStatus 

}

$md5 = [Security.Cryptography.MD5]::Create()
$thePrompt = try { 
    [Text.Encoding]::Unicode.GetBytes((Get-Command -ErrorAction SilentlyContinue prompt | Select-Object -ExpandProperty Definition))

} catch {
}

$thePRomptHash = $md5.ComputeHash($thePrompt)


if ($thePRomptHash -and $thePromptHash -eq $defaultPromptHash) #using the default prompt?
{    
    #recommend our own    
    function prompt(){    
        # Reset color, for many things can change this
        $Host.UI.RawUI.ForegroundColor = $global:DefaultPromptColor
    
        $promptText = 
            $global:PromptStatus | 
                ForEach-Object {
                    if ($_ -is [ScriptBlock]) {
                        & $_
                    } else {
                        $_
                    }
                }
                
        
        return "$($promptText -join '')"    
    }
} else {
    Write-Verbose "Custom Prompt Already Defined, Not Defining One"
} 
