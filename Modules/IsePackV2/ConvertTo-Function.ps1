function ConvertTo-Function
{
    [CmdletBinding(DefaultParameterSetName='Name')]
    param(
    [Parameter(ParameterSetName='Name',
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
    [String]
    $Name,

    [Parameter(ParameterSetName='Name',
        ValueFromPipelineByPropertyName=$true)]
    [Switch]
    $ExactMatch,
    
    [Parameter(ParameterSetName='Name',
        ValueFromPipelineByPropertyName=$true)]
    [Switch]
    $MatchCase,

    [Parameter(ValueFromPipeline=$true,
        ParameterSetName='ExternalScriptInfo',
        Mandatory=$true)]
    [Management.Automation.ExternalScriptInfo]
    $ExternalScriptInfo,
    
    [Switch]
    $AsScriptBlock
    )
        
    process {
        if ($psCmdlet.ParameterSetName -eq 'ExternalScriptInfo') {
            $sb = New-Object Text.StringBuilder
            $functionName = $externalScriptInfo.Name.Substring(0, 
                $externalScriptInfo.Name.LastIndexOf("."))
            $null = $sb.AppendLine("function $functionName {")
            foreach ($line in $externalScriptInfo.ScriptContents.Split([Environment]::NewLine)) {
                if (-not $line) { continue } 
                if (-not $line.StartsWith('"@')) {
                    $null = $sb.AppendLine("    $line")
                } else {
                    $null = $sb.AppendLine($line)
                }
            }
            $null = $sb.AppendLine("}")
            if ($AsScriptBlock) { 
                try {
                    [ScriptBlock]::Create($sb) 
                } catch {
                    Write-Error -Message "Could not convert to a function, because the script block could not be parsed" -Exception $_
                }
            } else {
                $sb.ToString()
            }        
        } elseif ($psCmdlet.ParameterSetName -eq 'Name') {
            if ($ExactMatch) {
                Write-Progress "Getting Commands" $Name
            } else {
                Write-Progress "Getting Commands" "Like $Name"
            }
            
            $commands = Get-ChildItem -Filter *.ps1 |
                Where-Object { 
                    if ($ExactMatch) {
                        if ($MatchCase) {
                            $_.Name -ceq $name 
                        } else {
                            $_.Name -eq $name 
                        }
                    } else {
                        if ($MatchCase) {
                            $_.Name -clike $Name
                        } else {
                            $_.Name -like $Name
                        }                        
                    }
                } |
                Get-Command -Name { ".\$($_.Name)" }
            
            if (-not $commands) { 
                Write-Progress "No Commands Found" "Nothing to Convert"
                return
            }
            $commands = @($commands) 
            Write-Progress "Commands Found" "$($commands.Count) Found"
            
            $c = 0
            $perc = $c * 100 / $commands.Count
            
            foreach ($cmd in $commands) {
                Write-Progress "Converting Commands to functions" $cmd.Name -PercentComplete $perc
                
                ConvertTo-Function -AsScriptBlock:$asScriptBlock -ExternalScriptInfo $cmd
            }
        }
    }
}