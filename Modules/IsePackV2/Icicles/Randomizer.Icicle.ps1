@{
    Name = 'Randomizer'
    Screen = {
        #$today  =Get-Date
        $today = $null

        if ($today.Month -eq 12 -and 
            ($today.Day -gt 17 -and $today.Day -lt 26)) {
        
            # Christmas Lights!                 
            $xmasVideos = 'http://www.youtube.com/watch?v=rmgf60CI_ks&feature=player_embedded',
                'http://www.youtube.com/watch?v=szLmAPW39uE&feature=player_embedded',
                'http://www.youtube.com/watch?v=bXjbMIZzAgs&feature=player_embedded',
                'http://www.youtube.com/watch?v=_vwOCmJyCZk&feature=player_embedded',
                'http://www.youtube.com/watch?v=ucjmd032Z-M&feature=player_embedded',
                'http://www.youtube.com/watch?v=mTbpuQzMnxA&feature=player_embedded',
                'http://www.youtube.com/watch?v=5W7xj5f-eCs&feature=player_embedded',
                'http://www.youtube.com/watch?v=RJISYEbPF4E&feature=player_embedded'

            Import-Module Pipeworks 
            
            $webPage = Write-Link -Url ($xmasVideos | Get-Random ) 
            
            $webPage = $webPage |
                    New-Region -Style @{
                        "Margin-Left" = "25%"
                        "Margin-Right" = "25%"
                    }
            $wb = New-WebBrowser 
            $wb.NavigateToString($webPage)
            $wb
             
        } else {

             New-WebBrowser  -On_Loaded {
                $fiComWebBrowser = $this.GetType().GetField('_axIWebBrowser2', 'Instance,NonPublic')
                if (-not $fiComWebBrowser) { return } 
    
                $objComWebBrowser = $fiComWebBrowser.GetValue($this);
                if (-not $objComWebBrowser) { return } 
        
                
                $arr = new-Object Object[] 1
                $arr[0] = $true
                $objComWebBrowser.GetType().InvokeMember('Silent', [Reflection.BindingFlags]'SetProperty', $null, $objComWebBrowser, $arr)

            } -Source http://get-random.com
        }
    }
    DataUpdate = {
    }
    UiUpdate = {
    }
} 
