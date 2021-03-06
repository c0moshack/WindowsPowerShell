@{
    Name = 'IseMan'
    Horizontal = $true
    UpdateFrequency = "0:0:30"
    UpdateOnAddOnChange = $true
    Screen = {
        New-Border -ControlName History -BorderBrush Black -CornerRadius 5 -Child {
            New-Grid -Rows Auto, 1*, Auto -Columns 1*, Auto -Children {
                New-TextBlock -Margin "10,10, 3, 3" -FontWeight DemiBold -FontSize 24 -Text "Iseman"
                New-ListBox -Margin "10,10, 3, 3"  -DisplayMemberPath Name  -Padding 10 -ItemsPanel {
                    New-StackPanel -Orientation Horizontal -Margin 10
                } -On_PreviewKeyDown {
                    if ($_.Key -eq 'Enter' -and $this.SelectedItem) {
                        . $this.Resources.'Select-ListItem' # When the user double clicks, go to the location and close the window
                        $_.Handled = $true
                    }
                } -Name Iciclelist -Row 1 -On_MouseDoubleClick {
                    if ($this.SelectedItem) {
                        $ise = [Windows.Window]::GetWindow($this).Resources.ISE
                        $ise.CurrentPowerShellTab.Invoke(
                            "Get-Icicle $($this.selectedItem.Name) | Show-Icicle"
                        )
                        
                        
                    }
                }
                
                New-Button -Margin "10,10, 3, 3" -Content { 
                    New-StackPanel -Orientation Vertical {
                        New-TextBlock -FontWeight DemiBold -FontSize 24 -HorizontalAlignment Center -FontFamily "Wingdings" -Text ([char]0x31)
                        New-TextBlock -Text Import-Icicle
                    }
                } -Row 1 -Column 1 -On_Click {
                        $ise = [Windows.Window]::GetWindow($this).Resources.ISE
                        if ($ise.CurrentPowerShellTab.CanInvoke) {
                            $ise.CurrentPowerShellTab.Invoke("
                        `$fd = New-OpenFileDialog -Multiselect -Filter `"Icicles (*.icicle.ps1)`" 
                        if (`$fd -and `$fd.ShowDialog()) {
                            `$fd.FileNames | Get-Item | Import-Icicle -force
                        }
                        ")
                        }
                   
                } 
            }
        }
    } 
    UiUpdate = {
        $hi = $args
        $this.Content | 
            Get-ChildControl -ByName Iciclelist | 
            ForEach-Object {
                $_.itemssource = $hi
            }
        $this.Content.Resources.Ise = $this.Parent.HostObject
    }

   
    DataUpdate = {
        Get-Icicle
    }
    
} 
