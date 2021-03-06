param([Hashtable]$options) 


if ($options.ForPublication) {
    return
}

if ($options.Clean) {
    Remove-Item "$home\Documents\WindowsPowerShell\Modules\EZOut" -Recurse
    Remove-Item "$home\Documents\WindowsPowerShell\Modules\Pipeworks" -Recurse
}

$modulePaths = $env:PSModulePath -split ';'

$showUIFound = $false
$ezOutFound = $false
$scripCopFound = $false
$pipeworksFound = $false

$modulesToFind = @{
    EzOut = $false
    ShowUI = $false
    Pipeworks = $false
}

$moduleDownloadUrl = @{
    EzOut = 'http://ezout.start-automating.com/?-GetManifest'
    Pipeworks = 'http://powershellpipeworks.com/Module.ashx?-GetManifest' 
}


$count = 0
foreach ($moduleName in @($modulestoFind.Keys)) {
    $count++
    $perc = $count * 100 / $modulesToFind.Count
    if (Get-Module $moduleName) { continue } 
    Write-Progress "Starting IsePack" "$moduleName" -PercentComplete $perc
    foreach ($mp in $modulePaths) {    
        if (Test-Path "$mp\$moduleName") {
            Import-Module "$mp\$moduleName\$moduleName" -Global 
            $modulesToFind[$moduleName]  = $true
        } elseif ($mp -eq "$home\Documents\WindowsPowershell\Modules") {
            # Go ahead and download them
            Write-Progress "Downloading $moduleName" "From $($moduleDownloadUrl[$moduleName])" -PercentComplete $perc
            $wc = New-Object Net.WebClient
            $tmpZipFile = [IO.Path]::GetTempFileName() + ".zip"
            $url = [uri]$moduleDownloadUrl[$moduleName]            
            $manifest = $wc.DownloadString($url)
            $xmlManifest = [xml]$manifest
            $modulezipUrl = ($xmlManifest.ModuleManifest.Url.Replace("Module.ashx", "").TrimEnd("/")) + 
                "/"+ $xmlManifest.ModuleManifest.Name + 
                "." + $xmlManifest.moduleManifest.Version + ".zip"
            $moduleZipUrl = $moduleZipUrl -ireplace 'Module\.ashx\/', ''
            $wc.DownloadFile($moduleZipUrl, $tmpZipFile)
            Write-Progress "Extracting $moduleName" " " -PercentComplete $perc
            
            $shell = New-Object -ComObject Shell.Application
            $zipContent = $shell.Namespace($tmpZipFile)
            $homeModules = $shell.Namespace("$home\Documents\WindowsPowershell\Modules\")
            $null = $homeModules.CopyHere($zipContent.Items(),(16 -bor 512))
            $tries = 0
            do {
                Start-sleep -seconds 1
                $tries++
                if ($tries -gt 10) {
                    break
                }
            } while (-not (Test-Path "$mp\$moduleName")) 
            
            Import-Module "$mp\$moduleName\$moduleName" -Global 
            $modulesToFind[$moduleName]  = $true
            
        }
    }
}


if ($psVersionTable.PSVersion -eq '2.0') {
    $global:PromptStatus = @({
        $(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + 'PS ' + $(Get-Location) + $(if ($nestedpromptlevel -ge 1) { '>>' }) 
    })
    $defaultPromptHash = "HEYStcKFSSj9jrfqnb9f+A=="
} elseif ($psVersionTable.PSVersion -eq '3.0') {
    $global:PromptStatus = @({
        "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
    })
    $defaultPromptHash = ""
}
$md5 = [Security.Cryptography.MD5]::Create()
$thePrompt = try { 
    [Text.Encoding]::Unicode.GetBytes((Get-Command -ErrorAction SilentlyContinue prompt | Select-Object -ExpandProperty Definition))
} catch {

}
$thePromptHash = [Convert]::ToBase64String($md5.ComputeHash($thePrompt))

if ($thePRomptHash -and $thePromptHash -eq $defaultPromptHash) #using the default prompt?
{    
    #recommend our own    
<#    function prompt(){    
        # Reset color, for many things can change this
        $Host.UI.RawUI.ForegroundColor = $global:DefaultPromptColor
    
        $promptText = 
            $global:PromptStatus, '>' | 
                ForEach-Object {
                    if ($_ -is [ScriptBlock]) {
                        . $_
                    } else {
                        $_
                    }
                }
                
        
        return "$($promptText -join ' ')"    
    }#>
} else {
    Write-Verbose "Custom Prompt Already Defined, Not Defining One"
} 
