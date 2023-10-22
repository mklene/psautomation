param (
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    [Parameter(Mandatory=$true)]
    [string]$Destination,
    [Parameter(Mandatory=$true)]
    [string]$LogPath
)

Function Move-ItemAdvanced {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory=$true)]
        [object]$File,
        [Parameter(Mandatory=$true)]
        [string]$Destination
    )

    $DestinationFile = Join-Path -Path $Destination -ChildPath $File.Name
    if (Test-Path $DestinationFile) {
        $FileMatch = $true
        $check = Get-Item $DestinationFile
        if ($check.Length -ne $file.Length) {
            $FileMatch = $false
        }
        $srcHash = Get-FileHash $file.FullName
        $dstHash = Get-FileHash $check.FullName
        if ($dstHash.Hash -ne $srcHash.Hash) {
            $FileMatch = $false
        }
        if ($FileMatch -eq $false) {
            $ts = (Get-Date).ToFileTimeUtc()
            $name = $File.Basename + "_" + $ts + $File.Extension
            $DestinationFile = Join-Path -Path $Destination -ChildPath $name
            Write-Verbose "File will be renamed to '$($name)'"
        }
        else {
            Write-Verbose "File will be overwritten"
        }
    }
    else {
        $FileMatch = $false
    }

    $moveParams = @{
        Path        = $file.FullName
        Destination = $DestinationFile
    }

    if ($FileMatch -eq $true) {
        $moveParams.Add('Force',$true)
    }
    Move-Item @moveParams -PassThru
}

if (-not (Test-Path $FilePath)) {
    "$(Get-Date) file not found " | Out-File $LogPath -Append
    break 
}

$file = Get-Item $FilePath
$Arguments = @{
    File        = $File
    Destination = $Destination
}
try {
    $moved = Move-ItemAdvanced @Arguments -ErrorAction Stop
    $message = "Moved '$($FilePath)' to '$($moved.FullName)"
}
catch {
    $message = "Error moving '$($FilePath)' : $($_)"
}
finally {
    "$(Get-Date) : $message" | Out-File $LogPath -Append
}