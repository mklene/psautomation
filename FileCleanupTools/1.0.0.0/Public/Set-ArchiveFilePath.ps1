Function Set-ArchiveFilePath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ZipPath,
        [Parameter(Mandatory=$true)]
        [string]$ZipPrefix,
        [Parameter(Mandatory=$true)]
        [datetime]$Date
    )

    if(-not (Test-Path $ZipPath)) {
        New-Item -Path $ZipPath -ItemType Directory | Out-Null
        Write-Verbose "Created directory '$ZipPath'"
    }

    $timeString = $Date.ToString('yyyyMMdd')
    $ZipName = "$($ZipPrefix)$($timeString).zip"
    $ZipFile = Join-Path $ZipPath $ZipName
    
    if (Test-Path $ZipFile) {
        throw "The Archive-File '$ZipFile' already exists"
    }

    $ZipFile
}