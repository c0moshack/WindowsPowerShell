function Send-PhoneCall
{
    <#
    .Synopsis
        Sends phone calls 
    .Description
        Sends phone calls messages with twilio
    .Example
        Send-PhoneCall -From 12065551212 -To 12065551212 -Url http://start-automating.com/Receive-CallToStartAutomating
    .Link
        Twilio.com
    .Link
        Get-PhoneCall
    #>
    param(
    # The Phone Number the text will be sent from
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    $From,
    
    # The Phone Number the text will be sent to
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    $To,
    
    # The body of the text message
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Uri]
    $Url,
    
    # Send digits after connecting
    [string]
    $SendDigit,    
    
    
    # The Twilio credential 
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Management.Automation.PSCredential]
    $Credential,
    
    
    # A setting storing the credential
    [Parameter(ValueFromPipelineByPropertyName=$true)]   
    [string[]]
    $Setting = @("TwilioAccountKey", "TwilioAccountSecret")
    )
    
    process {
        if (-not $Credential -and $Setting) {
            if ($setting.Count -eq 1) {

                $userName = Get-WebConfigurationSetting -Setting "${Setting}_UserName"
                $password = Get-WebConfigurationSetting -Setting "${Setting}_Password"
            } elseif ($setting.Count -eq 2)  {
                $userName = Get-secureSetting -Name $Setting[0] -ValueOnly
                $password= Get-secureSetting -Name $Setting[1] -ValueOnly
            }

            if ($userName -and $password) {                
                $password = ConvertTo-SecureString -AsPlainText -Force $password
                $credential  = New-Object Management.Automation.PSCredential $username, $password 
            } elseif ((Get-SecureSetting -Name "$Setting" -ValueOnly | Select-Object -First 1)) {
                $credential = (Get-SecureSetting -Name "$Setting" -ValueOnly | Select-Object -First 1)
            }
            
            
        }
        if (-not $Credential) {
            Write-Error "No Twilio Credential provided.  Use -Credential or Add-SecureSetting TwilioAccountDefault -Credential (Get-Credential) first"               
            return
        }

        $getWebParams = @{
            WebCredential=$Credential
            Url="https://api.twilio.com/2010-04-01/Accounts/$($Credential.GetNetworkCredential().Username.Trim())/Calls"
            Method="POST"
            UseWebRequest=  $true
            AsXml =$true
            Parameter = @{
                From = $from
                To = $to
                Url = $url
            }
        }
        
        if ($SendDigit) {
            $getWebParams.Parameter.SendDigits = $sendDigit
        }        
        Get-Web @getwebParams -Verbose |
            Select-Object -ExpandProperty TwilioResponse |
            Select-Object -ExpandProperty Call |
            ForEach-Object {
                $_.pstypenames.clear()
                $_.pstypenames.Add('Twilio.Call')
                $_
            }
              
    }       
} 
