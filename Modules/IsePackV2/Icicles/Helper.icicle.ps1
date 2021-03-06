@{
    Name = 'Helper'
    Screen = {
        New-Border -ControlName Helper -BorderBrush Black -CornerRadius 5 -Child {
            New-Grid -Rows Auto, Auto, 1*, Auto -Children {
                New-TextBlock -FontWeight DemiBold -FontSize 22 -Text "Need some Help?"
                New-TextBlock -Row 1 -FontSize 14 -Text "Click on a Command to Show Its Help.  The commands shown are the commands referenced by the loaded script." -TextWrapping Wrap
                New-ListBox -Row 2 -On_PreviewKeyDown {
                    if ($_.Key -eq 'Enter' -and $this.SelectedItem) {
                        . $this.Resources.'Select-ListItem' # When the user double clicks, go to the location and close the window
                        $_.Handled = $true
                    }
                } -Name HelperList -DisplayMemberPath Name -On_MouseDoubleClick {
                    if ($this.SelectedItem) {
                        $ise = [Windows.Window]::GetWindow($this).Resources.ISE
                        $ise.CurrentPowerShellTab.Invoke(
                            "Show-Command -Name '$($this.SelectedItem.Name)'"
                        )
                        
                    }
                } 
            }
        }
    }
    DataUpdate = {
        try {
            $sb = [ScriptBlock]::Create($psise.CurrentFile.Editor.Text)
            Get-ReferencedCommand -ScriptBlock $sb
        } catch {
        }
    }
    UiUpdate = {
        $commandList = $args
        $this.Content | 
            Get-ChildControl -ByName HelperList | 
            ForEach-Object {  
                $_.itemssource = @($commandList)
            }
        $this.Content.Resources.Ise = $this.Parent.HostObject
    }
    UpdateFrequency = "0:0:30"
} 
