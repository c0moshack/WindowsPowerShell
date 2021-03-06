function Start-Demo
{
    param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('Fullname')]
    [string]$fileName,

    [Switch]$Paused
    )

    process {
        $resolvedFile = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($fileName)
        if (-not $resolvedFile) { return } 
        
        $demoIce = Import-Icicle Demo -Force        

        if (-not $demoIce) { 
            return
        }
        if ($demoIce) {
            $walkthrus = Get-Item -LiteralPath $resolvedFile | Get-Walkthru

            $n = 0
            foreach ($step in $walkThrus) {
                $n++   
                $step | 
                    Add-Member NoteProperty Name "Step $n" -Force 
                                    
            }

            $null = $demoIce.Control.InvokeScript({                                    
                $demoStepList.ItemsSource = @($args[0])
                $paused = $args[1]
                $demoStepList.Visibility = 'Visible'
                                    
                $firstStep= $args[0] | 
                    Select-Object -First 1                                         
                $demoStepList.Tag = $firstStep
                $demoStepList.SelectedItem = $firstStep
                if ($firstStep.SourceFile ){                                        
                                        
                    $leaf=  $firstStep.SourceFile | Split-Path -Leaf
                    $DemoName.Text = $leaf -ireplace '\.walkthru\.help\.txt', '' -ireplace '_', ' '
                    $DemoName.Visibility = 'Visible'
                    
                    $StepName.Visibility = 'Visible'
                    
                    $TimeUntilNextStep.Tag = [Timespan]::FromSeconds(20)
                    if ($paused) {
                        $autoPlayDemo.IsChecked = -not $paused    
                        $TimeUntilNextStep.Visibility = 'Collapsed'
                    } else {
                        $TimeUntilNextStep.Visibility = 'Visible'
                        $StepName.Text = 'Step 1'
                        $autoPlayDemo.Tag = $true
                    }
                }


                $ImportAndStartDemo.Visibility = 'Collapsed'
                                    
                $PlayPauseButton.IsEnabled = $true
                                    
                $DemoName.Tag = $false
            },@($walkthrus,$Paused))

                                
                                
        }        
    }
} 
