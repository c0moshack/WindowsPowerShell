function Add-SqlTable {
    <#
    .Synopsis
        Adds a SQL Table
    .Description
        Creates a new Table in SQL
    
    .Link
        Select-SQL
    .Link
        Update-SQL
    #>
    [CmdletBinding(DefaultParameterSetName='SqlServer')]
    param(
    # The name of the SQL table
    [Parameter(Mandatory=$true)]
    [string]$TableName,

    # The columns to create within the table
    [Parameter(Mandatory=$true)]
    [string[]]$Column,

    # The keytype to use
    [ValidateSet('Guid', 'Hex', 'SmallHex', 'Sequential', 'Named', 'Parameter')]
    [string]$KeyType  = 'Guid',

    # The name of the column to use as a key.
    [string]
    $RowKey = "RowKey",

    # The data types of each column
    [string[]]$DataType,
    
    # A connection string or a setting containing a connection string.    
    [Alias('ConnectionString', 'ConnectionSetting')]
    [string]$ConnectionStringOrSetting,
    
    # If set, outputs the SQL, and doesn't execute it
    [Switch]
    $OutputSQL,
    
    # If set, will use SQL server compact edition
    [Parameter(Mandatory=$true,ParameterSetName='SqlCompact')]
    [Switch]
    $UseSQLCompact,


    # The path to SQL Compact.  If not provided, SQL compact will be loaded from the GAC
    [Parameter(ParameterSetName='SqlCompact')]
    [string]
    $SqlCompactPath,

    # If set, will use SQL lite
    [Parameter(Mandatory=$true,ParameterSetName='Sqlite')]
    [Alias('UseSqlLite')]
    [switch]
    $UseSQLite,
    
    # The path to SQL Lite.  If not provided, SQL compact will be loaded from Program Files
    [Parameter(ParameterSetName='Sqlite')]
    [string]
    $SqlitePath,
    
    # The path to a SQL compact or SQL lite database
    [Parameter(Mandatory=$true,ParameterSetName='SqlCompact')]
    [Parameter(Mandatory=$true,ParameterSetName='Sqlite')]
    [Alias('DBPath')]
    [string]
    $DatabasePath)

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
        $columnsAndTypes = @()
        $rowKeySqlType = if ($KeyType -ne 'Sequential') {
            if ($useSqlLite) {
                "nchar(100)"
            } elseif ($useSqlCompact) {
                "nchar(100)"
            } else {
                "char(100)"
            }
        } else {
            if ($UseSQLite) {
                "integer"
            } else {
                "bigint"
            }
            
        }
        $autoIncrement = $(if ($KeyType -eq 'Sequential') { 
            if ($useSQlite) {
                "PRIMARY KEY" 
            } else {
                "IDENTITY"
            }
        } else {
            ""
        })
        $columnsAndTypes += "$RowKey $rowKeySqlType NOT NULL $autoIncrement Unique $(if (-not ($UseSQLite -or $UseSQLCompact)) { " CLUSTERED "})"
        $columnsAndTypes +=
            for($i =0; $i -lt $Column.Count; $i++) {
                $columnDataType = 
                    if ($dataType -and $DataType[$i]) {
                        $datatype[$i]
                    } else {
                        if ($UseSQLite) {
                            "text"
                        } elseif ($useSqlCompact) {
                            "ntext"
                        } else {
                            "varchar(max)"
                        }
                    }
                "`"$($Column[$i])`" $columnDataType"
            }
        $createstatement = "CREATE TABLE $tableName (
    $($ColumnsAndTypes -join (',' + [Environment]::NewLine + "   "))
)"                
        
        if ($OutputSQL) {
            $createstatement
        } else {
            if ($UseSQLCompact) {
                $sqlAdapter = New-Object "Data.SqlServerCE.SqlCeDataAdapter" $createStatement, $sqlConnection
                $dataSet = New-Object Data.DataSet
                $rowCount = $sqlAdapter.Fill($dataSet)
            } elseif ($UseSQLite) {
                $sqliteCmd = New-Object Data.Sqlite.SqliteCommand $createstatement, $sqlConnection
                $rowCount = $sqliteCmd.ExecuteNonQuery()
            } else {
                $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($createStatement, $sqlConnection)
                $sqlAdapter.SelectCommand.CommandTimeout = 0
                $dataSet = New-Object Data.DataSet
                $rowCount = $sqlAdapter.Fill($dataSet)

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