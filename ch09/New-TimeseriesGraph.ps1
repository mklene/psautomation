Function New-TimeseriesGraph {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PyPath,
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.Commands.GetCounter.PerformanceCounterSampleSet]
        $CounterData
    )

    $CounterJson = $CounterData | Select-Object @{l='Value';e={$_.CounterSamples.CookedValue}} | ConvertTo-Json -Compress
    $Guid = New-Guid
    $path = @{
        Path = $env:TEMP
    }

    $picture = Join-Path @Path -ChildPath "$($Guid).png"
    $StandardOutput = Join-Path @Path -ChildPath "$($Guid)-Output.txt"
    $StandardError = Join-Path @Path -ChildPath "$($Guid)-Error.txt"

    $ArgumentList = @(
        """$($ScriptPath)"""
        """$($picture)"""
        """$($Title)"""
        $CounterJson.Replace('"','\"')
    )

    $Process = @{
        FilePath               = $PyPath
        ArgumentList           = $ArgumentList
        RedirectStandardOutput = $StandardOutput
        RedirectStandardError  = $StandardError 
        NoNewWindow            = $true
        PassThru               = $true
    }

    $graph = Start-Process @Process
    $RuntimeSeconds = 30
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    while ($graph.HasExited -eq $false) {
        if ($timer.Elapsed.TotalSeconds -gt $RuntimeSeconds) {
            $graph | Stop-Process -Force
            throw "The application did not exit in time"
        }
    }
    $timer.Stop()
    $OutputContent = Get-Content -Path $StandardOutput
    $ErrorContent = Get-Content -Path $ErrorContent
    if ($ErrorContent) {
        Write-Error $ErrorContent
    }
    elseif ($OutputContent | where-object { $_ -match 'File saved to :'}) {
        $output = $OutputContent | where-object { $_ -match 'File saved to :' }
        $Return = $output.Substring($output.IndexOf(':') + 1).Trim()
    }
    else {
        Write-Error "Unknown error occured"
    }

    Remove-Item -LiteralPath $StandardOutput -Force
    Remove-Item -LiteralPath $StandardError -Force
    
    $Return
}