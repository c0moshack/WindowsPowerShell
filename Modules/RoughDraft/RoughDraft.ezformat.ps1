$moduleRoot = "$home\documents\windowspowershell\modules\RoughDraft" 

Write-FormatView -TypeName System.Windows.Media.FontFamily -Action {
    if ($request -and $response) {
        $fileFound = Get-ChildItem -Path "$($_.Source).png" -ErrorAction SilentlyContinue
        if ($fileFound) {
            "<h3>$($_.SOurce)</h3><img src='data:image/png;base64,$([Convert]::ToBase64String([io.FILE]::ReadAllBytes($fileFound.FullName)))' />"
        } else {
            $_.Source
        }
    } else {
        $_.Source
    }
} | Out-FormatData |
Set-Content "$moduleRoot\RoughDraft.Format.ps1xml"
