Function Get-PoshServer {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory = $false)]
        [int]$ID,
        [Parameter(Mandatory = $false)]
        [string]$name,
        [Parameter(Mandatory = $false)]
        [string]$OSType,
        [Parameter(Mandatory = $false)]
        [string]$Status,
        [Parameter(Mandatory = $false)]
        [string]$RemoteMethod,
        [Parameter(Mandatory = $false)]
        [string]$UUID,
        [Parameter(Mandatory = $false)]
        [string]$Source,
        [Parameter(Mandatory = $false)]
        [string]$SourceInstance
    )

    $ServerTable = "Servers"
    [System.Collections.Generic.List[string]] $where = @()
    $SqlParameter = @{}
    $PSBoundParameters.GetEnumerator() | where-object { $_.Key -notin [System.Management.Automation.Cmdlet]::CommonParameters } |
        ForEach-Object {
            $where.Add("$($_.Key) = @$($_.Key)")
            $SqlParameter.Add($_.Key, $_.Value)
        }
    $Query = "SELECT * FROM " + $ServerTable

    if ($where.Count -gt 0) {
        $Query += " WHERE " + ($where -join (' and '))
    }
    Write-Verbose $Query
    Write-Verbose ($SqlParameter | convertto-json)
    $DbaQuery = @{
        SqlInstance  = $_SqlInstance
        Database     = $_PoshAssetMgmt.Database
        Query        = $Query
        SqlParameter = $SqlParameter
    }

  #  Invoke-DbaQuery @DbaQuery
}