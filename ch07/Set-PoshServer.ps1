Function Set-PoshServer {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(ValueFromPipeline = $true, ParameterSetName = "Pipeline")]
        [object]$InputObject,
        [Parameter(Mandatory = $true, ParameterSetName = "ID")]
        [int]$ID,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1,50)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Windows','Linux')]
        [string]$OSType,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1,50)]
        [string]$OSVersion,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Active','Depot','Retired')]
        [string]$Status,

        [Parameter(Mandatory = $false)]
        [ValidateSet('WSMan','SSH','PowerCLI','HyperV','AzureRemote')]
        [string]$RemoteMethod,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1,255)]
        [string]$UUID,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Physical','VMware','Hyper-V','Azure','AWS')]
        [string]$Source,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1,255)]
        [string]$SourceInstance
    )
    begin {
        [System.Collections.Generic.List[object]] $Return = @()
        [System.Collections.Generic.List[string]] $Set = @()
        [System.Collections.Generic.List[string]] $Output = @()
        $SqlParameter = @{ID = $null}

        $PSBoundParameters.GetEnumerator() |
            Where-Object { $_.Key -notin @('ID','InputObject') + [System.Management.Automation.Cmdlet]::CommonParameters } |
                ForEach-Object {
                    $set.Add("$($_.Key) = @$($_.Key)")
                    $Output.Add("deleted.$($_.Key) AS Prev_$($_.Key), inserted.$($_.Key) AS $($_.Key)")
                    $SqlParameter.Add($_.Key, $_.Value)
                }

                $query = 'UPDATE [dbo].' + "[$($_PoshAssetMgmt.$ServerTable)] " + 'SET ' + ($set -join (', ')) + ' OUTPUT @ID as ID, ' + ($Output -join (', ')) + 'WHERE ID = @ID'
                
                Write-Verbose @query
                $Parameters = @{
                    SqlInstance   = $_SqlInstance
                    Database      = $_PoshAssetMgmt.Database
                    Query         = $Query
                    SqlParameter  = @{}
                }

                if ($PSCmdlet.ParameterSetName -eq 'ID') {
                    $InputObject = Get-PoshServer -Id $Id
                    if (-not $InputObject) {
                        throw "No server object was found for id '$Id'"
                    }
                }
    }
    process {
        $SqlParameter['ID'] = $InputObject.ID
        $Parameters['SqlParameter'] = $SqlParameter
        Invoke-DbaQuery @Parameters | ForEach-Object { $Return.Add($_) }
    }
    end {
        $Return
    }
}