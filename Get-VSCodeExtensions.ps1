[System.Collections.Generic.List[psobject]] $extensions = @()
if ($IsLinux) {
    $homePath = '/home/'
}
else {
    $homePath = "$($env:HOMEDRIVE)\Users"
}

$homeDirs = Get-ChildItem -Path $homePath -Directory

foreach($dir in $homedirs) {
    $vscPath = Join-Path $dir.FullName '.vscode\extensions'
    if (Test-Path -Path $vscPath) {
        $ChildItem = @{
            Path      = $vscPath
            Recurse   = $true
            Filter    = '.vsixmanifest'
            Force     = $true
        }
        $manifests = Get-ChildItem @ChildItem
        foreach ($m in $manifests) {
            [xml]$vsix = Get-Content -Path $m.FullName
            $vsix.PackageManifest.Metadata.Identity | select-object -Property Id, Version, Publisher,
                @{l = 'Folder'; e = {$m.FullName }},
                @{l = 'ComputerName'; e = {[System.Environment]::MachineName}},
                @{l = 'Date'; e = {Get-Date}} |
                ForEach-Object {$extensions.Add($_)}
        }
    }
}
if ($extensions.Count -eq 0) {
    $extensions.Add([pscustomobject]@{
        Id           = 'No extension found'
        Version      = $null
        $Publisher   = $null
        Folder       = $null
        ComputerName = [System.Environment]::MachineName
        Date         = Get-Date
    })
}
$extensions