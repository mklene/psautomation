[CmdletBinding(SupportsShouldProcess=$true)]
[OutputType()]
param(
    [Parameter(Mandatory = $true)]
    [String]$LogPath,
    [Parameter(Mandatory = $true)]
    [String]$ZipPath,
    [Parameter(Mandatory = $true)]
    [String]$ZipPrefix,
    [Parameter(Mandatory = $false)]
    [double]$NumberOfDays = 30
)

<#
$LogPath = "c:\temp\Logs\"
$ZipPath = "c:\temp\"
$ZipPrefix = "LogArchive-"
$NumberOfDays = 30
#>

Import-Module .\FileCleanupTools

$Date = (Get-Date).AddDays(-$NumberOfDays)
$Files = Get-ChildItem -Path $LogPath -File | Where-Object { $_.LastWriteTime -lt $Date}
$ZipParameters = @{
    ZipPath   = $ZipPath
    ZipPrefix = $ZipPrefix
    Date      = $Date
}

if ($files.Count -eq 0) {
    // Nothing found
    return
}
$ZipFile = Set-ArchiveFilePath @ZipParameters

$Files | Compress-Archive -DestinationPath $ZipFile

$RemoveFiles = @{
    ZipFile = $ZipFile
    FilesToDelete = $Files
}

Remove-ArchivedFiles @RemoveFiles
