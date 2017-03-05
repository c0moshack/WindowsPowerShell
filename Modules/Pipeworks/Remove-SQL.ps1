function Remove-SQL
{
    <#
    .Synopsis
        Removes SQL data
    .Description
        Removes SQL data or databases
    .Example
        Remove-Sql -TableName ATable -ConnectionSetting SqlAzureConnectionString
    .Example
        Remove-Sql -TableName ATable -Where 'RowKey = 1' -ConnectionSetting SqlAzureConnectionString        
    .Example
        Remove-Sql -TableName ATable -Clear -ConnectionSetting SqlAzureConnectionString        
    .Link
        Add-SqlTable
    .Link
        Update-SQL
    #>
    [CmdletBinding(DefaultParameterSetName='DropTable',SupportsShouldProcess=$true,ConfirmImpact='High')]
    param(
    # The table containing SQL results
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
    [Alias('Table','From', 'Table_Name')]
    [string]$TableName,


    # The where clause.  Beware:  different SQL engines treat this differently.  For instance, SQL server Compact requires the format:
    # ([RowName] = 'Value')
    [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true,ParameterSetName='DeleteRows')]
    [string]$Where,

    [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true,ParameterSetName='ClearTable')]
    [Switch]$Clear,

    # A connection string or setting.    
    [Alias('ConnectionString', 'ConnectionSetting')]
    [string]$ConnectionStringOrSetting,

    [Switch]
    $OutputSql,

        # If set, will use SQL server compact edition
    [Parameter()]
    [Switch]
    $UseSQLCompact,


    # The path to SQL Compact.  If not provided, SQL compact will be loaded from the GAC
    [Parameter()]
    [string]
    $SqlCompactPath,

    # If set, will use SQL lite
    [Parameter()]
    [Alias('UseSqlLite')]
    [switch]
    $UseSQLite,
    
    # The path to SQL Lite.  If not provided, SQL compact will be loaded from Program Files
    [Parameter()]
    [string]
    $SqlitePath,
    
    # The path to a SQL compact or SQL lite database
    [Parameter()]
    [Alias('DBPath')]
    [string]
    $DatabasePath

    )

    begin {
        if ($PSBoundParameters.ConnectionStringOrSetting) {
            if ($ConnectionStringOrSetting -notlike "*;*") {
                $ConnectionString = Get-SecureSetting -Name $ConnectionStringOrSetting -ValueOnly
            } else {
                $ConnectionString =  $ConnectionStringOrSetting
            }
            $script:CachedConnectionString = $ConnectionString
        } elseif ($script:CachedConnectionString){
            $ConnectionString = $script:CachedConnectionString
        } else {
            $ConnectionString = ""
        }
        if (-not $ConnectionString -and -not ($UseSQLite -or $UseSQLCompact)) {
            throw "No Connection String"
            return
        }

        if (-not $OutputSQL) {

            if ($UseSQLCompact) {
                if (-not ('Data.SqlServerCE.SqlCeConnection' -as [type])) {
                    if ($SqlCompactPath) {
                        $resolvedCompactPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($SqlCompactPath)
                        $asm = [reflection.assembly]::LoadFrom($resolvedCompactPath)
                    } else {
                        $asm = [reflection.assembly]::LoadWithPartialName("System.Data.SqlServerCe")
                    }
                }
                $resolvedDatabasePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($DatabasePath)
                $sqlConnection = New-Object Data.SqlServerCE.SqlCeConnection "Data Source=$resolvedDatabasePath"
                $sqlConnection.Open()
            } elseif ($UseSqlite) {
                if (-not ('Data.Sqlite.SqliteConnection' -as [type])) {
                    if ($sqlitePath) {
                        $resolvedLitePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($sqlitePath)
                        $asm = [reflection.assembly]::LoadFrom($resolvedLitePath)
                    } else {
                        $asm = [Reflection.Assembly]::LoadFrom("$env:ProgramFiles\System.Data.SQLite\2010\bin\System.Data.SQLite.dll")
                    }
                }
                
                
                $resolvedDatabasePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($DatabasePath)
                $sqlConnection = New-Object Data.Sqlite.SqliteConnection "Data Source=$resolvedDatabasePath"
                $sqlConnection.Open()
                
            } else {
                $sqlConnection = New-Object Data.SqlClient.SqlConnection "$connectionString"
                $sqlConnection.Open()
            }
            

        }
    }

    process {
        if ($TableName -and $where) {
            $sqlStatement = "DELETE FROM $tableName $(if ($Where) { "WHERE $where"})".TrimEnd("\").TrimEnd("/")
        } elseif ($clear) {
            
            $sqlStatement = if ($UseSQLCompact) {
                "DELETE FROM $tableName"
            } elseif ($UseSQLite) {
                "DELETE FROM $tableName"
            } else { 
                "TRUNACATE TABLE $tableName"
            }
        } else {
            

            $sqlStatement = "DROP TABLE $tableName"
        }

        if ($outputSql) {
            $sqlStatement
        } elseif (-not $outputSql -and $psCmdlet.ShouldProcess($sqlStatement)) {
            Write-Verbose "$sqlStatement"
            if ($UseSQLCompact) {
                $sqlAdapter = New-Object "Data.SqlServerCE.SqlCeDataAdapter" $sqlStatement, $sqlConnection
                $dataSet = New-Object Data.DataSet
                $rowCount = $sqlAdapter.Fill($dataSet)
            } elseif ($UseSQLite) {
                $sqliteCmd = New-Object Data.Sqlite.SqliteCommand $sqlStatement, $sqlConnection
                $rowCount = $sqliteCmd.ExecuteNonQuery()
            } else {
                $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($sqlStatement, $sqlConnection)
                $sqlAdapter.SelectCommand.CommandTimeout = 0
                $dataSet = New-Object Data.DataSet
                $rowCount = $sqlAdapter.Fill($dataSet)

            }                        
        
            foreach ($t in $dataSet.Tables) {
            
                foreach ($r in $t.Rows) {
                    $r.pstypenames.clear()
                    if ($r.pstypename) {                    
                        foreach ($tn in ($r.pstypename -split "\|")) {
                            $r.pstypenames.add($tn)
                        }
                    }
                
                    $r
                
                }
            }

        }
        
    }

    end {
         
        if ($sqlConnection) {
            $sqlConnection.Close()
            $sqlConnection.Dispose()
        }
        
    }
}
 
