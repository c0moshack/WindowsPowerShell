function Get-ScriptToken {
    <#
    .Synopsis 
        Gets the tokens within a script block of file
    .Description
        Gets the tokens within a script block of file
    .Example
        Get-ScriptToken {
            function foo() {
                "foo"
            }
            function bar() {
                "bar"
            }
        }
    #>
    param(
    [Parameter(Mandatory=$true,
        ParameterSetName="ScriptBlock",
        ValueFromPipelineByPropertyName=$true)]    
    [ScriptBlock]
    $ScriptBlock,
    
    
    [Parameter(Mandatory=$true,
        ParameterSetName="File",
        ValueFromPipelineByPropertyName=$true)]           
    [Alias('FullName')]
    [String]
    $File
    )
    
    process {
        if ($psCmdlet.ParameterSetName -eq "File") {
            $realFile = Get-Item $File
            if (-not $realFile) {
                $realFile = Get-Item -LiteralPath $File -ErrorAction SilentlyContinue
                if (-not $realFile) { 
                    return
                }
            }
            $text = [IO.File]::ReadAllText($realFile.Fullname)
            $scriptBlock = [ScriptBlock]::Create($text)
            Get-ScriptToken -ScriptBlock $scriptBlock
        } elseif ($psCmdlet.ParameterSetName -eq "ScriptBlock") {            
            $text = $scriptBlock.ToString()
            $tokens = [Management.Automation.PSParser]::Tokenize($scriptBlock, [ref]$null)            
            $tokens
        }        
    }
} 
