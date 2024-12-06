Function Disable-WindowsService {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$services,
        [Parameter(Mandatory = $true)]
        [int]$HardKillSeconds,
        [Parameter(Mandatory = $true)]
        [int]$SecondsToWait
    )

    [System.Collections.Generic.List[PSObject]] $ServiceStatus = @()
    foreach ($Name in $Services) {
        $ServiceStatus.Add([pscustomobject]@{
            Service  = $Name
            HardKill = $false
            Status   = $null
            Startup  = $null
        })
        try {
            $Get = @{
                Name        = $Name
                ErrorAction = 'Stop'
            }
            $Service = Get-Service @Get
            $Set = @{
                InputObject = $Service
                StartupType = 'Disabled'
            }
            Set-Service @Set
            $Stop = @{
                InputObject = $Service
                Force       = $true
                NoWait      = $true
                ErrorAction = 'SilentlyContinue'
            }
            Stop-Service @Stop
            Get-Service -Name $Name | foreach-object {
                $ServiceStatus[-1].Status = $_.Status.ToString()
                $ServiceStatus[-1].Startup = $_.StartType.ToString()
            }
        } catch {
            $msg = 'NoServiceFoundForGivenName,Microsoft.PowerShell' + '.Commands.GetServiceCommand'
            if ($_.FullyQualifiedErrorId -eq $msg) {
                $ServiceStatus[-1].Status = 'Stopped'
            }
            else {
                Write-Error $_
            }
        }
    }

    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    do {
        $ServiceStatus | where-object { $_.Status -ne 'Stopped' } |
        foreach-object { 
            $_.Status = (Get-Service $_.Service).Status.ToString()
            if ($_.HardKill -eq $false -and $timer.Elapsed.TotalSeconds -gt $HardKillSeconds) {
                Write-Verbose "Attempting hard kill on $($_.Service)"
                $query = "SELECT * from Win32_Service Where name = '{0}'"
                $query = $query -f $_.Service
                $svcProcess = Get-CimInstance -Query $query
                $Process = @{
                    Id          = $svcProcess.ProcessId
                    Force       = $true
                    ErrorAction = 'SilentlyContinue'
                }
                Stop-Process @Process
                $_.HardKill = $true
            }
        }
        $Running = $ServiceStatus | where-object { $_.Status -ne 'Stopped' }
    } while ( $Running -and $timer.Elapsed.TotalSeconds -lt $SecondsToWait )
    $ServiceStatus | where-object { $_.Status -ne 'Stopped'} | foreach-object {$_.Status = 'Reboot Rquired' }
    $ServiceStatus
}