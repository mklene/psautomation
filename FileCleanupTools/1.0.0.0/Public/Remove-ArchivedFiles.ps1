Function Remove-ArchivedFiles {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ZipFile,
        
        [Parameter(Mandatory=$true)]
        [object]$FilesToDelete
    )
    $AssemblyName = 'System.IO.Compression.Filesystem'
    Add-Type -AssemblyName $AssemblyName | Out-Null

    $OpenZip = [System.IO.Compression.ZipFile]::OpenRead($ZipFile)
    $ZipFileEntries = $OpenZip.Entries

    foreach($file in $FilesToDelete) {
        $check = $ZipFileEntries | where-object {$_.Name -eq $file.Name -and $_.Length -eq $file.Length}
        if ($null -ne $check) {
            $file | Remove-Item -Force -WhatIf:$WhatIf
        }
        else {
            Write-Error "'$($file.Name)' was not found in ZipFile '$($ZipFile)'"
        }
    }

}