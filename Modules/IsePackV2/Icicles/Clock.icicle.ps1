@{ 
    Name = 'Clock'
    Horizontal = $true
    Screen = {
        New-Border -Child {
            New-Label "$(Get-Date | Out-String)" -FontSize 24  -FontFamily 'Lucida Console'
        }    
    }
    DataUpdate = {
        Get-date 
    }
    UiUpdate = {
        $this.Content.Child.Content = $args | Out-String
    }
    UpdateFrequency = "0:0:1"
}
