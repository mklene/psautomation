Function New-ModuleTemplate{
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [Parameter(Mandatory=$true)]
        [string]$ModuleVersion,
        [Parameter(Mandatory=$true)]
        [string]$Author,
        [Parameter(Mandatory=$true)]
        [string]$PSVersion,
        [Parameter(Mandatory=$false)]
        [string[]]$Functions
    )
    $ModulePath = Join-Path .\ "$($ModuleName)\$($ModuleVersion)"
    New-Item -Path $ModulePath -ItemType Directory
    Set-Location $ModulePath
    New-Item -Path .\Public -ItemType Directory

    $ManifestParameters = @{
        ModuleVersion = $ModuleVersion
        Author        = $Author
        Path          = ".\$($ModuleName).psd1"
        RootModule    = ".\$($ModuleName).psm1"
    }
    New-ModuleManifest @ManifestParameters

    $File = @{
        Path     = ".\$($ModuleName).psm1"
        Encoding = 'utf8'
    }
    Out-File @File

    $Functions | ForEach-Object {
        Out-File -Path ".\Public\$($_).ps1" -Encoding utf8
    }
}

$module = @{
    ModuleName    = 'FileCleanupTools'
    ModuleVersion = "1.0.0.0"
    Author        = "MKlene"
    PSVersion     = '7.0'
    Functions     = 'Remove-ArchivedFiles', 'Set-ArchiveFilePath'
}

New-ModuleTemplate @module