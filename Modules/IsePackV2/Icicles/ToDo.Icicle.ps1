# To Do: Test Refresh
@{
    Name = 'ToDo'
    Screen = {
        New-Border -ControlName ToDo -BorderBrush Black -Padding 20 -CornerRadius 5 -Child {
            New-Grid -Rows Auto, 1*, Auto -Children {
                New-TextBlock -FontWeight DemiBold -FontSize 24 -Text "ToDo"
                New-ListBox -On_PreviewKeyDown {
                    if ($_.Key -eq 'Enter' -and $this.SelectedItem) {
                        . $this.Resources.'Select-ListItem' # When the user double clicks, go to the location and close the window
                        $_.Handled = $true
                    }
                } -Resource @{
                    "Select-ListItem" = {
                
                        $CurrentFile.Editor.SetCaretPosition($this.SelectedItem.StartLine, 
                            $this.SelectedItem.StartColumn)
                       
                        $currentFile.Editor.EnsureVisible($this.SelectedItem.StartLine)
                        $ISE.CurrentPowerShellTab.ExpandedScript = $true

                        $currentFile.Editor.Focus()
                        
                        $ISE.CurrentPowerShellTab.HorizontalAddOnToolsPaneOpened = $false
                        $ISE.CurrentPowerShellTab.VerticalAddOnToolsPaneOpened = $false
                
                    }
                } -Name ToDoList -Row 1 -DisplayMemberPath Content -On_MouseDoubleClick {
                    if ($this.SelectedItem) {
                        . $this.Resources.'Select-ListItem' # When the user double clicks, go to the location and close the window
                        
                    }
                } -On_SelectionChanged {
                    if ($this.SelectedItem) { 
                        $CurrentFile.Editor.SetCaretPosition($this.SelectedItem.StartLine, 
                            $this.SelectedItem.StartColumn)
                       
                        $currentFile.Editor.EnsureVisible($this.SelectedItem.StartLine)
                        $ISE.CurrentPowerShellTab.ExpandedScript = $true               
                        $this.Focus() 
                    }
                }
            }
        }
    }
    DataUpdate = {
        try {
            $matches = [Management.Automation.PSParser]::Tokenize($psise.CurrentFile.Editor.Text,[ref]$null) |
                Where-Object {
                    $_.Type -eq 'Comment' -and (
                        $_.Content -like "*To?do*" -or $_.Content -like "*todo*"
                    )
                }
            New-Object PSObject -Property @{
                ToDoList = $matches
                CurrentFile = $psise.CurrentFile
                Ise = $psise
            }

        } catch {
        
        }
    }
    UiUpdate = {
        $toDo = $args | Select-Object -ExpandProperty ToDoList 
        $currentFile = $args | Select-Object -ExpandProperty  CurrentFile
        $ise = $args | Select-Object -ExpandProperty  Ise
        $this.Content | 
            Get-ChildControl -ByName ToDoList | 
            ForEach-Object {  
                $_.itemssource = @($toDo)
            }
        $this.Content.Resources.currentFile  = $currentFile
        $this.Content.Resources.Ise = $ise
    }
    UpdateFrequency = "0:0:10"
} 
#Todo: do stuff