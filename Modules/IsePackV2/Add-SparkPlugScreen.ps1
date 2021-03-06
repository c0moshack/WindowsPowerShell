function Add-SparkplugScreen
{
    param(
    [Parameter(Mandatory=$true)]
    [string]
    $Name,    
    [Parameter(Mandatory=$true)]
    [ScriptBlock]
    $Screen,
    [ScriptBlock]    
    $Update,
    
    [Timespan]$UpdateFrequency = "0:0:15"
    )
            
 	$runningJob = Get-Job -Name Sparkplug -ErrorAction SilentlyContinue | 
		Where-Object { 
			$_.State -eq 'Running' -and
			$_ -is [ShowUI.WPFJob]
		} | Select-Object -First 1

    if (-not $runningJob) { Start-SparkPlug }
    
    $runningJob = Get-Job -Name Sparkplug -ErrorAction SilentlyContinue | 
		Where-Object { 
			$_.State -eq 'Running' -and
			$_ -is [ShowUI.WPFJob]
		} | Select-Object -First 1


    $params = @{} + $psBoundParameters
    $cmd = [ScriptBlock]::Create("
    `$screen  = { $screen } 
    `$name = '$name' 
    `$update = { $update }
    `$UpdateFrequency = [Timespan]'$UpdateFrequency'
    " + {                
        $window.Content.Resources.ScreenScripts = $screen
        
        $screenResult = & $screen

        if ($screenResult -is [Windows.Media.Visual]) {
            $window.Content.Resources.Screens[$Name] = New-Border -Padding 15 -MaxWidth 420 -MaxHeight 360 -CornerRadius 15 -BorderThickness 3 -Child { $screenResult }
            $window.Content.Resources.ScreenUpdates[$Name] = $Update
            $window.Content.Resources.ScreenUpdateInterval[$name] = $UpdateFrequency
            $realScreen = $window.Content.Resources.Screens[$Name]
            $realScreen.SetValue([Windows.Controls.Canvas]::TopProperty, [Double]30)
            $realScreen.SetValue([Windows.Controls.Canvas]::LeftProperty, [Double]-1080)
            Add-ChildControl -control $realScreen -parent $window.Content
            $screenList = $window.Content | Get-ChildControl -PeekIntoNestedControl -ByName ScreenList
            
            $screenList.ItemsSource = @($window.Content.Resources.Screens.Keys | Sort-Object) 
            $sb = [ScriptBLock]::Create("
            `$screenName = '$Name'
            " +{
                $runspace = $window.Content.Resources.Runspace
                $invokeSparkplug = [ScriptBlock]::Create($window.Content.Resources.'Invoke-Sparkplug')
                New-Module -ScriptBlock $invokeSparkplug
                $updateScript = $window.Content.Resources.ScreenUpdates[$screenName]                
                $screenBorder = $window.Content.Resources.Screens[$screenName]
                if (-not $screenBorder) {
                    $window.Content.Resources.Screens[$screenName] = 
                        New-Border -Child { & $window.Content.Resources.ScreenScripts[$screenName] }
                        
                    $screenBorder = $window.Content.Resources.Screens[$screenName]
                }
                
                
                $updateResult = . Invoke-Sparkplug -Script $updateScript -GetOutput -DoNotAddToHistory
                if ($screenBorder.Child) {
                    $screenBorder.Child.DataContext = $updateResult                    
                }    
                                
                $window.Content.Resources.ScreenLastUpdated[$screenName] = Get-Date                
            })            
            Register-PowerShellCommand -ScriptBlock $sb -run -once -in "0:0:0.5"
            Register-PowerShellCommand -Name "UpdateScreen$Name" -ScriptBlock $sb -run -in $UpdateFrequency
            #$screenList.SelectedItem = $Name
        }
                        
        & ([scriptBlock]::Create($window.Content.Resources.'Refresh-Screen')) $window.Content
    })
    Update-WPFJob -Job $runningJob -Command $cmd
}