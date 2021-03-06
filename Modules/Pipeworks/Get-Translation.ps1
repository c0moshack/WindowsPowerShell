function Get-Translation
{
    <#
    .Synopsis
        Translates text
    .Description
        Translates text, using Bing Translator
    .Example
        Get-Translation "Start-Automating"
    .Example
        Get-Translation "Hello World" -To "German"

    .Notes
        Using Bing requires you to sign up for the Azure Data Market.  
        
        It is recommended that you use the default secure setting to store your data market key, AzureDataMarketAccountKey

        Using Google requires you sign up for the custom search api, and providing a custom search id
    #>
    [CmdletBinding(DefaultParameterSetName='Bing')]
    param(
    # The text to be translated
    [Parameter(Mandatory=$true,
        Position=0,        
        ValueFromPipelineByPropertyName=$true,
        ValueFromPipeline=$true)]
    [string]
    $Text,


    # The language to translate to
    [Parameter(        
        ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        $allCultures = [Globalization.CultureInfo]::GetCultures("AllCultures")
        $lang = $_

        $matchingCulture = $allCultures | Where-Object { $_.DisplayName -like $lang -or $_.Name -like $lang } 
        if (-not $matchingCulture) {
            throw "Language not found"
        }
        return $true
    })]
    [string]
    $To= "de",

    # The language text will be translated from
    [Parameter(        
        ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        $allCultures = [Globalization.CultureInfo]::GetCultures("AllCultures")
        $lang = $_

        $matchingCulture = $allCultures | Where-Object { $_.DisplayName -like "$lang*" -or $_.Name -like "$lang*" } 
        if (-not $matchingCulture) {
            throw "Language not found"
        }
        return $true
    })]
    [string]
    $From= "",

    
    # The Azure Data Market Key Or Setting
    [Parameter(ParameterSetName='Bing')]
    [string]
    $AzureDataMarketSetting = "AzureDataMarketAccountKey",


    # The Azure Data Market Key.  If this is not provided, then the AzureDataMarketSetting, or it's default value, will be used
    [Parameter(ParameterSetName='Bing')]
    [string]
    $AzureDataMarketAccountKey       

    )

    begin {
        

        Set-StrictMode -Off
        Add-Type -AssemblyName System.Web
        if (-not ($script:CachedTranslation)) { 
            $script:CachedTranslation = @{}            
        }
    }

    process {
        if ($AsJob) {
            $myDefinition = [ScriptBLock]::Create("function Get-Translation {
$(Get-Command Get-Translation | Select-Object -ExpandProperty Definition)
}
")
            $null = $psBoundParameters.Remove('AsJob')            
            $myJob= [ScriptBLock]::Create("" + {
                param([Hashtable]$parameter) 
                
            } + $myDefinition + {
                
                Search-Engine @parameter
            }) 
            
            Start-Job -ScriptBlock $myJob -ArgumentList $psBoundParameters 
            return
        }

        
        #region Bing
        $allCultures = [Globalization.CultureInfo]::GetCultures("AllCultures")
        $realTo = $allCultures | 
            Where-Object { $_.DisplayName -like "$to*" -or $_.Name -like "$to*" } |
            Select-Object -First 1  |
            ForEach-Object { 
                if ($_.Name -like "zh-*") {
                    $_.Name
                } else {
                    $_.Name.Substring(0, 2)
                }

            } 

        $realFrom = if ($From) {
            $allCultures | 
                Where-Object { $_.DisplayName -like "$from*" -or $_.Name -like "$from*" } |
                Select-Object -First 1 |
                ForEach-Object {
                    if ($_.Name -like "zh-*") {
                        $_.Name
                    } else {
                        $_.Name.Substring(0, 2)
                    }
                }
    
        } else {
            $null
        }
        

        $admk = if ($AzureDataMarketAccountKey) {
            $AzureDataMarketAccountKey
        } else {
            if ($script:CachedAzureDataMarketAccountKey) {
                $script:CachedAzureDataMarketAccountKey
            } else {
                Get-SecureSetting -Name $AzureDataMarketSetting -ValueOnly
            }
        }

        $script:CachedAzureDataMarketAccountKey = $admk

        $cred = New-Object Management.Automation.PSCredential $admk, (ConvertTo-SecureString -AsPlainText -Force "$admk")
            

        $result = 
            if ($script:CachedTranslation["${Text}_${RealTo}_${RealFrom}"] -and (-not $Force)) {
                $script:CachedTranslation["${Text}_${RealTo}_${RealFrom}"]
            } else {                
                    

                $script:CachedTranslation["${Text}_${RealTo}_${RealFrom}"] = Get-Web -Url "https://api.datamarket.azure.com/Bing/MicrosoftTranslator/v1/Translate?Text=%27$([Web.HttpUtility]::UrlEncode("$Text").Replace('+', '%20'))%27&To=%27$($RealTo)%27$(if ($Realfrom) { "&From=%27$($Realfrom)%27"})" -WebCredential $cred -UseWebRequest 
                $script:CachedTranslation["${Text}_${RealTo}_${RealFrom}"]
            }
             

            if ($result) {
                $rx = [xml]$result
                $feed=  $rx.feed
                $entries = foreach($e in $feed.entry) { $e } 

                foreach ($e in $entries) {
                    

                    
                    $translation = New-Object PSObject -Property @{
                        Original = $text;
                        Translation= $e.content.properties.Text.'#text';
                        Language = ([Globalization.CultureInfo]$RealTo).DisplayName                        
                        From = if ($From) {
                            ([Globalization.CultureInfo]$RealFrom).DisplayName                        
                        } else {
                            "Auto-Detect"
                        }
                    } 

                    $translation.pstypenames.clear()                    
                    $translation
                     
                }

            }
            

            #endregion Bing
        
    }
}
 
