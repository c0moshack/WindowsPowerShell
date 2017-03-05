@{
    Name = 'History'
    Screen = {
        New-Border -ControlName History -BorderBrush Black -CornerRadius 5 -Child {
            New-grid -rows 1*, auto -children {
                
                    New-ListBox -SelectionMode Multiple -Row 0 -On_PreviewKeyDown {
                        if ($_.Key -eq 'Enter' -and $this.SelectedItem) {
                            
                            $_.Handled = $true
                        } elseif ($_.Key -eq 'Delete' -and $this.SelectedItems) {
                            $removeHistoryScript = ""
                            foreach ($i in @($this.SelectedItems)) {
                                $removeHistoryScript += "Clear-History -Id $($i.id) -ErrorAction SilentlyContinue
"
                                $this.ItemsSource = @($this.ItemsSource | Where-Object { $_.Id -ne $i.Id } )
                            }

                            $ise = [Windows.Window]::GetWindow($this).Resources.ISE
                            
                            if ($ise.CurrentPowerShellTab.CanInvoke) {
                                $ise.CurrentPowerShellTab.InvokeSynchronous($removeHistoryScript + "
Update-Icicle History"
)
                                                    
                            }
                            $_.Handled = $true
                        }
                        
                    } -Name HistoryList -DisplayMemberPath CommandLine -On_PreviewMouseDoubleClick {
                        
                        if ($this.SelectedItem -and ($this.SelectedItems.Count -eq 1)) {
                            $ise = [Windows.Window]::GetWindow($this).Resources.ISE
                            $ise.CurrentPowerShellTab.Invoke($this.SelectedItem.CommandLine)                        
                        }
                        $_.Handled = $true
                        
                    } -On_SelectionChanged {
                        $nc = $this.Parent | 
                            Get-childControl -OutputNamedControl

                        if ($this.SelectedItem -and ($this.SelectedItems.Count -eq 1)) {
                            $nc.StartTime.Content = 
                                $this.SelectedItem.StartExecutionTime.ToShortTimeString()
                            $nc.StopTime.Content = 
                                $this.SelectedItem.EndExecutionTime.ToShortTimeString()
                            $nc.Duration.Content  =  
                                $this.SelectedItem.EndExecutionTime - $this.SelectedItem.StartExecutionTime
                            $nc.CopyToClipboard.Tag = $this.SelectedItem.CommandLine
                            $nc.historyDetail.Visibility = "Visible"
                            

                        } elseif ($this.SelectedItems.Count) {
                            $nc.CopyToClipboard.Tag = ($this.SelectedItems | Select-Object -expandProperty CommandLine) -join ([Environment]::NewLine)
                            $nc.historyDetail.Visibility = "Visible"
                        } else {
                           $nc.historyDetail.Visibility = "Collapsed"
                        }
                        
                    }


                    New-Grid -Row 1 -Name historyDetail -Rows 'Auto', 'Auto', 'Auto', 'Auto' -Columns 2 -Children {
                        New-Label -Content "Started" -Row 0 -HorizontalAlignment Right 
                        New-Label -Name StartTime 0 -Column 1 
                        New-Label -Content "Stopped" -Row 1 -HorizontalAlignment Right 
                        New-Label -Name StopTime -Column 1 -Row 1 
                        New-Label -Content "Duration" -Row 2 -HorizontalAlignment Right 
                        New-Label -Name Duration -Column 1  -Row 2 
                        New-Button -Row 3 -ColumnSpan 2 -Margin 3 -Padding 3 -Name CopyToClipboard -content "Copy To Clipboard"-HorizontalAlignment Center -FontFamily 'Segoe UI' -FontSize 19 -FontWeight DemiBold -On_Click {
                            [Windows.Clipboard]::SetText($this.tag)
                        }
                    }
                
            }
        }
    }
    DataUpdate = {
        Get-History | Sort-Object StartExecutionTime -Descending
        
    } 
    UiUpdate = {
        $hi = $Args

        
        
        $this.Content | 
            Get-ChildControl -ByName HistoryList | 
            ForEach-Object {  
                $_.Tag = $this.Parent.HostObject
                $i = $_
                if (-not $i.ItemsSource) {
                    $i.ItemsSource = @($hi)
                } else {
                    foreach ($h in $hi) {
                        if ($i.ItemsSource[0].Id -lt $h.Id) {
                            $i.ItemsSource= @($h) + $i.ItemsSource
                        }
                        
                    }
                    
                }
            }
        $this.Content.Resources.Ise = $this.Parent.HostObject
    }
    UpdateFrequency = "0:0:11"
    ShortcutKey = "Ctrl + Alt + H"
} 
