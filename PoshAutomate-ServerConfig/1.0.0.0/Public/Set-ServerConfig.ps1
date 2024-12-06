Import-Module .\PoshAutomate-ServerConfig.psd1 -Force

$Config = New-ServerConfig

$Content = @{
    Path = '.\RegistryChecksAndResolves.json'
    Raw  = $true
}

$Data = (Get-Content @Content | ConvertFrom-Json)
$Config.SecurityBaseline = $Data
$Config.FirewallLogSize = 4096

$Config.Features = @(
    "RSAT-AD-Powershell",
    "RSAT-AD-AdminCenter",
    "RSAT-ADDSTools"
)

$Config.Services = @(
    "PrintNotify",
    "Spooler",
    "lltdsvc",
    "SharedAccess",
    "wisvc"
)

if (-not (Test-Path ".\Configurations")) {
    New-Item -Path ".\Configurations" -ItemType Directory
}

$Config | ConvertTo-Json -Depth 4 | Out-File ".\Configurations\SecurityBaseline.json" -Encoding utf8