$moduleRoot = Get-Module "ScriptCop" | Split-Path

if (-not $moduleRoot) { return }


$formatting = @()

$formatting += Write-FormatView -TypeName ScriptCopError -Property Problem, ItemWithProblem -Wrap -GroupByProperty Rule
$formatting += Write-FormatView -TypeName ScriptCop.Test.Output  -action {
    $writeColor = if ($_.Passed) {
        "DarkGreen"
    } else {
        "Red"
    }
    $testStatus = if ($_.Passed) {
        "--- Passed ---"
    } else {
        "*** Failed ***"
    }
    Write-Host "
$($_.TestPass)
|>$($_.TestCase)                         
                                       $testStatus
" -ForegroundColor $writeColor 

    if ($_.Errors) {
Write-Host "
$($_.Errors |Out-String)
" -ForegroundColor $writeColor         
    }
}

$formatting | Out-FormatData | Set-Content "$moduleRoot\ScriptCop.Format.ps1xml"