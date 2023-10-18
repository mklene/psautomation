param(
    [Parameter(Mandatory=$true)]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Destination,

    [Parameter(Mandatory=$true)]
    [string]$ActionScript,

    [Parameter(Mandatory=$true)]
    [int]$ConcurrentJobs,

    [Parameter(Mandatory=$true)]
    [string]$WatcherLog,

    [Parameter(Mandatory=$true)]
    [int]$TimeLimit
)

$Timer = [System.Diagnostics.Stopwatch]::StartNew()

if (Test-Path $WatcherLog) {
    $logDate = Get-Content $WatcherLog -Raw
    try {
        $LastCreationTime = Get-Date $logDate -ErrorAction Stop
    }
    catch {
        $LastCreationTime = Get-Date 1970-01-01
    }
} 
else {
    $LastCreationTime = Get-Date 1970-01-01
}

$files = Get-ChildItem -Path $Source |
    Where-Object {$_.CreationTimeUtc -gt $LastCreationTime}
$sorted = $files | Sort-Object -Property CreationTime

[int[]]$Pids = @()

foreach($file in $sorted) {
    Get-Date $file.CreationTimeUtc -Format o | Out-File $WatcherLog

    $Arguments = "-file ""$ActionScript""",
        "-FilePath ""$($file.FullName)""",
        "-Destination ""$($Destination)""",
        "-LogPath ""$($ActionsLog)"""

    $jobParams = @{
        FilePath     = 'pwsh'
        ArgumentList = $Arguments
        NoNewWindow  = $true 
    }

    $job = Start-Process @jobParams -PassThru
    $Pids += $job.Id

    while ($Pids.Count -ge $ConcurrentJobs) {
        Write-Host "Pausing PID count : $($Pids.Count)"
        Start-Sleep -Seconds 1
        $Pids = @(Get-Process -Id $Pids -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
    }

    if ($Timer.Elapsed.TotalSeconds -gt $TimeLimit) {
        Write-Host "Graceful terminating afer $TimeLimit seconds"
        break
    }
}