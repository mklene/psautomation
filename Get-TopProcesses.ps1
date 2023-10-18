Function Get-TopProcesses{
    param(
        [Parameter(Mandatory=$true)]
        [int]$TopN
    )
    Get-Process | Sort-Object CPU -Descending | 
        Select-Object -First $TopN -Property ID, ProcessName,@{l='CPU';e={'{0:N}' -f $_.CPU}}
}