@{
    Name = 'Pasty'
    Horizontal = $true
    Screen = {
        New-Border -ControlName Pasty -Padding 10 -CornerRadius 5 -Child {
            New-grid -rows auto,1*, auto -Columns 2 -children {
                    New-TextBlock -Text "Paste early.  Refactor often." -FontSize 19 -Margin 9                     
                    New-Border -Column 1 -Margin 10 -CornerRadius 6 -BorderBrush Black -BorderThickness 2 -HorizontalAlignment Right  -Child {
                        New-Label "Clear" -FontWeight DemiBold -On_MouseDown {
                            $PasteList = $this.Parent.Parent | 
                                Get-ChildControl -ByName PasteList
                            $pasteList.ItemsSource = @()                    
                        }
                    }
                    
                    New-ListBox -Padding 10 -ColumnSpan 2 -ItemsPanel {
                        New-StackPanel -Orientation Horizontal -Margin 20 
                    } -Tag @{} -Row 1 -Name PasteList -On_MouseDoubleClick {
                        if ($this.SelectedItem) {
                            $ise = [Windows.Window]::GetWindow($this).Resources.ISE
                            [Windows.Clipboard]::SetText("$($this.SelectedItem)")                        
                        }
                        
                    }
                    
                     
                
            }
        }
    }
    DataUpdate = {
        [Windows.Clipboard]::GetText()        
    } 
    UiUpdate = {                
        $paste = $args
        $pasteMd5 = [Security.Cryptography.MD5]::Create().ComputeHash("$paste".ToCharArray()) 
        $pasteMd5 = [Convert]::ToBase64String($pasteMd5)
        $this.Content | 
            Get-ChildControl -ByName PasteList | 
            ForEach-Object {  
                if (-not $_.Tag[$pasteMd5]) {
                        
                    $_.itemssource = @($paste) +  @($_.itemssource) 
                } else {
                    $_.itemssource = @($paste) + @(
                        $_.itemssource | 
                            Where-Object { 
                                $_ -ne $paste})
                }
                
                $_.Tag[$pasteMd5] = $paste
                

               
                
            }
        $this.Content.Resources.Ise = $this.Parent.HostObject
    }
    UpdateFrequency = "0:0:10"
    ShortcutKey = "Ctrl + Alt + H"
} 
