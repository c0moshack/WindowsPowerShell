Function Update-Window {
    Param (
        $Title,
        $Content,
        [switch]$AppendContent
    )
    $syncHash.textbox.Dispatcher.invoke([action]{
        $syncHash.Window.Title = $title
        If ($PSBoundParameters['AppendContent']) {
            $syncHash.TextBox.AppendText($Content)
        } Else {
            $syncHash.TextBox.Text = $Content
        }
    },
    "Normal")
}

Update-Window -Title ("Services on {0}" -f $Env:Computername) `
              -Content (Get-Service | Sort Status -Desc| out-string)
