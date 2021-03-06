function Invoke-WebCommand
{
    <#
    .Synopsis
        Invokes the commands within a web service
    .Description
        Invokes the commands within a Pipeworks web service
    .Example
        # Invoke-WebCommand is the Pipeworks function runs commands in a web service.        
    #>
    param(
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [Management.Automation.CommandInfo]
    $Command,
    
    # A friendly name for the service
    [Parameter(Position=1)]
    [string]
    $FriendlyName,        

    # The order of the displayed parameters
    [Parameter(Position=2)]
    [string[]]$ParameterOrder,
            
    
    # If set, allows the command to be run without any parameters.  This is especially useful for Get- commands.
    [switch]$RunWithoutInput,
    
    # If set, these parameters will be hidden from a command handler's input and output parameters.  
    # They will still be visible in help.
    [Parameter(Position=3)]
    [Alias('DenyParameter')]
    [string[]]$HideParameter,        
    
    # The ID to use for Google Analytics tracking
    [string]
    $AnalyticsId,
    
    # The AdSenseID used to monetize the command with Google AdSense
    [string]
    $AdSenseID,
    
    # The AdSlotId used to monetize the command with Google AdSense
    [string]
    $AdSlot,
    
    # If set, allows the command to be downloaded
    [Switch]$AllowDownload,
       

    # If set, the command will be enabled as a web service.  This parameter is implied by almost every other parameter (except -ShowHelp, which contravenes it), and is primarily present for backwards-compatibility.    
    [Switch]
    $RunOnline,

    # If set, the payment has been processed by the server.  This is used internally to finalize actions after payments.
    [switch]
    $PaymentProcessed,
    
    # If SessionThrottle is set, the request handler will wait for at least the -SessionThrottle before 
    # allowing the user to re-run the command.  This can be useful in mitigating Denial of Service attacks
    # as well as providing an avenue to upsell (i.e. a free user can run a command once a minute, where as a premium user can run requests without the throttle)
    [Timespan]
    $SessionThrottle = "0:0:0",    
        
    # If set, escapes the output from the command, so it can be embedded into a webpage
    [switch]$EscapeOutput,
    
    # The CSS Style section to use for the page
    [Hashtable]$Style,
        
    # If set, will output the results of the command without encasing it in a container
    [Switch]$PlainOutput,
    
    # If set, will output the results of the command with a particular content type
    [string]$ContentType,
    
    # Sets the method used for the web form.  By default, POST is used, but Get is required if the command outputs binary data (like image streams)
    [ValidateSet('POST', 'GET')]
    [string]$Method = "POST",
    
    # If set, will not add sharing links to the page 
    [Switch]$AntiSocial,
    
    # The Module Service URL.  
    # If this is not set, this will automatically be the url to the command directory.
    [Uri]$ServiceUrl,
    
    # The Web Front End for a command, declared in HTML.  Setting a Web Front End will override the default front end with any web page.
    [String]$WebFrontEnd,
    
    # The Mobile Web Front End for a command, declared in HTML.  Setting a Mobile Web Front End will override the default front end with any web page.
    [String]$MobileWebFrontEnd,
          
    # A table of parameters that will get their value from a cookie
    [Hashtable]$CookieParameter = @{},
    
    # If set, will save the output in a cookie.
    [string]$SaveInCookie,

    # A table of parameter URL aliases.  These allow URLs to the sevice to become shorter.
    [Hashtable]$ParameterAlias= @{},
 
    # Default values for the parameters
    [Alias('DefaultParameter')]
    [Hashtable]$ParameterDefaultValue = @{},
    
    # Parameters that are taken from the web.config settings
    [Alias('SettingParameter')]
    [Hashtable]$ParameterFromSetting= @{},
    
    
    # Parameters that are taken from the user settings
    [Alias('UserParameter')]
    [Hashtable]$ParameterFromUser= @{},
    
    # Any additional commands that the command can be piped into.    
    # In the Sandbox service, these commands will be allowed as well
    [string[]]$PipeInto,
    
    # If set, will allow the command to be run in a sandbox
    [Switch]$RunInSandBox,
    
    # The margin on either side of the module content.  Defaults to 7.5%.
    [ValidateRange(0,100)]
    [Double]
    $MarginPercent = 7.5,
    
    # The margin on the left side of the module content. Defaults to 7.5%.
    [ValidateRange(0,100)]
    [Double]
    $MarginPercentLeft = 7.5,
    
    # The margin on the left side of the module content. Defaults to 7.5%.
    [ValidateRange(0,100)]
    [Double]
    $MarginPercentRight = 7.5,
    
    # If set, will only allow logged-in users to run the command
    [Alias('RequiresLogin', 'RequiredLogin', 'LoginRequired')]
    [Switch]
    $RequireLogin,
    
    # If set, will require an app key to run the command.  Logged in users will automatically use their app key
    [Alias('RequiresAppKey', 'RequiredAppKey', 'AppKeyRequired')]
    [Switch]
    $RequireAppKey,
    
    # If set, will track uses of an appkey.
    [string]
    $UserTable,
    
    [string]
    $UserPartition,
    
    # If set, will track parameters the user supplied for a command, and when they ran it.
    [switch]
    $KeepUserHistory,
    
    [switch]
    $KeepHistory,
    
    [switch]
    $KeepResult,
    
    # If set, will track uses of the command.
    [string]
    $UseTrackingTable,
    
    # If set, will track unique properties of the output, such as the number of times an item with a particular ID is output.   
    [string[]]
    $TrackProperty,
    
    # If set, will track unique parameters in the input, such as the number of times an input value is used
    [string[]]
    $TrackParameter,        
        
    # The name of the web.config setting containing the storage account name.  Required for tracking.
    [string]
    $StorageAccountSetting = 'AzureStorageAccountName',
    
    # The name of the web.config setting containing the storage account key. Required for tracking.
    [string]
    $StorageKeySetting = 'AzureStorageAccountKey',
    
    # Allows the command to be run only if the user is logged as one of the values.  
    # 
    #
    # Values can be email addresses or userids.  With email addresses, wildcards (i.e. *@microsoft.com) will be supported.
    [string[]]
    $IfLoggedInAs,
    
    # Validates that users are allowed to run the command by checking objects with a Condition property found in ValidUserPartition
    [string]
    $ValidUserPartition,
    
    
    # Any config settings
    [Hashtable]$ConfigSetting,
    
    # A table of costs per run by locale
    [Hashtable]
    $CostPerRun,


    # If set, makes the person pay before the command is actually executed
    [Alias('BuyNow')]
    [Switch]
    $PayNow,

    # If set, makes the person subscribe before the command is actually executed
    
    [Switch]
    $SubscribeNow,

    # The currency used for the transaction.  By default, US Dollars.  Additional currencies are treated as additional purchasing options
    [string[]]$Currency = "USD",    

    # The frequency for the subscription.  By default, every month.  Additional billing frequencies are used to create additional subscription options.
    [ValidateSet("Daily", "Weekly", "Monthly", "Yearly")]    
    [string[]]
    $BillingFrequency = 'Monthly',



    # If set, prompts for confirmation before a command will be run
    [Switch]
    $PromptForConfirmation,

    # A custom confirmation message.  If provided, -PromptForConfirmation is assumed.
    [string]
    $ConfirmationMessage,

    
    # A location to redirect to when the command is complete.
    [Uri]
    $RedirectTo,        
    
    # The amount of time to wait before redirecting (by default, no time)
    [Timespan]
    $RedirectIn,
    
    # The cost to run the command. Providing more than one cost is used to create additional subscription options.
    [Double[]]
    $Cost,
    
    # A cost factor table
    [Hashtable]
    $CostFactor= @{},
    
    
    # If set, will show the help for a command, but will not run it
    [Switch]
    $ShowHelp,

    # If provided, will use this PSOBject for the command help.
    [PSObject]
    $HelpObject,

    # If set, will hide the related items in command help.  
    [Switch]
    [Alias('HideRelatedItems')]
    $HideRelatedItem,

    # The string shown to a person when the command does not throw an error but has not output
    [Alias('NoOp')]
    [String]
    $NoOutputMessage,

    
    # The properties from the output to display
    [String[]]
    $OutputProperty,

    # Will link selected items to items from a command
    [Hashtable]
    $LinkTo,


    # If set, the command will be hidden from web front ends, but can still be directly invoked.
    [Switch]
    $Hidden,

    # If provided, the output will be rendered with a given type name.  
    # Changing this will allow you to override the look and feel of any object.
    [string]
    $AsTypename,

    # If provided, will lookup the user by email and will run commands as them.      
    # This is used for montezation, and should only be used directly very carefully.
    [string]
    $AsEmail,

    # If provided, will lookup the user by email and will run commands as them.      
    # This is used for montezation, and should only be used directly very carefully.
    [string]
    $AsUserId,

    # If provided, will not use ajax while running the command
    [Switch]
    $NoAjax,

    # If provided, will use window.external.notify to provide a notification message when complete.
    [string]
    $Notify,
    
    # If set, default values and other information the pipeworks manifest will be ignored.  This allows you to execute commands with parameters that would not be available to a web user.
    [Switch]
    $IgnoreManifest
    )
    

    begin {
        if (-not $global:session) {
            $global:Session = @{}
        }
        if (-not $global:Application) {
            $global:Application= @{}
        }        
        

        $ComputeTotalCost = {
            $totalCost = 0
            $listOfCosts= @()
            $listOfFrequencies= @()
            $listOfCurrencies = @()
            
            for ($i = 0;  $i -lt $cmdOptions.Cost.Count; $i++) {

                $listOfCosts+= $cmdOptions.Cost[$i]                    
                                                           
            }


            
                
            if ($cmdOptions.CostFactor) {
                $factoredCost = 0
                
                foreach ($kv in $cmdOptions.CostFactor.getEnumerator()) {                        
                    $parameterValue = $mergedParameters["$($kv.Value.Parameter)"]
                    if ($kv.Value.CostMap) {
                        
                        if ($kv.Value.CostMap[$parameterValue]) {
                            $factoredCost += $kv.Value.CostMap[$parameterValue]
                        } elseif ($kv.Value.CostMap[$parameterValue -as [int]]) {
                            $factoredCost += $kv.Value.CostMap[$parameterValue -as [int]]
                        }         
                        
                    } elseif ($kv.Value.CostPerItem) {
                        
                        $factoredCost += $kv.Value.CostPerItem * $parameterValue
                    }
                            
                }
                 
                $listOfCosts += $factoredCost
            }
                        
            $confirmLink = "$fullUrl"

            if ($confirmLink.Contains("?")) {
                $confirmLink += "&"
            } else {
                $confirmLink = $confirmLink.TrimEnd("/") + "/?"
            }

            $costString = "$" + $totalCost             
        }


        $getProxyCommand = {
            
if (-not $script:CachedProxies) {
    $script:CachedProxies = @{}
}

if ($script:CachedProxies["$command"]) {
    $proxyCommandText  = $script:CachedProxies["$command"]
}

$proxyCommandMetaData = [Management.Automation.CommandMetaData]$command
# then strip off hidden parameters
foreach ($p in $hideParameters){
    $null = $proxyCommandMetaData.Parameters.Remove($p)    
}

$paramBlock = [Management.Automation.ProxyCommand]::GetParamBlock($proxyCommandMetaData)
    $remoteCommandUrl= $serviceUrl.ToString() + "?command=$command"
    

$handleResponseScript  = 
"
    if (`$getWebCommandLink) { return `$str }
    `$xmlResult = `$str -as [xml]

    if (`$xmlResult) {
        Write-Verbose 'Response is XML'
        if (`$str -like '*<Object*') {
            Write-Verbose 'Response is Object Xml'
            `$str | 
                Select-Xml //Object |
                ForEach-Object {
                    `$_.Node
                } | 
                ForEach-Object {
                    if (`$_.Type -eq 'System.String') {
                        `$_.'#text'
                    } elseif (`$_.Property) {
                        `$_ | 
                            Select-Object -ExpandProperty Property | 
                            ForEach-Object -Begin {
                                `$outObject = @{}
                            } {
                                `$name = `$_.Name
                                `$value = `$_.'#Text'
                                `$outObject[`$name] = `$value
                            } -End {
                                New-Object PSObject -Property `$outObject
                            }
                    }
                }
        } else { 
            Write-Verbose 'Response is Normal Xml'
            `$strWrite = New-Object IO.StringWriter
            `$xmlResult.Save(`$strWrite)
            `$strOut = `"`$strWrite`"
            `$strOut.Substring(`$strOut.IndexOf([environment]::NewLine) + 2)
        }
    } elseif (`$str -and 
        (`$str -notlike '*://*' -or
        (`$str.ToCharArray()[1..100] | ? { `$_ -eq ' '} ))) {
        Write-Verbose 'Response is Text with spaces'
        `$str.ResponseText
    } elseif (`$xmlHttp.ResponseBody) {
        Write-Verbose 'Response is Data'
        `$r
    } elseif (`$xmlHttp.ResponseText) {
        Write-Verbose 'Response is Text'
        `$str
    } else {
        Write-Verbose 'Unknown Response'
    }
"        

$script:CachedProxies["$command"] = 
$proxyCommandText = "
function $($command.Name) {
    $([Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($proxyCommandMetaData))
    param(
    $paramBlock,
    [Timespan]`$WebCommandTimeout = '0:0:45',
    $(if ($CmdOptions.RequireAppKey -or $cmdOptions.RequireLogin -or $cmdOptions.IfLoggedInAs -or $cmdOptions.ValidUserPartition) {
    "
    # An API Key    
    [string]`$AppKey,
    
    
    # An API Key    
    [string]`$AppKeySetting,    
    "
    })
    [switch]`$GetWebCommandLink
    )
    begin {
        
        Add-Type -AssemblyName System.Web
        `$xmlHttp = New-Object -ComObject Microsoft.XmlHttp 
        `$remoteCommandUrl = '$RemoteCommandUrl'
        `$wc = New-Object Net.Webclient        
    }
    process {        
        if (`$psBoundParameters.AppKey) {
            `$script:CachedAppKey = `$appKey
        } elseif (`$psBoundParameters.AppKeySetting) {
            `$script:CachedAppKey = Get-SecureSetting `$psBoundParameters.AppKeySetting -ValueOnly
        }

        if (`$script:CachedAppKey) {
            `$appKey = `$script:CachedAppKey
        } else {
            `$appKey = ''
        }

        `$result = `$null
        `$nvc = New-Object Collections.Specialized.NameValueCollection
        `$urlParts = foreach (`$param in `$psBoundParameters.Keys) {
            if ('WebCommandTimeout', 'GetWebCommandLink', 'AppKey', 'AppKeySetting' -contains `$param) { continue }            
            `$null = `$nvc.Add(`"$($command.Name)_`$param`", `"`$(`$psBoundParameters[`$param])`")
            `"$($command.Name)_`$param=`$([Web.HttpUtility]::UrlEncode(`$psBoundParameters[`$param]))`" 
        }
        `$urlParts = `$urlParts -join '&' 
        if (`$remoteCommandUrl.Contains('?')) {
            `$fullUrl = `$RemoteCommandUrl + '&' + `$urlParts
        } else {
            `$fullUrl = `$RemoteCommandUrl + '?' + `$urlParts
        }
        
        if (`$GetWebCommandLink) {
            `$fullUrl += '&-GetLink=true'
            `$null = `$nvc.Add('GetLink', 'true')
        } else {
            $(if (-not $cmdOptions.PlainOutput) { "`$fullUrl += '&AsXml=true'" })             
            `$null = `$nvc.Add('AsXml', 'true')
        }

        if (`$AppKey) {
            if (`$fullUrl.Contains('?')) {
                `$fullUrl += '&AppKey=' + `$appKey
            } else {
                `$fullUrl += '?AppKey=' + `$appKey
            }
        }
        
        
        `$sendTime  = Get-Date
        Write-Verbose `"`$fullUrl - Sent `$sendTime`"        
        `$r = `$wc.UploadValues(`"`$remoteCommandUrl`", `"POST`", `$nvc)                    
        if (-not `$?) {
            return
        }
        `$str = [Text.Encoding]::UTF8.GetString(`$r)
        
        Write-Verbose `"`$fullUrl - Response Received `$(Get-Date)`"        
        $handleResponseScript            
        
       
                
        
    }
    
}
"

}
    }
    
    process {
        $commandWasRun = $false

        $inputWasRequested = $false

        $commandError = $null

        if (-not $ServiceUrl) {
            $ServiceUrl = "/"
        }

#        if (-not $request -and $Response) {
#            Write-Error "Must be run within a web site"
#            return
#        }                              
        
        
        $cmdmd = $Command -as [Management.Automation.CommandMetaData]
        $cmdOptions = @{} + $psBoundParameters  

         

        if (-not $FriendlyName) {
            $FriendlyName = $Command.Name
        }
        
        $manifestIsTemporary = $false
        if (-not $pipeworksManifest) {
            if ($Command.Module) {
                $global:pipeworksManifest = Get-PipeworksManifest  -ModuleName $Command.Module
                if (-not ($request -and $response)) {
                    $manifestIsTemporary = $true
                }
            }
        }
        if (-not $IgnoreManifest) {
            if ($pipeworksManifest.WebCommand.($Command.Name)) {
                foreach ($kv in $pipeworksManifest.WebCommand.($command.Name).GetEnumerator()) {
                    $cmdOptions[$kv.Key] = $kv.Value
                    Set-Variable -Name $kv.Key -Value $kv.Value
                }
            }
        }
        

        $RequestParameterNames = @{}
        foreach ($k in @($request.Params.Keys)) {
            if (-not $k) { continue }
            $RequestParameterNames[$k] = $request[$k]
        }

        
        if ($storageAccountSetting) {
            $storageAccount = Get-SecureSetting -Name $storageAccountSetting -ValueOnly
        }
        
        if ($storageKeySetting) {
            $storageKey = Get-SecureSetting -Name $storageKeySetting -ValueOnly
        }
        
                               
        $cmdHasErrors = $null

        if ($AsEmail -or $AsUserId) {
            $userExists = $null

            if ($pipeworksManifest.UserDB) {
                $TheUserDB = @{} + $pipeworksManifest.UserDB
                if ($AsEmail) {
                    $userExists = Select-SQL -FromTable $pipeworksManifest.UserDB.Name -ConnectionStringOrSetting $pipeworksManifest.UserDB.ConnectionSetting -Where "UserEmail = '$($AsEmail)'"
                } elseif ($AsUserId) {
                    $userExists = Select-SQL -FromTable $pipeworksManifest.UserDB.Name -ConnectionStringOrSetting $pipeworksManifest.UserDB.ConnectionSetting -Where "UserID = '$($AsUserId)'"
                }

                $null = $TheUserDB.Remove("Name")            
                

            } elseif ($pipeworksManifest.UserTable) {
                $TheUserTable = @{} + $pipeworksManifest.UserTable
                if (-not $cmdOptions.UserTable) {
                    $cmdOptions.UserTable = $TheUserTable.Name            
                    $UserTable = $TheUserTable.Name
                }

                if (-not $cmdOptions.UserPartition) {
                    $cmdOptions.UserPartition  = $TheUserTable.Partition
                    $UserPartition = $TheUserTable.Partition
                }


                if (-not $cmdOptions.StorageAccountSetting) {
                
                    $storageAccountSetting = $cmdOptions.StorageAccountSetting = $TheUserTable.StorageAccountSetting
                    $storageAccount = Get-SecureSetting -Name $storageAccountSetting -ValueOnly

                }

                if (-not $cmdOptions.StorageKeySetting) {
                
                    $storageKeySetting= $cmdOptions.StorageKeySetting = $TheUserTable.StorageKeySetting
                    $storageKey= Get-SecureSetting -Name $storageKeySetting -ValueOnly

                }


                $TheUserTable.Remove("Name")            
                $TheUserTable.UserTable = $pipeworksManifest.UserTable.Name
                

                if ($AsEmail) {
                    $userExists = Search-AzureTable -TableName $cmdOptions.UserTable -Filter "PartitionKey eq '$($cmdOptions.UserPartition)' and UserEmail eq '$($AsEmail)'" -StorageAccount $storageAccount -StorageKey $storageKey
                } elseif ($AsUserId) {
                    $userExists = Search-AzureTable -TableName $cmdOptions.UserTable -Filter "PartitionKey eq '$($cmdOptions.UserPartition)' and RowKey eq '$($AsUserId)'" -StorageAccount $storageAccount -StorageKey $storageKey
                }
            }

            

            if (-not $userExists) {
                if ($AsEmail) {
                    $userExists = New-Object PSObject -Property @{
                        UserEmail = $AsEmail
                    }
                } elseif ($AsUserId) {
                    $userdomain = if ($pipeworksManifest.DomainSchematics) {
                        @($pipeworksManifest.DomainSchematics.Keys)[0]
                    } else {
                        "unknown.com"
                    }
                    $userExists = New-Object PSObject -Property @{
                        UserEmail = "$asUserId@$userdomain"
                    }
                }
            } 

            if ($AsEmail) {
                if ($pipeworksManifest.UserDB) {
                        New-Object PSObject -Property $TheUserDB |
                            Confirm-Person -WebsiteUrl $serviceUrl -Email $userExists.UserEmail -PersonObject $userExists  
                } else {
                    $confirmedUserAccount = 
                        New-Object PSObject -Property $TheUserTable |
                            Confirm-Person -WebsiteUrl $serviceUrl -Email $userExists.UserEmail -PersonObject $userExists -StorageAccountSetting $StorageAccountSetting -StorageKeySetting $StorageKeySetting            

                }
            } elseif ($AsUserId -and $userExists) {
                $confirmedUserAccount = $userExists
                
            }


            if ($confirmedUserAccount) {
                $session["User"] = $confirmedUserAccount 
            }

        }

        

        if ($session -and (-not $session['User'])) {
            if ($cmdOptions.IfLoggedInAs -or $cmdOptions.RequireLogin -or $cmdOptions.ValidUserPartition) {
                
                $confirmHtml = . Confirm-Person -WebsiteUrl $ServiceUrl 
                if (-not $session['User']) {
                    '<span style="margin-top:3%;margin-bottom:3%" class=''ui-state-error''>You have to log in</span><br/>'  + $confirmHtml   
                    return
                } 

                
            }            
        }

        if ($cmdOptions.IfLoggedInAs -or $cmdOptions.ValidUserPartition) {
            $ok = Confirm-Person -CheckId -WebsiteUrl $ServiceUrl -IfLoggedInAs $cmdOptions.IfLoggedInAs -ValidUserPartition $cmdOptions.ValidUserPartition
            if (-not $ok) { return } 

        }
        <#
        $okIf = @()
        # ValidateUserTable preceeds IfLoggedInAs, and $ok is set first.
        # this way, logins in tables work as well as specific whitelists                                        
        if ($cmdOptions.ValidUserPartition) {
            $okUserList = 
                Search-AzureTable -TableName $UserTable -Filter "PartitionKey eq '$($cmdOptions.ValidUserPartition)' and IfLoggedInAs ne ''" -Select IfLoggedInAs -StorageAccount $storageAccount -StorageKey $storageKey   -ExcludeTableInfo
            $okUserIf = $okUserList | 
                Select-Object -ExpandProperty IfLoggedInAs
            
            $okIf += $okUserIf    
        }
        
        if ($cmdOptions.IfLoggedInAs) {
            $okIf += $cmdOptions.IfLoggedInAs                    
        }
        
        if ($okIf) {
            $ok = $false
            $global:notOkReason = ""
            foreach ($if in $okIf) {
                if ($If -eq '*') {
                    if ($session['User']) {
                        $ok= $true
                        break
                    }
                    $global:notOkReason = "Not Logged In"
                } 
                if ($if -like "*@*") {
                    # Email
                    if ($session["User"].UserEmail -like $if)  {
                        $ok = $true
                        break
                    }
                } elseif ($if -like "*:*") {
                    $ifParts = $if -split ':'
                    if ($ifParts[0] -ieq 'memberOf') {
                        if ($session['User'].MemberOf -and $session['User'].MemberOf -like "*$($ifParts[1])*") {
                            $ok = $true
                            break
                        }
                        $global:notOkReason = "Not Member Of $($ifParts[1])"
                    } elseif ($ifParts[0] -ieq 'notMemberOf') {
                        if ($session['User'].MemberOf -and $session['User'].MemberOf -notlike "*$($ifParts[1])*") {
                            $ok = $true
                            break
                        }
                        $global:notOkReason = "Member Of $($ifParts[1])"
                    } elseif ($ifParts[0] -ieq 'awarded') {
                        if ($session['User'].Awards -and $session['User'].Awards -like "*$($ifParts[1])*") {
                            $ok = $true
                            break
                        }
                    } elseif ($ifParts[0] -ieq 'notAwarded') {
                        if ($session['User'].Awards -and $session['User'].Awards -notlike "*$($ifParts[1])*") {
                            $ok = $true
                            break
                        }
                    } elseif ($ifParts[0] -ieq 'interactionCount') {
                        $interactionCountOperations = if ($ifParts[1] -like "*>=*") {
                            if ($session['User'].InteractionCount) {
                                $interactionCountData = ConvertFrom-StringData -StringData "$($session['User'].InteractionCount)".Replace(':', '=') -ErrorAction SilentlyContinue
                                $equation = $ifParts[1] -split "\>="

                                if (($interactionCountData[$equation[0].Trim()] -as [double]) -ge ($equation[1] -as [double])) {
                                    $ok=$true
                                    break
                                }
                            } 
                                
                                
                        } elseif ($ifParts[1] -like "*>*") {
                            if ($session['User'].InteractionCount) {
                                $interactionCountData = ConvertFrom-StringData -StringData "$($session['User'].InteractionCount)".Replace(':', '=') -ErrorAction SilentlyContinue
                                $equation = $ifParts[1] -split "\>"

                                if (($interactionCountData[$equation[0].Trim()] -as [double]) -gt ($equation[1] -as [double])) {
                                    $ok=$true
                                    break
                                }
                            } 
                                
                                
                        } if ($ifParts[1] -like "*<=*") {
                            if ($session['User'].InteractionCount) {
                                $interactionCountData = ConvertFrom-StringData -StringData "$($session['User'].InteractionCount)".Replace(':', '=') -ErrorAction SilentlyContinue
                                $equation = $ifParts[1] -split "\<="

                                if (($interactionCountData[$equation[0].Trim()] -as [double]) -le ($equation[1] -as [double])) {
                                    $ok=$true
                                    break
                                }
                            }                                                                 
                        } elseif ($ifParts[1] -like "*<*") {
                            if ($session['User'].InteractionCount) {
                                $interactionCountData = ConvertFrom-StringData -StringData "$($session['User'].InteractionCount)".Replace(':', '=') -ErrorAction SilentlyContinue
                                $equation = $ifParts[1] -split "\<"

                                if (($interactionCountData[$equation[0].Trim()] -as [double]) -lt ($equation[1] -as [double])) {
                                    $ok=$true
                                    break
                                }
                            }
                        }
                    }
                } else {
                    if ($session["User"].UserId -eq $if) {
                        $ok = $true
                        break
                    }
                    $global:notOkReason = "Not Correct UserID"
                }
            }
            
            if (-not $ok) {  return } 
        }
        #>
        
        $depth = 0
        $fullUrl = "$($request.Url)"
        if ($request -and $request.Params -and $request.Params["HTTP_X_ORIGINAL_URL"]) {
            
            #region Determine the Relative Path, Full URL, and Depth
            $originalUrl = $context.Request.ServerVariables["HTTP_X_ORIGINAL_URL"]
            $urlString = $request.Url.ToString().TrimEnd("/")
            $pathInfoUrl = $urlString.Substring(0, 
                $urlString.LastIndexOf("/"))
                                                            
            $protocol = ($request['Server_Protocol'].Split("/", 
                [StringSplitOptions]"RemoveEmptyEntries"))[0] 
            $serverName= $request['Server_Name']                     
            
            $port=  $request.Url.Port
            $fullOriginalUrl = 
                if (($Protocol -eq 'http' -and $port -eq 80) -or
                    ($Protocol -eq 'https' -and $port -eq 443)) {
                    $protocol+ "://" + $serverName + $originalUrl 
                } else {
                    $protocol+ "://" + $serverName + ':' + $port + $originalUrl 
                }
                                                    
            $rindex = $fullOriginalUrl.IndexOf($pathInfoUrl, [StringComparison]"InvariantCultureIgnoreCase")
            $relativeUrl = $fullOriginalUrl.Substring(($rindex + $pathInfoUrl.Length))
            if ($relativeUrl -like "*/*") {
                $depth = @($relativeUrl -split "/" -ne "").Count - 1                    
                if ($fullOriginalUrl.EndsWith("/")) { 
                    $depth++
                }                                        
            } else {
                $depth  = 0
            }
            #endregion Determine the Relative Path, Full URL, and Depth                                                
            $fullUrl = $fullOriginalUrl
            
        }
        
        $global:FullUrl = $fullUrl
        
        $depthChunk = "../"  * $depth
        
        $commandParameters = Get-WebInput -ParameterAlias $cmdOptions.ParameterAlias -CommandMetaData $command -DenyParameter $HideParameter -ErrorAction SilentlyContinue -ErrorVariable ValidationErrors                 
        
        # Prefer supplied parameters to default values, but remove one or the other or the commands will not run
        $defaultValues = $cmdOptions.parameterDefaultValue
        $cmdParamNames = $commandParameters.Keys 
        foreach ($k in @($defaultValues.Keys)) {
            if (-not $k) { continue} 
            if ($cmdParamNames -contains $k -and $commandParameters[$k]) {
                $null = $defaultValues.Remove($k)
            }
        }
        if (-not $defaultValues) {
            $defaultValues = @{}
        }


        if (-not $commandParameters ) {
            $commandParameters = @{}
        }

        $parametersFromCookies = @{}
        if ($cmdOptions.CookieParameter) {        
            foreach ($parameterCookieInfo in $cmdOptions.CookieParameter.GetEnumerator()) {
                if ($command.Parameters[$parameterCookieInfo.Key]) {    
                    $cookie = $request.Cookies[$parameterCookieInfo.Value]
                    if ($cookie) {
                        $parametersFromCookies[$parameterCookieInfo.Key] = $cookie
                    }            
                }
            }
            

            foreach ($k in @($parametersFromCookies.Keys))
            {
                if ($cmdParamNames -contains $k -and $commandParameters[$k]) {
                    $null = $parametersFromCookies.Remove($k)
                }
            }
        }


        $parametersFromSettings = @{}
        if ($cmdOptions.ParameterFromSetting) {
            foreach ($parameterSettingInfo in $cmdOptions.parameterFromSetting.GetEnumerator()) {
                if ($command.Parameters[$parameterSettingInfo.Key]) {    
                    $webConfsetting = Get-SecureSetting -Name $parameterSettingInfo.Value -ValueOnly
                    if ($webConfsetting ) {
                        $parametersFromSettings[$parameterSettingInfo.Key] = $webConfsetting
                    }            
                }
            }

            foreach ($k in @($parametersFromSettings.Keys))
            {
                if ($cmdParamNames -contains $k -and $commandParameters[$k]) {
                    $null = $parametersFromSettings.Remove($k)
                }
            }
        }


        $parametersFromUser = @{}
        if ($cmdOptions.ParametersFromUser) {
            foreach ($parameterUserInfo in $cmdOptions.parametersFromUser.GetEnumerator()) {
                if ($command.Parameters[$parameterUserInfo.Key]) {    
                    $userSetting = if ($session -and $session['User'].($parameterUserInfo.Key)) {
                        $session['User'].($parameterUserInfo.Key)
                    }  else {
                        $null
                    }
                    if ($userSetting ) {
                        $parametersFromUser[$parameterUserInfo.Key] = $userSetting 
                    }            
                }
            }

            foreach ($k in @($parametersFromUser.Keys))
            {
                if ($cmdParamNames -contains $k -and $commandParameters[$k]) {
                    $null = $parametersFromUser.Remove($k)
                }
            }

        
        }
        

        $nonDefaultParameters = @{} + $commandParameters + $parametersFromCookies + $parametersFromSettings + $parametersFromUser
        $mergedParameters = @{} + $commandParameters + $defaultValues + $parametersFromCookies + $parametersFromSettings + $parametersFromUser
        
        if (-not $HelpObject) {
            $helpObj = $command | Get-Help -ErrorAction SilentlyContinue
        } else {
            $helpObj = $HelpObject
        }
        

        if ($RequestParameterNames.'Download') {
            # If the module can be downloaded, let the command be downloaded.  Otherwise, download the proxy
            if ($cmdOptions.AllowDownload) {
$proxyCommandText = "function $($Command.Name) { 
$($Command.Definition)
}
" } elseif (-not $ShowHelp) {
    $proxyCommandText = . $getProxyCommand
} else {
    $proxyCommandText = " " 
}




if ($Request.Params["AsHtml"]) {
$webPage = Write-ScriptHtml ([ScriptBlock]::create($proxyCommandText)) 
$webPage
} else {
    #$proxyCommandText
    $response.ContentType = "text/plain"
    $response.Write($proxyCommandText)
    $response.Flush()
}

return
        } elseif ($ShowHelp -or 
            ($Request -and $Request["GetHelp"]) -or
            $FullUrl.EndsWith("-?")){
            # The Help Handler
            
            if ($HelpObject) {
                $commandTitleArea = "<h2>$($HelpObject.Details.Name)</h2>"
            } else {
                $commandTitleArea = "<h2>$command</h2>"
            }
            
            
            
            # $helpObj = $command | Get-Help 
            
            
            $helpContent =
                if ($HelpObj.Synopsis) {
                    $description = @($helpObj.Description)[0].Text
                    "<h3>$($helpObj.Synopsis)</h3>" + 
                        (ConvertFrom-Markdown -Markdown "$description " )
                    
                    $navLinks = @(@($helpObj.relatedLinks)[0].NavigationLink)
                    $examples = @(@($helpObj.examples)[0].Example)
                    $parameters = @(@($helpObj.parameters)[0].Parameter)
                    
                    $seeAlso = foreach ($nav in $navLinks) {
                        if ($nav.LinkText) {
                            # Link to topic or command
                            $isCommand  = 
                                if ($command.ScriptBlock.Module.ExportedFunctions.($nav.LinkText) -or $command.ScriptBlock.Module.ExportedCmdlets.($nav.LinkText)) {
                                    $command.ScriptBlock.Module.ExportedCommands[$nav.LinkText]
                                } else {
                                    $false
                                }
                            
                            if ($isCommand) {
                                Write-Link -Style @{
                                    "font-size"="small";
                                    "text-align" = "center"
                                    width="66%"
                                } -Url "$($depthChunk)$($nav.LinkText)-?" -Caption $nav.LInktext -Button
                            } elseif ($nav.LinkText -like "*_*") {
                                Write-Link -Style @{
                                    "font-size"="small";
                                    "text-align" = "center"
                                    width="66%"
                                } -Url "$($depthChunk)$($nav.LinkText.Replace('_', ' '))" -Caption $nav.LInktext.Replace("_"," ") -Button
                            }
                        } elseif ($nav.Uri) {
                            # External link
                            Write-Link -Style @{
                                    "font-size"="small";
                                    "text-align" = "center"
                                    width="66%"
                            } -Url $nav.Uri -Caption $nav.Uri -Button
                         }
                    }
                    
                    $examples = foreach ($ex in $examples) {
                        if ($ex) {
                            $s = $ex | Out-String
                            $s = $s.Substring($s.IndexOf("C:\PS>") + 6)
                            
                            # One line trimmed example, use remarks
                            if ($s.Trim().Length -ge 63 -and $s.Trim().Length -lt 64) {
                                $remarks = $s.Remarks | ForEach-Object {$_.Text } 
                                $s = $remarks
                            }

                            $sAsScriptBlock = try { 
                                [ScriptBlock]::Create($s)
                            } catch {
                                
                            }
                            
                            if ($sAsScriptBlock) {
                                Write-ScriptHTML -Text $sAsScriptBlock
                            } else {
                                $s
                            }
                        }
                    }
                    
                    
                    $parameterLayer = @{}
                    foreach ($param in $parameterS) {
                        if (-not $param) {
                            continue
                        }
                        if ($HideParameter -contains $param.Name) {
                            continue
                        }
                        $parameterLayer[$param.Name]  =
                            ConvertFrom-Markdown -Markdown "$(@($param.Description)[0].Text) " -ScriptAsPowerShell
                    }
                    
                    
                    $helpTabs = @{}
                    
                    if ($examples) {
                        $exLayer = @{}
                        $c = 0
                        foreach ($ex in $examples) {
                            $c++
                            $exLayer["Example $c"] = $ex    
                        }

                        if ($pipeworksManifest.UseBootstrap) {

                        $helpTabs.Examples=  
                            New-Region -Style @{
                                "Font-size" = "small"
                            } -asHeadline -layer $exLayer -layerId "$($command)_Example_Content"

                        } elseif ($pipeworksManifest.UseJQueryUI) {

                        $helpTabs.Examples=  
                            New-Region -Style @{
                                "Font-size" = "small"
                            } -AsAccordian -layer $exLayer -layerId "$($command)_Example_Content"

                        } else {
                        $helpTabs.Examples=  
                            New-Region -Style @{
                                "Font-size" = "small"
                            } -AsHangingSpan -layer $exLayer -layerId "$($command)_Example_Content"

                        }
                        
                    }
                    
                    if ($seeAlso -and (-not $HideRelatedItem)) {
                        
                        $helpTabs."Related Links" = "<p style='text-align:center'>" + ($seeAlso -join "<BR/>") + "</p>"
                    }
                    
                    if ($parameterLayer) {
                        if ($pipeworksManifest.UseBootstrap) {
                            $helpTabs.Parameters = 
                            New-Region -Style @{
                                "Font-size" = "small"
                            } -asheadline -LayerId "$($Command)_Parameters" -layer $parameterLayer
                        } elseif ($pipeworksManifest.UseJQueryUI) {
                            $helpTabs.Parameters = 
                            New-Region -Style @{
                                "Font-size" = "small"
                            } -aspopout -LayerId "$($Command)_Parameters" -layer $parameterLayer
                        } else {
                            $helpTabs.Parameters = 
                            New-Region -Style @{
                                "Font-size" = "small"
                            } -AsHangingSpan -LayerId "$($Command)_Parameters" -layer $parameterLayer
                        }
                    }
                    
                    $order = $helpTabs.Keys | 
                        Sort-Object -Descending

                    New-Region -LayerID "$($command)_HelpContent" -Style @{
                        "Font-size" = "Medium"
                    } -AsTab $helpTabs -Order $order
                    
                } else {
                    # Syntax only help, just display a pre
                    "<pre>$($helpObj)</pre>"
                }
            
            
            
            
            ($commandTitleArea, ($helpContent -join '')| 
                New-Region -Style @{                    
                }) -join ([Environment]::NewLine)
                
                
            return
        } elseif ($Request -and $Request["Platform"]) {
            $platform = $request["Platform"]

            $allHiddenParameters =@() + $HideParameter
            
            if ($ParameterDefaultValue) {
                $allHiddenParameters += $ParameterDefaultValue.Keys
            }

            $inputForPlatform = Request-CommandInput -Platform $platform -CommandMetaData $cmdMd -DenyParameter $allHiddenParameters

            if ($platform -ne 'Web' -and ($inputForPlatform -as [xml])) {
                $strWrite = New-Object IO.StringWriter
                ([xml]$inputForPlatform).Save($strWrite)
                $resultToOutput  = "$strWrite" -replace "encoding=`"utf-16`"", "encoding=`"utf-8`""
                if (-not $cmdOptions.ContentType) {
                    $response.ContentType ="text/xml"
                }
                $response.Write("$resultToOutput")    

                
            } else {
                if ($platform -ne 'Web') {
                    $Response.ContentType = 'text/plain'
                } else {
                    $inputForPlatform = $inputForPlatform | 
                        New-WebPage -UseJQueryUI
                }
                $Response.Write($inputForPlatform)
            }

        } elseif ($request -and $Request["Body"] -and
            $Request["From"] -and
            $Request["To"] -and
            $Request["SmsSid"] -and
            $Request["AccountSid"]) {
            
            
            # Text handler 
            # The command is being texted.  If the command contains parameters that match, use them, otherwise, pass the whole
            # body as an embedded script in data language mode.
            $cmdParams = @{} + $commandParameters
            
            if ($cmdOptions.ShowHelp) {
                # Text Back the Description
                
                $helpObj= (Get-Help $cmdMd.Name)
                $description  = if ($helpObj.Description) {
                    $helpObj.Description[0].text.Replace('"',"'").Replace('<', '&lt;').Replace('>', '&gt;').Replace('$', '`$')
                } else {
                    ""
                }
                
                $response.contentType = 'text/xml'
                
                
                $response.Write("<?xml version='1.0' encoding='UTF-8'?>
        <Response>
            <Sms>$($cmdMd.name): $([Security.SecurityElement]::Escape($Description))</Sms>
        </Response>        ") 
                $response.Flush()
                
                
                return                  
            }
            
            #region Conditionally move any parameters found into the cmdparams  
            if ($command.Parameters.From -and $request['From']) {
                $cmdParams["From"] = $request['From']
            }
            
            if ($command.Parameters.To -and $request['To']) {
                $cmdParams["To"] = $request['To']
            }
               
            
            if ($command.Parameters.Body -and $request['Body']) {
                $cmdParams["Body"] = $request['Body']
            }
            
            if ($command.Parameters.AccountSid -and $request['AccountSid']) {
                $cmdParams["Accountsid"] = $request['Accountsid']
            }
            
            if ($command.Parameters.SmsSid -and $request['SmsSid']) {
                $cmdParams["SmsSid"] = $request['SmsSid']
            }
            
            if ($command.Parameters.FromCity -and $request['FromCity']) {
                $cmdParams["FromCity"] = $request['FromCity']
            }
            
            if ($command.Parameters.FromState -and $request['FromState']) {
                $cmdParams["FromState"] = $request['FromState']
            }
            
            if ($command.Parameters.FromZip -and $request['FromZip']) {
                $cmdParams["FromZip"] = $request['FromZip']
            }
            
            if ($command.Parameters.FromCountry -and $request['FromCountry']) {
                $cmdParams["FromCountry"] = $request['FromCountry']
            }
            
            
            if ($command.Parameters.ToCity -and $request['ToCity']) {
                $cmdParams["ToCity"] = $request['ToCity']
            }
            
            if ($command.Parameters.ToState -and $request['ToState']) {
                $cmdParams["ToState"] = $request['ToState']
            }
            
            if ($command.Parameters.ToZip -and $request['ToZip']) {
                $cmdParams["ToZip"] = $request['ToZip']
            }
            
            if ($command.Parameters.ToCountry -and $request['ToCountry']) {
                $cmdParams["ToCountry"] = $request['ToCountry']
            }  

            $allowedParameter  = @($cmdMd.Parameters.Keys )
            if (-not $AllowedParameter) {
                $allowedParameter  = $cmdMd.Parameters.Keys 
            }
   
            # If a parameter set was provided, filter out parameters from other parameter sets
            if ($parameterSet) {        
                $allParameters = $allowedParameter |
                    Where-Object {
                        $cmdMd.Parameters[$_].Attributes | 
                            Where-Object { $_.ParameterSetName -eq $parameterSet }
                    }
            }
        
            if ($parameterSet) {        
                $allParameters = $allParameters |
                    Where-Object {
                        $cmdMd.Parameters[$_].Attributes | 
                            Where-Object { $_.ParameterSetName -eq $parameterSet }
                    }
            }
                 
            $allParameters = foreach ($param in $allowedParameter) {
                if ($HideParameter -notcontains $param) {
                    $param
                }
            }
        
            # Order parameters if they are not explicitly ordered
            if (-not $order) {
                $order = 
                     @($allParameters |                         
                        Select-Object @{
                            Name = "Name"
                            Expression = { $_ }
                        },@{
                            Name= "NaturalPosition"
                            Expression = { 
                                $p = @($cmdMd.Parameters[$_].ParameterSets.Values)[0].Position
                                if ($p -ge 0) {
                                    $p
                                } else { 1gb }                                              
                            }
                        } |                         
                        Sort-Object NaturalPosition| 
                        Select-Object -ExpandProperty Name)
            }
            

          
            if (-not $cmdParams.Body) {
                $body = 
                    if ($request -and $request.Params -and $request.Params['Body']) {
                        $request.Params['Body']
                    } else {
                        ""
                    }
                    

                # The body should strip off the command specifier, so that the input could be easily redirected from a module
                $possibleCmdNames = 
                    @(Get-Alias -Definition "$($cmdMd.Name)" -ErrorAction SilentlyContinue) + "$($cmdMd.Name)"
                
                foreach ($pcn in $possibleCmdNames) {
                    if ($body -like "$pcn*") {
                        $body = $body.Susbstring("$pcn".Length).TrimStart(":").TrimStart("-")
                    }
                }

                $body = $body.Replace(",", '`,').Replace("(", '`(').Replace(")",'`)').Replace(";", '`;')
                
                
                
                $dataScriptBlock = [ScriptBlock]::create("
$($cmdMd.Name) @cmdParams $body 
                ")
                
                
                
                $dataScriptBlock = [ScriptBlock]::Create("data -SupportedCommand $($cmdMd.Name) { $dataScriptBlock } ")        
                try {
                    $error.clear()
                    $outputData = & $dataScriptBlock               

                } catch {
                    $errorRecord = $_
                    
                   
                }
                
            } else {
                $error.clear()
                try {
                    $outputData = & $command @mergedParameters 2>&1     
                } catch {
                    $errorRecord = $_
                    
                }
            }


            
            
            if ($outputData -is [string]) {
                $response.contentType = 'text/xml'
                $response.Write("<?xml version='1.0' encoding='UTF-8'?>
        <Response>
            <Sms>$([Security.SecurityElement]::Escape($OutputData))</Sms>
        </Response>")
            } elseif ($outputData -is [Management.Automation.ErrorRecord]) {
                $msg = $OutputData.Message
                $msg = if ($msg.Length -gt 160) {
                    $msg.Substring(0, 159)
                } else {
                    $msg
                }
                $response.contentType = 'text/xml'
                $response.Write("<?xml version='1.0' encoding='UTF-8'?>
        <Response>
            <Sms>$([Security.SecurityElement]::Escape($msg))</Sms>
        </Response>")
            } elseif ($ErrorRecord) {
                $msg = "$errorRecord"
                $msg = if ($msg.Length -gt 160) {
                    $msg.Substring(0, 159)
                } else {
                    $msg
                }
                $response.contentType = 'text/xml'
                $response.Write("<?xml version='1.0' encoding='UTF-8'?>
        <Response>
            <Sms>$([Security.SecurityElement]::Escape($msg))</Sms>
        </Response>")
            } else {
                $outputText = ""        
                
                # Loop thru each object and concatenate properties
                foreach ($outputItem in $outputData) {
                    foreach ($kv in $outputItem.psObject.properties) {
                        if (-not $kv) { continue } 
                        $outputText += "$($kv.Name):$($kv.Value)$([Environment]::NewLine)"
                    }
                }

                if ($outputText) {
                    $response.contentType = 'text/xml'
                    $response.Write("<?xml version='1.0' encoding='UTF-8'?>
            <Response>
                <Sms>$($outputText)</Sms>
            </Response>")
                
                }
                        
            }                                                                            
            return                  
            
                 
        } elseif ($Request -and $Request["CallSid"] -and
            $Request["From"] -and
            $Request["To"] -and
            $Request["AccountSid"]
        ) { 
            # Phone handler

            $callSid = $request["CallSid"]

            $cmdParams = @{} + $commandParameters

            if ($parameterDefaultValue) {
                foreach ($d in $ParameterDefaultValue.Keys) {
                    if (! $cmdParams.ContainsKey($D)) {
                        $cmdParams[$d] = $ParameterDefaultValue[$d]
                    }
                }                
            }
            



            if ($command.Parameters.From -and $request['From']) {
                $cmdParams["From"] = $request['From']
            }
            
            if ($command.Parameters.To -and $request['To']) {
                $cmdParams["To"] = $request['To']
            }
               

            if ($command.Parameters.AccountSid -and $request['AccountSid']) {
                $cmdParams["Accountsid"] = $request['Accountsid']
            }
            
            if ($command.Parameters.CallSid -and $request['CallSid']) {
                $cmdParams["CallSid"] = $request['CallSid']
            }
            
            if ($command.Parameters.FromCity -and $request['FromCity']) {
                $cmdParams["FromCity"] = $request['FromCity']
            }
            
            if ($command.Parameters.FromState -and $request['FromState']) {
                $cmdParams["FromState"] = $request['FromState']
            }
            
            if ($command.Parameters.FromZip -and $request['FromZip']) {
                $cmdParams["FromZip"] = $request['FromZip']
            }
            
            if ($command.Parameters.FromCountry -and $request['FromCountry']) {
                $cmdParams["FromCountry"] = $request['FromCountry']
            }
            
            
            if ($command.Parameters.ToCity -and $request['ToCity']) {
                $cmdParams["ToCity"] = $request['ToCity']
            }
            
            if ($command.Parameters.ToState -and $request['ToState']) {
                $cmdParams["ToState"] = $request['ToState']
            }
            
            if ($command.Parameters.ToZip -and $request['ToZip']) {
                $cmdParams["ToZip"] = $request['ToZip']
            }
            
            if ($command.Parameters.ToCountry -and $request['ToCountry']) {
                $cmdParams["ToCountry"] = $request['ToCountry']
            }

            $allowedParameter  = @($cmdMd.Parameters.Keys )
            if (-not $AllowedParameter) {
                $allowedParameter  = $cmdMd.Parameters.Keys 
            }
   
            # If a parameter set was provided, filter out parameters from other parameter sets
            if ($parameterSet) {        
                $allParameters = $allowedParameter |
                    Where-Object {
                        $cmdMd.Parameters[$_].Attributes | 
                            Where-Object { $_.ParameterSetName -eq $parameterSet }
                    }
            }
        
            
            $allParameters = foreach ($param in $allowedParameter) {
                if ($HideParameter -notcontains $param -and (! $CmdParams.ContainsKey($param))) {
                    $param
                }
            }
            
            
            

            
        
            # Order parameters if they are not explicitly ordered
            $order = 
                    @($allParameters |                         
                    Select-Object @{
                        Name = "Name"
                        Expression = { $_ }
                    },@{
                        Name= "NaturalPosition"
                        Expression = { 
                            $p = @($cmdMd.Parameters[$_].ParameterSets.Values)[0].Position
                            if ($p -ge 0) {
                                $p
                            } else { 1gb }                                              
                        }
                    } |
                    Where-Object { $_.NaturalPosition -ne 1gb -and (! $CmdParams.ContainsKey($_.Name))} | 
                    Sort-Object NaturalPosition| 
                    Select-Object -ExpandProperty Name)
     
            

            $parameterNumber = 
                if ($request["ParameterNumber"]) {
                    $request["ParameterNumber"] -as [Int32]
                } else {
                    0
                }
                
            
            # In phone calls, the system needs to keep track of the state of each individual call.  
            # This is done using a cookie keyed off of the CallSid
            $callSid = $request["CallSid"]
            $parameterValues = @()

            for ($pN = 0; $pn -lt $parameterNumber; $pn++) {
                if ($request["P$Pn"]) {
                    # A parameter value exists!
                    $parameterValues+= $request["P$pn"]
                        
                    
                }
            }

            
            
            
            $helpObj= ($command | Get-Help)            
            
            $responseXml = "<Response>"
                             
            if ($parameterNumber -lt $order.Count) {
                $parameterInfo = $order[$parameterNumber]
                $parameterInfo = $command.Parameters[$parameterInfo] 
            } else {
                $parameterInfo  = $null
            }                                    
            
            $parameter = $parameterInfo.Name
            $parameterType = $parameterInfo.ParameterType
            $validateSet = 
                foreach ($attribute in $parameterInfo.Attributes) {
                    if ($attribute.TypeId -eq [Management.Automation.ValidateSetAttribute]) {
                        $attribute
                        break
                    }
                }
                
            $parameterHelp  = 
                foreach ($p in $helpObj.Parameters.Parameter) {
                    if ($p.Name -eq $parameter) {
                        $p.Description | Select-Object -ExpandProperty Text
                    }
                }                
            
                
            $parameterVisibleHelp = $parameterHelp -split ("[`n`r]") |? { $_ -notlike "|*" } 
            
            $pipeworksDirectives  = @{}
            foreach ($line in $parameterHelp -split ("[`n`r]")) {
                if ($line -like "|*") {
                    $directiveEnd= $line.IndexofAny(": `n`r".ToCharArray())
                    if ($directiveEnd -ne -1) {
                        $name, $rest = $line.Substring(1, $directiveEnd -1).Trim(), $line.Substring($directiveEnd +1).Trim()
                        $pipeworksDirectives.$Name = $rest
                    } else {
                        $name = $line.Substring(1).Trim()
                        $pipeworksDirectives.$Name = $true
                    }
                    
                    
                }
            }                


            if ($request.Cookies["CallStatusFor_${CallSid}"]) {
                $callStatusCookie = $request.Cookies["CallStatusFor_${CallSid}"]
            } else {
                $callStatusCookie = New-Object Web.HttpCookie "CallStatusFor_${CallSid}"
            }
            


            
            
            if ($pipeworksDirectives.Options -or $validateSet -or ($parameterType -and $parameterType.IsSubClassOf([Enum]))) {
                $optionList = 
                    if ($pipeworksDirectives.Options) {
                        Invoke-Expression -Command "$($pipeworksDirectives.Options)" -ErrorAction SilentlyContinue
                    } elseif ($ValidateSet) {
                        $ValidateSet.ValidValues
                    } elseif ($parameterType -and $parameterType.IsSubClassOf([Enum])) {
                        [Enum]::GetValues($parameterType)
                    }            

            } else {
                $optionList = @()
            }

                               
            if  ($parameterInfo -and 
                                
                $Request["TranscriptionText"]) {
                # The person has supplied a value to a parameter, store it and move on
                
                if ($parameterInfo.ParameterType -eq [ScriptBlock]) {
                    $parameterValues += try { [ScriptBlock]::Create($Request["TranscriptionText"]) } catch {} 
                } else {
                    $parameterValues += ($Request["TranscriptionText"] -as $parameterInfo.ParameterType)
                }
                $parameterValues += $Request["TranscriptionText"]

                $callStatusCookie["ParameterValue_$parameterInfo"]  = 
                    $Request["RecordingUrl"]

                $parameterNumber++                            
            } elseif  (
                $Request["RecordingUrl"]) {
                # A recording
                $callStatusCookie["ParameterValue_$parameterInfo"]  = 
                    $Request["RecordingUrl"]
                $parameterValues += $Request["RecordingUrl"]
                $parameterNumber++
            } elseif ($Request["Digits"]) {
                # The person has supplied a value to a parameter, add it to the cookie and move on
                $callStatusCookie["ParameterValue_$parameterInfo"]  = 
                    $request["Digits"].TrimEnd("#").TrimEnd("*")
                $digit = $request["Digits"].TrimEnd("#").TrimEnd("*") -as [Uint32]
                if ($optionList -and $optionList[$digit - 1]) {
                    $parameterValues += $optionList[$digit - 1]
                } else { 
                    $parameterValues += $digit
                }

                
                $parameterNumber++                
            } else {
                if ($parameterNumber -eq 0 ) {

                    $description  = if ($helpObj.Description) {
                        $helpObj.Description[0].text.Replace('"',"'").Replace('<', '&lt;').Replace('>', '&gt;').Replace('$', '`$')                        
                    } else {
                        ""
                    }

                    if ($description) {
                        if ($description -like "http://*") {
                            $responseXml  += "<Play>$([Security.SecurityElement]::Escape($description))</Play>"            
                        } else {
                            $responseXml  += "<Say>$([Security.SecurityElement]::Escape($description))</Say>"            
                        }
                        
                    }
                    
                }
            }


            if ((-not $order.Count) -or ($parameterNumber -eq $order.Count)) {

                $params = @{}

                
                for ($on = 0 ; $on -lt $order.count; $on++) {
                    $paramInfo = $Command.Parameters[$order[$on]]
                    if ($paramInfo.ParameterType -eq [switch]) {
                        $params[$order[$on]] = if ($parameterValues[$on] -eq 0) { $false } else { $true } 
                    } else {
                        $params[$order[$on]] = $parameterValues[$on]
                    }
                    
                }
                

                foreach ($p in $params.GetEnumerator()) {
                    $cmdParams[$p.Key] = $p.Value
                    
                }

                foreach ($k in @($cmdParams.Keys)) {
                    if (-not $command.Parameters.ContainsKey($k)) {
                        $cmdParams.remove($k)# = $p.Value
                    }
                }
                    


                $cmdResult = & $command @cmdParams
                

                if ($cmdResult -as [xml]) {
                    $xml = ($cmdResult -as [xml])
                    if ($xml.Response) {
                        $responseXml += $xml.Response.InnerXml
                    } else {
                        $responseXml += $xml.InnerXml
                    }                    
                } elseif ($cmdResult -like "http*") {
                    if ($cmdResult -like "*.mp3") {
                        $responseXml += "<Play>$([Security.SecurityElement]::Escape($cmdResult))</Play>"
                    } elseif ($cmdResult -like "*.wav") {
                        $responseXml += "<Play>$([Security.SecurityElement]::Escape($cmdResult))</Play>"
                    } else {
                        $responseXml += "<Redirect>$([Security.SecurityElement]::Escape($cmdResult))</Redirect>"
                    }                     
                    
                } else {
                
                    $responseXml += "<Say>$([Security.SecurityElement]::Escape($cmdResult))</Say>"
                }


                
            } else {
                $parameterInfo = $order[$parameterNumber]
                $parameterInfo = $Command.Parameters[$parameterInfo] 
                $parameter = $parameterInfo.Name
                $parameterType = $parameterInfo.ParameterType

                # Combine the parameters here, so we can send the handler back to the right spot with all of the data intact
                $ParameterData = 
                    if ($parameterValues.Count) {                    
                        for ($pN = 0; $pn -le $parameterValues.Count; $pn++) {
                            "P$PN=$([web.httputility]::UrlEncode($parameterValues[$pn]))"
                    
                        }
                    } else {
                        ""
                    }
                

                $ParameterData = $ParameterData -join "&"

                $actionUrl = 
                    if ($fullUrl.Contains("ParameterNumber=")) {
                        # Replacing an existing parameter data
                        $fullUrl ="$fullUrl".substring(0,"$fullUrl".IndexOf("ParameterNumber=") -1)
                        if ($fullUrl.ToString().Contains("?")) {
                            $fullUrl + "&ParameterNumber=$ParameterNumber&${ParameterData}"
                        } else {                        
                            "$fullUrl".TrimEnd("/") + "/" + "?ParameterNumber=$ParameterNumber&${ParameterData}"
                        }
                    } elseif ($fullUrl.ToString().Contains("?")) {
                        $fullUrl + "&ParameterNumber=$ParameterNumber&${ParameterData}"
                    } else {                        
                        "$fullUrl".TrimEnd("/") + "/" + "?ParameterNumber=$ParameterNumber&${ParameterData}"
                    }


                


                
                # Request input for the parameter.  
                $parameterInfo = $order[$parameterNumber]
                
                $paramInput = Request-CommandInput -Platform TwilML -CommandMetaData $cmdMd -AllowedParameter $parameter -Action $actionUrl -DenyParameter $HideParameter

                if ($paramInput -as [xml]) {
                    $responseXml +=  ($paramInput -as [xml]).Response.innerXml
                }
                
    
            }

            
            # If the parameter is a Number, have them enter it in on the keypad.

                
            # If the parameter is text, and named Recording* or *Recording, then record

            # If the parameter is text, and named Trascribe* or *Transcript, then transcribe

            # Otherwise, transcribe

            # If the parameter is a PSObject, pass in the whole recording or transcription object

                

                
                
                
            #$responseXml += "<Play>$([Security.SecurityElement]::Escape($ActionUrl))</Play>"
                                                         
                
                
            if ($callStatusCookie) {
                $response.Cookies.Add($callStatusCookie)                    
            }
            $responseXml += "</Response>"
                
            $strWrite = New-Object IO.StringWriter
            ([xml]$responseXml).Save($strWrite)
            $resultToOutput  = "$strWrite" -replace "encoding=`"utf-16`"", "encoding=`"utf-8`""
            if (-not $cmdOptions.ContentType) {
                $response.ContentType ="text/xml"
            }
            $response.Write("$resultToOutput")    
                
                
        } elseif ($requestParameterNames."DownloadProxy") {
            # Start with the core command, 
            . $getProxyCommand
            
if ($Request["AsHtml"]) {
$webPage = Write-ScriptHtml ([ScriptBlock]::create($proxyCommandText)) 
$webPage
} elseif ($request["AsBase64"]) {
$b64 = [Convert]::ToBase64String(([Text.Encoding]::Unicode.GetBytes($proxyCommandText)))
    $response.ContentType = "text/plain"
    $response.Write($b64)
    $response.Flush()

} else {
    #$proxyCommandText
    $response.ContentType = "text/plain"
    $response.Write($proxyCommandText)
    $response.Flush()
}
            
        } else  {            
            # Normal command handler
        
        
        
        
            # If they want a link to run the command, instead of actually running it...
            if ($Request -and ($Request['GetLink'] -or $request['-GetLink'])) {
                # Get a link
                $response.contentType = 'text/plain'
                $responseString = $request.Url.ToString()
                if ($responseString.Contains('?')) {
                    $responseString = $responseString.Substring(0, $responseString.IndexOf("?"))
                }
                $responseString+='?'
                foreach ($cp in $commandParameters.GetEnumerator()) {
                    $b64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cp.Value))
                    $responseString +="$($CmdMd.Name)_$($cp.Key)=${b64}&"
                }
                $responseString
                return
            }
            
            # If -Bare/Bare was specified, then do not output anything but the result
            if ($Request -and (($request['Bare'] -ilike "$true") -or ($request['-Bare'] -ilike "$true"))) {
                $cmdoptions.PlainOutput = $true
            }     

            $result = $null
       
            $runAnyways = ($request -and (
                $request["RunItAnyway"] -or 
                $request["RunItAnyways"] -or 
                $request["RunAnyway"] -or 
                $request["RunAnyways"]))
            
            if ($cmdOptions.runWithoutInput -or 
                ($CommandParameters.Count -gt 0) -or 
                $runAnyways) {                    
                if ($cmdOptions.RequireAppKey) {
                    $appKey = if ($session['User'].SecondaryApiKey -and 
                        -not $request['AppKey']) {
                        $session['User'].SecondaryApiKey
                    } elseif ($request['AppKey']) {
                        $request['AppKey']
                    } else {
                        Write-Error "App Key is Required.  The user must be logged in, or a parameter named AppKey must be passed with the request"
                        return
                    }
                    
                    Confirm-Person -ApiKey $appKey -StorageAccountSetting $storageAccountSetting -StorageKeySetting $storageKeySetting -WebsiteUrl $serviceUrl
        
                    <#
                    $storageAccount = Get-WebConfigurationSetting -Setting $cmdOptions.StorageAccountSetting
                    $storageKey = Get-WebConfigurationSetting -Setting $cmdOptions.StorageKeySetting
                    $userTableExists = Get-AzureTable -TableName $cmdOptions.UserTable -StorageAccount $storageAccount -StorageKey $storageKey
                    if (-not $userTableExists) { 
                        return
                    }
        
        
                    $userExists = Search-AzureTable -TableName $cmdOptions.UserTable -Filter "PartitionKey eq '$($cmdOptions.UserPartition)' and SecondaryApiKey eq '$appKey'"
                    if (-not $UserExists) {
                        Write-Error "User not found"
                        return
                    }
                    #>                
                } elseif ($cmdOptions.RequireLogin) {
                    $confirmHtml = Confirm-Person -WebsiteUrl $serviceUrl                
                    if ($session["User"]) {
                        $userExists = $session['User']
                    } else {
                        if ($confirmHtml) {
                            $confirmHtml
                        }
                        return
                    }
                
                }
    
    
                # There are parameters, or the command knows it can run without them.

                # First, clear out empty parameters from the structure
                if ($mergedParameters.Count) {
                    $toRemove = @()
                    foreach ($kv in $mergedParameters.GetEnumerator()) {
                        if (-not $kv.Value -and ($kv.Value -ne 0)) { 
                            $toRemove += $kv.Key 
                        } 
                    }
                    foreach ($to in $toRemove) {
                        $null = $mergedParameters.Remove($to)
                    }
                }                    
         
                # Then, Enforce the Session Throttle       
                $doNotRunCommand = $true
                if ($cmdOptions.SessionThrottle.TotalMilliseconds) {
                    if (-not $session["$($cmdMd.Name)_LastRun"]) {
                        $session["$($cmdMd.Name)_LastRun"] = Get-Date
                        $doNotRunCommand = $false
                    } elseif (($session["$($cmdMd.Name)_LastRun"] + $cmdOptions.SessionThrottle) -lt (Get-Date)) {
                        $session["$($cmdMd.Name)_LastRun"] = Get-Date
                        $doNotRunCommand = $false
                    } else {
                        $timeUntilICanRunAgain = (Get-Date) - ($session["$($cmdMd.Name)_LastRun"] + $cmdOptions.SessionThrottle)
                        "<span style='color:red'>Can run the command again in $(-$timeUntilICanRunAgain.TotalSeconds) Seconds</span>"
                        $doNotRunCommand = $true
                    }        
                } else {
                    $doNotRunCommand = $false
                }


                if ($mergedParameters.Count -gt 0 -or $psBoundParameters.RunWithoutInput) {
                
                }

       
                # Default behavior, do not cache
                if (-not $doNotRunCommand) {                       
                    # Run the command 
                    $useId = [GUID]::NewGuid()
                    if ($cmdOptions.ModeratedBy -and $cmdOptions.ExecutionQueueTable) {
                        # If the command was moderated, 'running' the command is really putting 
                        # the parameters into table storage for someone to approve
                        $subject = "Would you like to run $($cmdMd.Name)?"
                        $confirmId = $useId
                        $pendingExecutionRequest = New-Object PSObject -Property $commandParameters
                        $requestAsString = $request.Url.ToString()
                        $serviceUrl = $requestAsString.Substring(0,$requestAsString.LastIndexOf("/"))
                    
                        $canReply = if ($session['User'].UserEmail) {
                            "<a href='$serviceUrl?sendreply=$confirmId'>Reply</a>"
                        } else {
                            ""
                        }
                
                
                        $message = "
$userInfo has requested that you run $($cmdMd.Name) with the following parameters:

$($pendingExecutionRequest | Out-HTML) 

               
<a href='${finalUrl}?confirm=$confirmId'>Run this</a>
<a href='${finalUrl}?deny=$confirmId'>Don't run this</a>
$canReply
"

                        $smtpEmail = Get-SecureSetting $cmdOptions.SmtpEmailSetting -ValueOnly
                        $smtpPassword = Get-SecureSetting $cmdOptions.SmtpPasswordSetting -ValueOnly
                        $smtpCred = New-Object Management.Automation.PSCredential ".\$smtpEmail", "$(ConvertTo-SecureString -AsPlainText -Force $smtpPassword)"
                        Send-MailMessage -To $cmdOptions.ModeratedBy -UseWebConfiguration -Subject $subject -Body $Message -BodyAsHtml -AsJob                
                
                
                        $pendingExecutionRequest | 
                            Set-AzureTable -TableName $cmdOptions.ExecutionQueueTable -PartitionKey $cmdMd.Name -RowKey $useId
                
                        $result = "Your request has been sent to the moderator"                                                                            
                    } elseif (($PayNow -or $SubscribeNow) -and ($Request -and $Request["Confirmed"])) {
                        # Calculate total payment and present with a bill and a pay now link.  When the payment is processed the command will be run
                        . $ComputeTotalCost
                                     
                        
                                  
                        $confirmLink = "$serviceUrl".Substring(0, "$serviceUrl".LastIndexOf("/")) + "/" + $Command + "/" 

                        if ($confirmLink.Contains("?")) {
                            $confirmLink += "&"
                        } else {
                            $confirmLink = $confirmLink.TrimEnd("/") + "/?"
                        }

                        $costString = "$" + $totalCost

                        $parameterConfirm = "
<span style='font-size:2em'>Are you sure you'd like to $($FriendlyName)?.  It will cost $costString .</span>                        
                        "
                        $parameterConfirm += "<div style='margin-left:auto;margin-right:auto;width:66%'>
                        <table style='align:center'>
                            <tr>
                            <th style='font-size:1.6em;width:50%'>
                                Option
                            </th>
                            <th style='font-size:1.6em;width:50%'>
                                Value
                            </th>
                        </tr>"
                        foreach ($pValue in $commandParameters.GetEnumerator()) {
                            if (-not $pValue) { continue }
                            $confirmLink += "&$($Command)_$($pValue.Key)=$([Web.HttpUtility]::UrlEncode($pValue.Value))"
                            $parameterConfirm += "<tr><td><b>$($pValue.Key)</b><td><td>$($pValue.Value | Out-HTML)</td></tr>"
                        }

                        $confirmLink += "&Confirmed=true"

                        $parameterConfirm +="</table></div>"
                        $parameterConfirm += Write-Link -Url $confirmLink -Caption "OK" -Style @{'font-size' = '2.5em';float='right'} 
                        
                        $parameterConfirm | New-WebPage | Out-HTML -WriteResponse 
                        return
                        
                    } elseif ((($PayNow -or $SubscribeNow) -and (-not ($Request -and $request["Confirmed"])))) {
                        # Prompting for a pay link if -AsEmail is not provided.  

                        
                        . $ComputeTotalCost


                        

                        $postPaymentCommand = $Command
                        $session["PostPaymentCommand"] = $postPaymentCommand
                        $session["PostPaymentParameter"] = $PostPaymentParameter = 
                            Write-PowerShellHashtable -InputObject $CommandParameters

                        #$PostPaymentParameter  = [Web.HttpUtility]::UrlEncode($PostPaymentParameter)
                        $payLink = 
                            if ($paynow) {
                                "Purchase"
                            } elseif ($SubscribeNow) {
                                "Rent"
                            } 
                        $payUrl  = $ServiceUrl.ToString() + "?$payLink=True&ItemName=$Command&ItemPrice=$TotalCost&$(if ($SubscribeNow) { "BillingFrequency=$BillingFrequency" })"
                        
                        
                        #$PostPaymentParameter,$postPaymentCommand = $null
                        $userPart = if ($pipeworksManifest.UserTable.Partition) {
                            $pipeworksManifest.UserTable.Partition
                        } else {
                            "Users"
                        }
            
                        $purchaseHistory = $userPart + "_Purchases"
            
                        
                        $azureStorageAccount = Get-SecureSetting -Name $pipeworksManifest.UserTable.StorageAccountSetting -ValueOnly
                        $azureStorageKey= Get-SecureSetting -Name $pipeworksManifest.UserTable.StorageKeySetting -ValueOnly

                        $purchase = @()
                        $payLinks = ""
                        $fullPayLink = ""
                        if (-not $listOfCosts) {
                            $itemPrice = $TotalCost
                            $purchaseId = [GUID]::NewGuid()
            
            
                            $newpurchase = New-Object PSObject
                            $newpurchase.pstypenames.clear()
                            $newpurchase.pstypenames.add('http://shouldbeonschema.org/ReceiptItem')
                            $itemNAme = $FriendlyName
                            $Currency = if ($cmdOptions.Currency) {
                                $cmdOptions.Currency
                            } else {
                                "USD"
                            }
            
                            $newpurchase  = $newpurchase |
                                Add-Member NoteProperty PurchaseId $purchaseId -PassThru |
                                Add-Member NoteProperty ItemName $itemName -PassThru |
                                Add-Member NoteProperty ItemPrice $itemPrice -PassThru |
                                Add-Member NoteProperty Currency $currency -PassThru |                            
                                Add-Member NoteProperty OrderTime $request["OrderTime"] -PassThru
                        
                            if ($session["User"]) {
                                $newpurchase = $newpurchase | 
                                    Add-Member NoteProperty UserID $session["User"].UserID -PassThru
                            }
                            $isRental = if ($SubscribeNow) {
                                $true
                            } else {
                                $false
                            }

                            $newpurchase = $newpurchase | 
                                Add-Member NoteProperty IsRental $isRental -Force -PassThru

                            

                            if ($postPaymentCommand) {
                                $newpurchase  = $newpurchase  |
                                    Add-Member NoteProperty PostPaymentCommand $postPaymentCommand -PassThru
                            }

                            if ($PostPaymentParameter) {
                                $newpurchase = $newpurchase  |
                                    Add-Member NoteProperty PostPaymentParameter $PostPaymentParameter -PassThru
                            }

                            

                            $newpurchase | 
                                    Set-AzureTable -TableName $pipeworksManifest.UserTable.Name -PartitionKey $purchaseHistory -RowKey $purchaseId -StorageAccount $azureStorageAccount  -StorageKey $azureStorageKey
            
                            
                            $payLinks = ""
                            $payLinks += 
                                if ($pipeworksManifest.PaymentProcessing.AmazonPaymentsAccountId -and 
                                    $pipeworksManifest.PaymentProcessing.AmazonAccessKey) {
                                    $newpurchase | 
                                        Write-Link -AmazonPaymentsAccountId $pipeworksManifest.PaymentProcessing.AmazonPaymentsAccountId -AmazonAccessKey $pipeworksManifest.PaymentProcessing.AmazonAccessKey
                                }
                
            
                            $payLinks += 
                                if ($pipeworksManifest.PaymentProcessing.PaypalEmail) {                                        
                                    Write-Link -ItemName $itemName -Currency $currency -ItemPrice $itemPrice -PaypalEmail $pipeworksManifest.PaymentProcessing.PaypalEmail -PaypalIPN "$ServiceUrl/?-PaypalIPN" -PaypalCustom $PurchaseId -Subscribe:$isRental -BillingFrequency $BillingFrequency 
                                }                            


                            $payLinks += 
                                if ($pipeworksManifest.PaymentProcessing.BuyCodeHandler) {
                                    $newpurchase | 
                                        Write-Link -BuyCodeHandler $pipeworksManifest.PaymentProcessing.BuyCodeHandler -Subscribe:$isRental
                                }

                            $fullPayLink += "                                                    
                            <span style='font-size:1.3em'>$itemName</span>
                            <br/>
                            <span style='font-size:1.1em'>$itemPrice $currency $(if ($SubscribeNow) { " $BillingFrequency"})</span>
                            <br/>
                        
                            $($payLinks| Out-HTML)"

                            
                        } else {
                            $lc = 0 
                            foreach ($loc in $listOfCosts) {
                                $itemPrice = $loc
                                $purchaseId = [GUID]::NewGuid()
            
            
                                $newpurchase = New-Object PSObject
                                $newpurchase.pstypenames.clear()
                                $newpurchase.pstypenames.add('http://shouldbeonschema.org/ReceiptItem')
                                $itemNAme = $FriendlyName
                                    
                                $TheCurrency = if ($cmdOptions.Currency -and $cmdOptions.Currency.Count -ge $lc) {
                                    $cmdOptions.Currency[$lc]
                                } else {
                                    $Currency[0]
                                }

                                $TheBillingFrequency= if ($cmdOptions.BillingFrequency -and $cmdOptions.BillingFrequency.Count -ge $lc) {
                                    $cmdOptions.BillingFrequency[$lc]
                                } else {
                                    $BillingFrequency[0]
                                }
                                    
            
                                $newpurchase  = $newpurchase |
                                    Add-Member NoteProperty PurchaseId $purchaseId -PassThru |
                                    Add-Member NoteProperty ItemName $itemName -PassThru |
                                    Add-Member NoteProperty ItemPrice $itemPrice -PassThru |
                                    Add-Member NoteProperty Currency $TheCurrency -PassThru |                                                                
                                    Add-Member NoteProperty BillingFrequency $TheBillingFrequency -PassThru
                        
                                
                                
                                if ($session["User"]) {
                                    $newpurchase = $newpurchase | 
                                        Add-Member NoteProperty UserID $session["User"].UserID -PassThru
                                }
                                $isRental = if ($SubscribeNow) {
                                    $true
                                } else {
                                    $false
                                }

                                $newpurchase = $newpurchase | 
                                    Add-Member NoteProperty IsRental $isRental -Force -PassThru

                            

                                if ($postPaymentCommand) {
                                    $newpurchase  = $newpurchase  |
                                        Add-Member NoteProperty PostPaymentCommand $postPaymentCommand -PassThru
                                }

                                if ($PostPaymentParameter) {
                                    $newpurchase = $newpurchase  |
                                        Add-Member NoteProperty PostPaymentParameter $PostPaymentParameter -PassThru
                                }

                                $purchase += $newpurchase

                                $itemPrice = $newpurchase.ItemPrice
                                $TheCurrency = $newpurchase.Currency
                                
                                $TheBillingFrequency = $newpurchase.BillingFrequency
                                $newpurchase | 
                                    Set-AzureTable -TableName $pipeworksManifest.UserTable.Name -PartitionKey $purchaseHistory -RowKey { $_.purchaseId } -StorageAccount $azureStorageAccount  -StorageKey $azureStorageKey
            
                            
                                $payLinks = ""
                                $payLinks += 
                                    if ($pipeworksManifest.PaymentProcessing.AmazonPaymentsAccountId -and 
                                        $pipeworksManifest.PaymentProcessing.AmazonAccessKey) {
                                        $newpurchase | 
                                            Write-Link -AmazonPaymentsAccountId $pipeworksManifest.PaymentProcessing.AmazonPaymentsAccountId -AmazonAccessKey $pipeworksManifest.PaymentProcessing.AmazonAccessKey
                                    }
                
            
                                $payLinks += 
                                    if ($pipeworksManifest.PaymentProcessing.PaypalEmail) {                                        
                                        Write-Link -ItemName $itemName -Currency $TheCurrency -ItemPrice $itemPrice  -PaypalEmail $pipeworksManifest.PaymentProcessing.PaypalEmail -PaypalIPN "$ServiceUrl/?-PaypalIPN" -PaypalCustom $PurchaseId -Subscribe:$isRental -BillingFrequency:$TheBillingFrequency 
                                    }


                                $payLinks += 
                                    if ($pipeworksManifest.PaymentProcessing.BuyCodeHandler) {
                                        $newpurchase | 
                                            Write-Link -BuyCodeHandler $pipeworksManifest.PaymentProcessing.BuyCodeHandler -Subscribe:$isRental
                                    }
                                $lc++
                                $fullPayLink += "                                                                                
                            <span style='font-size:1.3em'>$itemName</span>
                            <br/>
                            <span style='font-size:1.1em'>$itemPrice $Thecurrency $(if ($SubscribeNow) { " $TheBillingFrequency"})</span>
                            <br/>
                        
                            $($payLinks| Out-HTML)"


                            }
                        }
            
                        

                        if ($cmdOptions.PaymentProcessed) {
                            try {
                            
                                if ($request -and ($Request["OutputParameter"] -eq 'true')) {
                                    $result = $mergedParameters 
                                } else {
                                
                                    $result = & $command @mergedParameters -ErrorVariable AnyProblem
                                    
                                }

                                return ($result | Out-HTML)

                            
                            } catch {
                                $commandError = $_
                        
                            }   
                        } else {
                            return $fullPayLink
                
                            
                        }
                        
                    } elseif ($promptForConfirmation -and -not $request["Confirmed"]) {
                        # Prompt for the person's confirmation
                        $confirmLink = "$fullUrl"

                        if (-not $ConfirmationMessage) {
                            $ConfirmationMessage= "Are you sure you'd like to $($FriendlyName)?."
                        } 
                        $parameterConfirm = "
<span style='font-size:2em'>$ConfirmationMessage</span>                        
                        "
                        $parameterConfirm += "<div style='margin-left:auto;margin-right:auto;width:66%'>
                        <table style='align:center'>
                            <tr>
                            <th style='font-size:1.6em;width:50%'>
                                Option
                            </th>
                            <th style='font-size:1.6em;width:50%'>
                                Value
                            </th>
                        </tr>"
                        foreach ($pValue in $commandParameters.GetEnumerator()) {
                            if (-not $pValue) { continue }
                            $confirmLink += "&$($Command)_$($pValue.Key)=$([Web.HttpUtility]::UrlEncode($pValue.Value))"
                            $parameterConfirm += "<tr><td><b>$($pValue.Key)</b><td><td>$($pValue.Value | Out-HTML)</td></tr>"
                        }

                        $confirmLink += "&Confirmed=true"

                        $parameterConfirm +="</table></div>"
                        $parameterConfirm  += Write-Link -Url $confirmLink -Caption "OK" -Style @{'font-size' = '2.5em';float='right';margin='100px'} 

                        
                        
                        $parameterConfirm | New-WebPage | Out-HTML -WriteResponse 
                        return

                    } else {
                        $anyProblem = ""
                        $commandError  = $null                                        
                        
                        try {
                            
                            if ($request -and ($Request["OutputParameter"] -eq 'true')) {
                                $result = $mergedParameters 
                            } else {
                                
                                $result = & $command @mergedParameters -ErrorVariable AnyProblem
                            }

                            
                        } catch {
                            $commandError = $_

                            if ($manifestIsTemporary) {
                                return
                            }
                            return $commandError
                        
                        }
                    }                        
            
                 
                    $worked = $?
                    $cmdresult = $result
            

                    $commandWasRun = $true
                        
                    # If it worked, charge them 
                    if ($worked -and $userExists -and ($cmdOptions.Cost -or $cmdOptions.CostFactor)) {
                        $userRecord = Search-AzureTable -TableName $cmdOptions.UserTable -Filter "PartitionKey eq '$($cmdOptions.UserPartition)' and RowKey eq '$($userExists.UserId)'" 

                        if ($cmdOptions.Cost -and -not $PaymentProcessed) {
                            # If there was a fixed cost, apply this cost to the user
                            $balance = 
                                $userRecord.Balance -as [Double]
                        
                        
                            $balance += $cmdOptions.Cost -as [Double]
                            $userRecord  |
                                Add-Member NoteProperty Balance $balance -Force -PassThru |                        
                                Update-AzureTable -TableName $cmdOptions.UserTable -Value { $_ } 
                        }
                
                        if ($cmdOptions.CostFactor -and -not $PaymentProcessed) {
                            $factoredCost = 0
                        
                            foreach ($kv in $cmdOptions.CostFactor.getEnumerator()) {                        
                            
                                $parameterValue = $mergedParameters["$($kv.Value.Parameter)"]
                                if ($kv.Value.CostMap) {
                                    $factoredCost += $kv.Value.CostMap[$parameterValue]
                                } elseif ($kv.Value.CostPerValue) {
                                    $factoredCost += $kv.Value.CostPerValue * $parameterValue
                                }
                            
                            }

                            # If there was a fixed cost, apply this cost to the user
                            $balance = 
                                $userRecord.Balance -as [Double]
                            if (-not $balance) {
                                $balance = 0
                            } 
                            $balance += $factoredCost
                            $userRecord |
                                Add-Member NoteProperty Balance $balance -Force -PassThru |                        
                                Update-AzureTable -TableName $cmdOptions.UserTable -Value { $_ }
                        }
                
                
                    }
            
            
            
                # Immediately track its use before it is rendered, if the cmdoptions say so
                if ($cmdOptions.UseTrackingTable) {
                    $storageAccount = Get-WebConfigurationSetting -Setting $cmdOptions.StorageAccountSetting
                    $storageKey = Get-WebConfigurationSetting -Setting $cmdOptions.StorageKeySetting
                    $trackingTable = Get-AzureTable -TableName $cmdOptions.UseTrackingTable -StorageAccount $storageAccount -StorageKey $storageKey
                    if (-not $trackingTable) { 
                        return
                    }
                
                
                    $useInfo = New-Object PSObject -Property @{
                        UseId = $useID
                        Worked = $worked
                    }                    
                    
                    
                    if (-not $worked) {
                        $ht = Write-PowerShellHashtable -InputObject $commandParameters
                        $useInfo | Add-Member NoteProperty Parameters $ht -Force
                    }
                    if ($session['User'].UserId) {
                        $useInfo | Add-Member NoteProperty UserId $session['User'].UserId -Force
                    }
                    
                    if ($appKey) {
                        $useInfo | Add-Member NoteProperty AppKey $appKey -Force
                    }
                    

                    
                    
                    
                    $useInfo | 
                        Set-AzureTable -TableName $cmdoptions.UseTrackingTable -PartitionKey "$($cmdMd.Name)_TimesUsed" -RowKey $useId
                    
                    if ($cmdOptions.TrackProperty) {
                        $result | 
                            Select-Object $cmdOptions.TrackProperty |
                            ForEach-Object { $_.psobject.properties } |
                            ForEach-Object {
                                $propName = $_.Name
                                $md5 = [Security.Cryptography.MD5]::Create()
                                $content = [Text.Encoding]::Unicode.GetBytes(("$($_.Value)"))
                                $part = [BitConverter]::ToString($md5.ComputeHash($content))
                                $useInfo |
                                    Set-AzureTable -TableName $cmdoptions.UseTrackingTable -PartitionKey "$($cmdMd.Name)_$($propName)_${Part}" -RowKey $useID
                            }
                    }
                                                                
                
                    if ($cmdOptions.TrackParameter) {
                        New-Object PSObject -Property $commandParameters |                    
                            Select-Object $cmdOptions.TrackParameter |
                            ForEach-Object { $_.psobject.properties } |
                            ForEach-Object {
                                $propName = $_.Name
                                $md5 = [Security.Cryptography.MD5]::Create()
                                $content = [Text.Encoding]::Unicode.GetBytes(("$($_.Value)"))
                                $part = [BitConverter]::ToString($md5.ComputeHash($content))
                                $useInfo |
                                    Set-AzureTable -TableName $cmdoptions.UseTrackingTable -PartitionKey "$($cmdMd.Name)_$($propName)_Input_${Part}" -RowKey $useID
                            }
                    }
                    
                    if ($cmdOptions.KeepResult -and $result) {
                        if ($session['User'].UserId) {
                            $result | Add-Member NoteProperty __UserId $session['User'].UserId -Force
                        }
                        
                        if ($appKey) {
                            $result | Add-Member NoteProperty __AppKey $appKey -Force
                        }
                        
                        $result | 
                            Add-Member NoteProperty __UseId $useId -Force
                            
                        $result |
                            Set-AzureTable -TableName $cmdoptions.UseTrackingTable -PartitionKey "$($cmdMd.Name)_Results" -RowKey $useID
                    }
                
                
                    if ($cmdOptions.KeepUserHistory) {
                        $ht = Write-PowerShellHashtable -InputObject $commandParameters 
                        $md5 = [Security.Cryptography.MD5]::Create()
                        $content = [Text.Encoding]::Unicode.GetBytes(("$($ht)"))
                        $part = [BitConverter]::ToString($md5.ComputeHash($content))
                        New-Object PSObject -Property @{
                            UseId = $useID
                            CompressedInput = Compress-Data -String $ht
                        }
                        $useInfo |
                            Set-AzureTable -TableName $cmdoptions.UseTrackingTable -PartitionKey "$($cmdMd.Name)_$($propName)_Input_${Part}" -RowKey $useID
                    }
                
                
                    if ($cmdOptions.KeepHistory) {                    
                        $ht = Write-PowerShellHashtable -InputObject $commandParameters 
                        $md5 = [Security.Cryptography.MD5]::Create()
                        $content = [Text.Encoding]::Unicode.GetBytes(("$($ht)"))
                        $part = [BitConverter]::ToString($md5.ComputeHash($content))
                        New-Object PSObject -Property @{
                            UseId = $useID
                            CompressedInput = Compress-Data -String $ht
                            CompressedResult = Compress-Data -String ($result | ConvertTo-Xml) 
                        }
                    }
                    
                    
                    
                                                    
                }

                if (-not $result -and $NoOutputMessage) {
                    $result = $NoOutputMessage
                } else {
                    if ($OutputProperty) {
                        $result = $result | Select-Object $OutputProperty
                    }

                }    


                if ($LinkTo) {
                    $result = foreach ($r in $result) {
                        if (-not $r) { continue }
                        foreach ($lt in $linkTo.GetEnumerator()) {
                            # The key of the link is the command / parameter, and the value is the property, for instance:
                            # @{"Get-Employee/RowKey" = "Row"} 
                            
                            if ($r.psobject.properties.($lt.Value)) {
                                $propCaption = $r.($lt.Value)
                                $moduleUrlRoot = $ServiceUrl.ToString().Substring(0, $ServiceUrl.ToString().LastIndexOf("/"))
                                $link = 
                                    if ($lt.Key -like "*/*") {
                                        $cmdName ,$paramName = $lt.Key -split "/"
                                        "$moduleUrlRoot/$cmdName/?$($cmdname)_$($paramName)=$($r.($lt.Value))"
                                    } else {
                                        $cmdName = $lt.Key
                                        "$moduleUrlRoot/$cmdName/$($lt.Key)"
                                    }

                                

                                $linkHtml = Write-Link -Caption $propCaption -Url $link

                                
                                Add-Member -InputObject $r -Name $lt.Value -MemberType NoteProperty -Value $linkHtml  -Force
                            }
                        }
                        $r

                    }                    
                }
                
                if ($AsTypename) {
                    $result = foreach ($r in $result) {
                        if (-not $r) { continue }
                        $r.pstypenames.clear()
                        $R.pstypenames.add($AsTypename)
                        $r
                    }

                }            
                                    
                if ($Request -and (($request['AsXml'] -eq $true) -or ($request['-AsXml'] -eq $true))) {
                    $response.contentType = 'text/xml'
                    $result = [string]($result | ConvertTo-Xml -as String)
                    $response.Write("$result     ")                                        
                    return 
                }
            
                if ($Request -and (($request['AsCsv'] -eq $true) -or ($request['-AsCsv'] -eq $true))) {
                    $response.contentType = 'text/csv'
                    $csvFile = [io.path]::GetTempFileName() + ".csv"
                    $result | Export-Csv -Path $csvFile                                 
                    $response.Write("$([IO.File]::ReadAllText($csvFile))")                                        
                    Remove-Item -Path $csvFile -ErrorAction SilentlyContinue 
                    return 
                }
                if ($Request -and (($request['AsJson'] -eq $true) -or ($request['-AsJson'] -eq $true))) {
                    if ($PSVersionTable.PSVersion -ge '3.0') {
                        $response.ContentType -eq 'application/json'
                        $response.Write("$($result | ConvertTo-Json)")                    
                        
                        return
                    } else {
                        throw "Not PS v3 or greater"
                    }
                }
                
                                             
                # $result | Out-HTML -Id "${CommandId}Output" -Escape:$escape                                        
                if ($Request -and (($request['AsRss'] -eq $true) -or ($request['-AsRss'] -eq $true))) {
                    $response.contentType = 'text/xml'
                    
                    $requestAsString = $request.Url.ToString() 
                    $pageUrl = $requestAsString  -ireplace "AsRss=true", ""
                    $pageUrl = $pageUrl.TrimEnd("&")
                    $shorturl = $requestAsString.Substring(0, $requestAsString.IndexOf("?"))
                    $description = (Get-Help $command.Name).Description
                    if ($description) {
                        $description = $description[0].text.Replace('"',"'").Replace('<', '&lt;').Replace('>', '&gt;').Replace('$', '`$')
                    }
                                
                    $getDateScript = {
                        if ($_.DatePublished) {
                            [DateTime]$_.DatePublished
                        } elseif ($_.TimeCreated) {
                            [DateTime]$_.TimeCreated
                        } elseif ($_.TimeGenerated) {
                            [DateTime]$_.TimeGenerated
                        } elseif ($_.Timestamp) {
                            [DateTime]$_.Timestamp
                        } else {
                            Get-Date
                        }
                    }
                
                    # DCR: Make RSS support multiple results
                    $resultFeed = 
                        $result | 
                            Sort-Object $getDateScript  -Descending | 
                            New-RssItem -DatePublished $getDateScript  -Author { 
                                if ($_.Author) { $_.Author } else { "$($command.Name)" }
                            } -Link {
                                $pageUrl 
                            } -Title {
                                if ($_.Title) { 
                                    $_.Title 
                                } elseif ($_.Name) { 
                                    $_.Name 
                                } else {
                                    "$($command.Name) - $(Get-Date)"
                                } 
                            } -Description {
                                if ($_.Description) {
                                    $_.Description
                                } elseif ($_.ArticleBody) {
                                    $_.ArticleBody
                                } elseif ($_.Readings) {
                                    $_.Readings | Out-HTML
                                } else {
                                    $_  | Out-HTML
                                }
                            }  |
                            Out-RssFeed -Link $shorturl -Title "$($command.Name)" -Description "$description"                     
                    $response.Write("$resultFeed")                    
                    return 
                } 

                if ($cmdOptions.PlainOutput -or 
                    ($request -and ($request['Bare'] -like "$true")) -or 
                    ($request -and ($request['-Bare'] -like "$true"))) {
                    if ($cmdOptions.ContentType -and $response) {
                        $response.ContentType = $cmdOptions.ContentType
                    }
                    $resultAsBytes = $result -as [Byte[]]
                    if ($resultAsBytes) {                    
                        if ($response) {
                            # If the result was a set of bytes, flush them all as one so that the handler can produce a complex content type.
                            $response.BufferOutput = $true
                            $response.BinaryWrite($resultAsBytes )
                            $response.Flush()
                        } else {
                            $resultAsBytes
                        }
                    } else {
                        # If the result is an XmlDocument, then render it as XML.
                        if ($result -is [xml]) {
                            $strWrite = New-Object IO.StringWriter
                            $result.Save($strWrite)
                            $result  = "$strWrite"
                            # And, if the content type hasn't been set, set the content type
                            $resultToOutput  = "$strWrite" -replace "encoding=`"utf-16`"", "encoding=`"utf-8`""
                            if (-not $cmdOptions.ContentType) {
                                $response.ContentType ="text/xml"
                                $response.write($resultToOutput)
                            }                            
                        } else {
                            if ($cmdOptions.ContentType -and $commandWasRun -and $worked -and (-not $inputWasRequested) -and $response) {
                                $response.ContentType =$cmdOptions.ContentType
                                $response.write($result)
                            } else {
                                # The normal output, with plain output
                                $result
                            }
                            
                        }

                        
                    }

                    if ($manifestIsTemporary) {
                        $global:pipeworksManifest = $null 
                    }
                    
                    return
                }  
                                            
                


            if ($cmdOptons.showCode) {                
                $result | Out-HTML 
                "
                $([Security.SecurityElement]::Escape($result))
                <hr/>
                Code
                <br/>
                <textarea cols='80' rows='30'>$([Security.SecurityElement]::Escape($result))</textarea>"                
            } 
            
            
            if ($result) {
                # Output page                


                # If there's a content type, and the output is that content type, then we want to write the output directly.
                # This makes services that create images or other files possible



                if ($cmdOptions.ContentType -and $commandWasRun -and $worked -and (-not $inputWasRequested)) {                    
                    $response.ContentType =$cmdOptions.ContentType
                    $response.write($result)                    
                } else {
                    $redirectPart = 
                    if ($RedirectTo -and $result) {
    $redirectHref = "$RedirectTo"
    if( $request["Snug"]) {
        if ($redirectHref.Contains("?")) {
            $redirectHref += "&snug=true"
        } else {
            $redirectHref += "?snug=true"
        }

    }
                        if(-not $RedirectIn) {
                            @"
    <a href='$redirectHref' style='display:none' id='redirectLink'>
    </a>
    <script type="text/javascript">
    setTimeout('document.getElementById("redirectLink").click()', 250)
    </script>
"@
                        } else {
                            @"
    <a href='$redirectHref' style='display:none' id='redirectLink'>
    </a>
    <script type="text/javascript">
    setTimeout('document.getElementById("redirectLink").click()', $($RedirectIn.TotalMilliseconds))
    </script>
"@                 
                        }                
                    } else {
                        ""
                    }
                    if ($request -and $request["Notify"]) {
                        "$($result | Out-Html)
$redirectPart
<script type='text/javascript'>
    if (windows.external != null) {
        windows.external.notify('$($request["Notify"].Replace("'", "''"))');
    }
</script>
"
                    

                    } elseif ($Notify) {
                        "$($result | Out-Html)
$redirectPart
<script type='text/javascript'>
    if (windows.external != null) {
        windows.external.notify('$($notify.Replace("'", "''"))');
    }
</script>
"
                    } else {
                        "$($result | Out-Html)
$redirectPart"
                    }
                }
                
            }   
                                       
                }             
            }            
            
            
            $depthChunk = if ($depth) {
                "../" * $depth
            } else {
                ""
            }

            $useAjax = if ($Request -and $Request["Ajax"]) {
                $true
            }
            if ((-not $result) -or ($commandError -or $validationErrors -or $anyProblem)) {
                $embedded =  $request -and (($Request["Embed"] -ilike "$true") -or ($Request["Bare"] -ilike "$true"))
                $allHiddenParameters =@() + $HideParameter
            
                if ($ParameterDefaultValue) {
                    $allHiddenParameters += $ParameterDefaultValue.Keys
                }
                $useAjax = 
                    if ($pipeworksManifest.NoAjax -or $cmdOptions.NoAjax -or $cmdOptions.ContentType -or $cmdOptions.RedirectTo -or $cmdOptions.PlainOutput) {
                        if ($request -and $request["Ajax"]) {
                            $true
                        } else {
                            $false                            
                            
                        }
                        
                    } else {
                        $true
                    }

                if ($anyProblem -or $validationErrors -or $commandError) {
                    
                    $AnyProblem  = $AnyProblem | ForEach-Object { $_.Message  } | Select-Object -Unique
                    $validationErrors = $validationErrors | ForEach-Object { $_ } 
                    $commandError = $commandError | ForEach-Object { $_ } 


                    $problemsPage=  $AnyProblem, $validationErrors, $commandError -ne $null | 
                        Select-Object -Unique |                         
                        ForEach-Object { "<span class='ui-state-error' style='color:red;padding:15px;margin:10px;font-size:1.33em'>$($_)</span>" }|                        
                        Out-HTML
                                        
                    
                    if (-not $embedded) {
                        $problemsPage = $problemsPage |  
                            New-Region -Style @{} -LayerID CommandOutput

                        $method = "POST"
                        if ($request -and $request["Method"]) {
                            $method = $request["Method"]
                        }

                        $problemsPage += Request-CommandInput -Action "${fullUrl}" -CommandMetaData $Command -DenyParameter $allHiddenParameters  -Method $method -Ajax:$useAjax |
                            New-Region -Style @{} -LayerID CommandInput     
                        $problemsPage  = $problemsPage 
                    }
                    
                    "$problemsPage "
                } else {
                    $method = "POST"
                    if ($request -and $request["Method"]) {
                        $method = $request["Method"]
                    }

                    $inputWasRequested = $true


                    $inputPage = 
                        Request-CommandInput -Action "$fullUrl" -CommandMetaData $Command -DenyParameter $allHiddenParameters -Method $method -Ajax:$useAjax  
                    if (-not $embedded) {    
                        $inputPage = $inputPage |
                            New-Region -Style @{} -LayerID CommandInput 
                        "$inputPage "
                    }
                }
                
            }    
        
        
            if ($manifestIsTemporary) {
                $global:pipeworksManifest = $null 
            }
            return
            
        }
        if ($manifestIsTemporary) {
            $global:pipeworksManifest = $null 
        }        
    }
} 
