function Import-Icicle
{
    <#
    .Synopsis
        Imports Icicles
    .Description
        Imports Icicles (advanced add ons for the PowerShell Integrated Scripting Environment) 
    .Example
        Import-Icicle Clock        
    .Link
        Add-Icicle
    .Link
        Remove-Icicle
    .Link
        Get-Icicle
    #>
    param(
    # The Icicle File
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=0,ParameterSetName='ImportFromFile')]
    [Alias('Fullname')]
    [string]
    $File, 

    # A hashtable directly defining the Icicle.  The hashtable's keys must be parameters to Add-Icicle
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='ImportFromHashtable')]    
    [Hashtable]
    $Icicle, 


    # If set, will force the Icicle to be reloaded
    [Switch]
    $Force,

    # If set, the icicle will be created but not displayed
    [Switch]
    $DoNotShow
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ImportFromFile') {

            try {
                $resolvedFile = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($File)
            } catch {
                $findError = $_
                $icicleExists = Get-Module | 
                    Split-Path | 
                    Join-Path -ChildPath { "Icicles" } | 
                    Join-Path -ChildPath { "${file}.icicle.ps1" } | 
                    Where-Object {
                        Test-Path $_
                    }

                if ($icicleExists) {
                    $resolvedFile = $icicleExists | Select-Object -Unique | Select-Object -First 1 
                } else {
                    Write-Error $findError
                    return
                }
            }
            if (-not $resolvedFile) { 
                # Ok, we really could not find the icicle, so bounce out             
                return 
            } 


            $fileContent = [IO.File]::ReadAllText($resolvedFile) 

            $fileScriptBlock = [ScriptBlock]::Create($fileContent)
            if (-not $fileScriptBlock) { return}


            $resultTable = & $fileScriptBlock
        } elseif ($PSCmdlet.ParameterSetName -eq 'ImportFromHashtable') {
            $resultTable = @{} + $Icicle     
        }
        if (-not $resultTable) { return }
        
        if ($resultTable -isnot [Object[]] -and
            $resultTable -isnot [Hashtable]) {
            return
        }

        

        foreach ($rt in $resultTable) {
            if ($rt -isnot [Hashtable]) { continue }
            if (-not $rt.Name) { $rt.Name = (Get-Item "$resolvedFile").Name.Replace(".icicle.ps1", "").Replace(".icicle", "")} 
            if ($DoNotShow) { $rt.DoNotShow = $DoNotShow } 
            $rt.Force = $Force


            Add-Icicle @rt

        }
    }
} 
