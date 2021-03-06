function Add-Icicle
{
    <#
    .Synopsis
        Adds an Icicle to the ISE
    .Description
        Adds an icicle to the ISE.  Icicles are mini-apps for the PowerShell ISE.
    .Link
        Import-Icicle
    .Example
        Add-Icicle -Horizontal -Name Clock -Screen { 
            New-Border -Child {
                New-Label "$(Get-Date | Out-String)" -FontSize 24  -FontFamily 'Lucida Console'
            }
        } -DataUpdate { 
            Get-date 
        } -UiUpdate {
            $this.Content.Child.Content = $args | Out-String
        } -UpdateEvery "0:0:1" 
    .Example
        Add-Icicle -Command (Get-Command Get-Process)
    #>
    [CmdletBinding(DefaultParameterSetName='Site')]
    param(
    # The name of the icicle
    [Parameter(ParameterSetName='Command')]
    [Parameter(Mandatory=$true,ParameterSetName='Site',ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true,ParameterSetName='Screen',ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true,ParameterSetName='UpdatedScreen',ValueFromPipelineByPropertyName=$true)]
    [Parameter(Mandatory=$true,ParameterSetName='UpdatedSite',ValueFromPipelineByPropertyName=$true)]
    [string]
    $Name,    

    # The url to display in the icicle
    [Parameter(Mandatory=$true, ParameterSetName='Site',ValueFromPipelineByPropertyName=$true)]
    [Uri]
    $Site,

    # The screen for the icicle
    [Parameter(Mandatory=$true, ParameterSetName='Screen')]
    [Parameter(Mandatory=$true, ParameterSetName='UpdatedScreen')]
    [ScriptBlock]
    $Screen,

    # The command to use for the icicle.  
    # The icicle will collect input for this command and run that command in the main runspace.
    [Parameter(Mandatory=$true, ParameterSetName='Command',ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
    [Management.Automation.CommandMetaData]
    $Command,

    # A list of parameters to hide when displaying the command within an Icicle
    [Parameter(ParameterSetName='Command',ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $HideParameter,


    # The command to use for the icicle.  
    # The icicle will collect input for this command and run that command in the main runspace.
    [Parameter(Mandatory=$true, ParameterSetName='Module', ValueFromPipeline=$true)]
    [Management.Automation.PSModuleInfo]
    $Module,

    # The data update.  This script will be run in the runspace that launched the icicle every UpdateEvery
    [Parameter(Mandatory=$true, ParameterSetName='UpdatedScreen')]
    [ScriptBlock]    
    $DataUpdate,

    # The UI update.  This script will be run in the UI runspace, and can access the results from the dataupdate in $args
    [Parameter(Mandatory=$true, ParameterSetName='UpdatedScreen')]
    [ScriptBlock]
    $UiUpdate,
    
    # The frequency of the update.
    [Timespan]
    [Alias('UpdateFrequency')]
    [ValidateRange("00:00:01", "00:01:00")]
    $UpdateEvery,

    # If set, will not show the icicle when it is created.
    [Switch]
    $DoNotShow,

    # If set, the icicle  will be horizontal.
    [Switch]
    $Horizontal,

    # If set, will remove an existing icicle before adding this one.
    [Switch]$Force,

    # If set, will make a shortcut key for the icicle.  If the first key has a conflict, the next key will be used.
    [string[]]$ShortcutKey,

    # If set, will update the Icicle whenever the files change
    [switch]$UpdateOnFileChange,

    # If set, will update the Icicle whenever an add on is added or removed
    [switch]$UpdateOnAddOnChange
    )
            
    process { 

        #region Create Icicle
        $addonParams = @{
            DisplayName=$Name
            DoNotshow=$DoNotshow
            Force=$Force
        }
        if ($Horizontal) {
            $addonParams["AddHorizontally"] = $true
        } else {
            $addonParams["AddVertically"] = $true
        }
        if ($psCmdlet.ParameterSetName -like "*Screen*") {
            $addonParams.ScriptBlock= $screen
        } elseif ($pscmdlet.ParameterSetName -like "*Site*") {
        
            $addonParams.ScriptBlock = [ScriptBlock]::Create("
            New-WebBrowser  -On_Loaded {
                `$fiComWebBrowser = `$this.GetType().GetField('_axIWebBrowser2', 'Instance,NonPublic')
                if (-not `$fiComWebBrowser) { return } 
    
                `$objComWebBrowser = `$fiComWebBrowser.GetValue(`$this);
                if (-not `$objComWebBrowser) { return } 
        
                
                `$arr = new-Object Object[] 1
                `$arr[0] = `$true
                `$objComWebBrowser.GetType().InvokeMember('Silent', [Reflection.BindingFlags]'SetProperty', `$null, `$objComWebBrowser, `$arr)

            } -Source '$site'            
            ")
            if ($psCmdlet.ParameterSetName -like "*update*") {
                $uiUpdate = {
                    $this.Content.Source = $this.Content.Source
                } 
            }
        } elseif ($pscmdlet.ParameterSetName -eq 'Module') {
            $cmds = @($module.ExportedFunctions.Values) + @($module.ExportedCmdlets.Values)
            $moduleRoot = Split-Path $Module.Path
            if (Test-Path "$moduleRoot\$($module.Name).pipeworks.psd1") {
                # If there's a pipeworks manifest, create Icicles for all entries in WebCommand
                $pipeworksManifestContent = [IO.File]::ReadAllText("$moduleRoot\$($module.Name).pipeworks.psd1")
                $pipeworksManifest = "data { $([ScriptBlock]::Create($pipeworksManifestContent)) }" 
            } else {
                foreach ($cmd in $cmds) {
                    Add-Icicle -command $cmd -DoNotShow
                }
            }
            # Create a horizontal icicle to show each command

        } elseif ($psCmdlet.ParameterSetName -eq 'Command') {
            $psBoundParameters.DisplayName = $Command.Name
            $name = $command.Name    
            $safecommandName = $command.Name.Replace("-", "")
            $addonParams.DisplayName = $command.Name
            $addonParams.ScriptBlock = [ScriptBlock]::Create(@"
$input = . Get-WebInput -Control $this -CommandMetaData $cmds
New-Grid -Rows 1* -RoutedEvent @{
    [Windows.Controls.Button]::ClickEvent = {
        
        try {            
            if (`$_.Source.Name -ne '$($command.Name.Replace("-", "") + "_Invoke")') {
                return
            }
            `$value = Get-ChildControl -Control `$this -OutputNamedControl
            foreach (`$kv in @(`$value.GetEnumerator())) {
                if ((`$kv.Key -notlike "${SafeCommandName}_*")) {
                    `$value.Remove(`$kv.Key)
                }
            }

            foreach (`$kv in @(`$value.GetEnumerator())) {
                if (`$kv.Value.Text) {
                    `$value[`$kv.Key] = `$kv.Value.Text
                } elseif (`$kv.Value.SelectedItems) {
                    `$value[`$kv.Key] = `$kv.Value.SelectedItems
                } elseif (`$kv.Value -is [Windows.Controls.Checkbox] -and `$kv.Value.IsChecked) {
                    `$value[`$kv.Key] = `$kv.Value.IsChecked
                } else {
                    `$value.Remove(`$kv.Key)
                }
            }

            foreach (`$kv in @(`$value.GetEnumerator())) {
                `$newKey = `$kv.Key.Replace("${SafeCommandName}_", "")
                `$newValue = `$kv.Value
                `$value.Remove(`$kv.Key)
                `$value.`$newKey = `$newValue
            }

            `$mainRunspace = [Windows.Window]::getWindow(`$this).Resources.MainRunspace
            if (`$value) {                
                
                
                if (`$mainRunspace.RunspaceAvailability -ne 'Busy') {
                    `$mainRunspace.SessionStateProxy.SetVariable("IcicleCommandParameter", `$value) 
                }
            }
            
            if (`$mainRunspace.RunspaceAvailability -ne 'Busy') {
                `$this.Parent.HostObject.CurrentPowerShellTab.Invoke({
                    if (`$IcicleCommandParameter ) {
                        $($command.Name) @IcicleCommandParameter 
                    } else {
                        'Parameters Not Found'
                    }
                    #Remove-Variable IcicleCommandParameter 
                })
            }
        } catch {
            [Windows.MessageBox]::Show("`$(`$_ | Out-String)", "Error")
        }
    }
} -ControlName '$($Command.Name)' -Children {
    [Windows.Markup.XamlReader]::Parse(@'
$(Request-CommandInput -CommandMetaData $command -Platform WPF)
'@)
}
"@)
        }
        if ($Force -and (Get-Icicle $Name)) {
            Get-Icicle $Name | 
                Remove-Icicle -Confirm:$false
            
        }
        if ($shortcutKey) {
            $addonParams.shortcutKey  =$shortcutKey
        }
        ConvertTo-ISEAddOn @addonParams
        #endregion

        

        $processUiUpdate = {
    
        if ($horizontal) {
                $list = $psise.CurrentPowerShellTab.HorizontalAddOnTools   
        } else {
            $list = $psise.CurrentPowerShellTab.VerticalAddOnTools
        }

        $list | 
            Where-Object {
                $_.Name -eq $UpdateName
            } |
            ForEach-Object {                 
                $_.Control.InvokeScript($uiUpdate, @($outputValue))
            }
     
        }
        if (("$DataUpdate" -or "$UiUpdate") -and 
            $updateEvery.totalMilliseconds) { 
            $timer = 
                New-Object Timers.Timer -Property @{
                    Interval = $UpdateEvery.TotalMilliseconds
                }


            $fullaction = [ScriptBlock]::Create("
`$outputValue = & {
`$global:ProgressPreference = 'SilentlyContinue'
$dataupdate
`$global:ProgressPreference = 'Continue'
}
`$UiUpdate = {$UiUpdate}
`$horizontal = $(if ($horizontal) {'$true' } else { '$false' })
`$updateName = '$Name'
" + $processUiUpdate )

            #region Update Actions


        if ($UpdateOnToggleScriptView) {
            $tabSwitchAction = [ScriptBlock]::Create("" + {
                if ($EventArgs.PropertyName -notlike "*expand*") {
                    return
                }
                
            } + $fullAction)

            if ($force) {
                Get-EventSubscriber "${Name}IseScriptView" -ErrorAction SilentlyContinue | Unregister-Event
            }
            $null = 
                Register-ObjectEvent -SourceIdentifier "${Name}IseScriptView" -InputObject $psise.CurrentPowerShellTab -EventName PropertyChanged -Action $tabSwitchAction  

        }


        if ($UpdateOnAddOnChange) {
            if ($Force) {
                Get-EventSubscriber "${Name}IseVerticalAddOnsChanged" -ErrorAction SilentlyContinue | Unregister-Event
                Get-EventSubscriber "${Name}IseHorizontalAddOnsChanged" -ErrorAction SilentlyContinue | Unregister-Event
            }
            $null = 
                Register-ObjectEvent -SourceIdentifier "${Name}IseVerticalAddOnsChanged" -InputObject $psise.CurrentPowerShellTab.VerticalAddOnTools -EventName CollectionChanged -Action $fullAction

            $null = 
                Register-ObjectEvent -SourceIdentifier "${Name}IseHorizontalAddOnsChanged" -InputObject $psise.CurrentPowerShellTab.HorizontalAddOnTools -EventName CollectionChanged -Action $fullAction

        }

        if ($UpdateOnFileChange) {
            if ($Force) {
                Get-EventSubscriber "${Name}IseFilesChanged" -ErrorAction SilentlyContinue | Unregister-Event
            }
            $null = 
                Register-ObjectEvent -SourceIdentifier "${Name}IseFilesChanged" -InputObject $psise.CurrentPowerShellTab.Files -EventName CollectionChanged -Action $fullAction
            

        }

        $runSoon = New-Object Timers.Timer -Property @{
            AutoReset = $false 
            Interval = ([Timespan]"0:0:0.5").TotalMilliseconds
        }

        if ($Force) {
            Get-EventSubscriber "${Name}FirstUpdate" -ErrorAction SilentlyContinue | Unregister-Event
        }

        $null = 
            Register-ObjectEvent -SourceIdentifier "${Name}FirstUpdate" -InputObject $runSoon  -EventName Elapsed -Action $fullaction 
        $runsoon.Start()
        
        
        if ($fullAction -and $UpdateEvery.totalMilliseconds) { 
            

            # Old tricks from task scheduler: If everything has the exact same update interval, the program will seem to logjam
            # Therefore, randomly offset by 1/8th of a second to avoid some collisions
            $jitteredInterval = $UpdateEvery.TotalMilliseconds + (Get-Random -Maximum 250) - 125

            $timer = 
                New-Object Timers.Timer -Property @{
                    Interval = $jitteredInterval
                }


            
            #region Update Actions

            if ($Force) {
                Get-EventSubscriber "${Name}RegularUpdate" -ErrorAction SilentlyContinue | Unregister-Event
            }
            $null = 
                Register-ObjectEvent -SourceIdentifier "${Name}RegularUpdate" -InputObject $timer -EventName Elapsed -Action $fullaction 
            $timer.Start()

            # Run soon, so it "feels" right


            # Run when the users switches tabs
            #endregion

        }
    }
    $syncAction = [ScriptBlock]::Create(@"

`$outputValue = `$psise, ([Runspace]::DefaultRunspace)
`$horizontal = $(if ($horizontal) {'$true' } else { '$false' })
`$uiUpdate = {
    
    [Windows.Window]::getWindow(`$this).Resources.ISE = (`$args)[0]
    [Windows.Window]::getWindow(`$this).Resources.MainRunspace = (`$args)[1]
}
`$updateName = '$Name'
"@ + $processUiUpdate )

        
    $SyncIse= New-Object Timers.Timer -Property @{
        Interval = ([Timespan]"0:0:2.$(Get-Random -Max 20)").TotalMilliseconds
    }
    if ($Force) {
                Get-EventSubscriber "${Name}SyncIse" -ErrorAction SilentlyContinue | Unregister-Event
            }
    $null = 
        Register-ObjectEvent -SourceIdentifier "${Name}SyncIse" -InputObject $SyncIse -EventName Elapsed -Action $syncAction 
    $SyncIse.Start()

}
}