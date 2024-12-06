$SqlInstance = "$($env:COMPUTERNAME)\SQLExpress"
$DatabaseName = 'PoshAssetMgmt'
$ServersTable = 'Servers'
$ServersColumns = @(
    @{Name = 'ID'; Type = 'int'; MaxLength = $null; Nullable = $false; Identity = $true;}
    @{Name = 'Name'; Type = 'nvarchar'; MaxLength = 50; Nullable = $false; Identity = $false;}
    @{Name = 'OSType'; Type = 'nvarchar'; MaxLength = 15; Nullable = $false; Identity = $false;}
    @{Name = 'OSVersion'; Type = 'nvarchar'; MaxLength = 50; Nullable = $false; Identity = $false;}
    @{Name = 'Status'; Type = 'nvarchar'; MaxLength = 15; Nullable = $false; Identity = $false;}
    @{Name = 'RemoteMethod'; Type = 'nvarchar'; MaxLength = 25; Nullable = $false; Identity = $false;}
    @{Name = 'UUID'; Type = 'nvarchar'; MaxLength = 255; Nullable = $false; Identity = $false;}
    @{Name = 'Source'; Type = 'nvarchar'; MaxLength = 15; Nullable = $false; Identity = $false;}
    @{Name = 'SourceInstance'; Type = 'nvarchar'; MaxLength = 255; Nullable = $false; Identity = $false;}

)

$DbaDbTable = @{
    SqlInstance = $SqlInstance
    Database    = $DatabaseName
    Name        = $ServersTable
    ColumnMap   = $ServersColumns
}
New-DbaTable @DbaDbTable
