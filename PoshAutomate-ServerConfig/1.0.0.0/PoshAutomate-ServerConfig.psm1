class RegistryTest {
    [string]$operator
    [string]$Value
    RegistryTest() {
    }
    RegistryTest([object]$object) {
        $this.operator = $object.operator
        $this.Value = $object.Value
    }
}

class RegistryCheck {
    [string]$KeyPath
    [string]$Name
    [string]$Type
    [string]$Data
    [string]$SetValue
    [Boolean]$Success
    [RegistryTest]$Tests

    RegistryCheck() {
        $this.Tests += [RegistryTest]::new()
        $this.Success = $false
    }

    RegistryCheck([object]$object) {
        $this.KeyPath = $object.KeyPath
        $this.Name = $object.Name
        $this.Type = $object.Type
        $this.Data = $object.Data
        $this.Success = $false
        $this.SetValue = $object.SetValue

        $object.Tests | foreach-object {
            $this.Tests += [RegistryTest]::new($_)
        }
    }
}

class ServerConfig {
    [string[]] $Features
    [string[]] $Services
    [RegistryCheck[]] $SecurityBaseline
    [UInt64] $FilewallLogSize
    ServerConfig() {
        $this.SecurityBaseline += [RegistryCheck]::new()
    }

    ServerConfig(
        [object] $object
    ) {
        $this.Features = $object.Features
        $this.Services = $object.Services
        $this.FirewallLogSize = $object.FirewallLogSize
        $object.SecurityBaseline | ForEach-Object { $this.SecurityBaseline += [RegistryCheck]::new($_) }
    }
}

Function New-ServerConfig {
    [ServerConfig]::new()
}

Function Invoke-ServerConfig{
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [string[]] $Config = $null
    )
    [System.Collections.Generic.List[PSObject]] $selection = @()
    $Path = @{
        Path      = $PSScriptRoot
        ChildPath = 'Configurations'
    }
    $ConfigPath = Join-Path @Path

    $ChildItem = @{
        Path   = $ConfigPath
        Filter = '*.json'
    }
    $Configurations = Get-ChildItem @ChildItem

    if (-not [string]::IsNullOrEmpty($Config)) {
        foreach($c in $Config) {
            $Configurations | where-object {$_.BaseLine -eq $Config} |
                Foreach-Object { $selection.Add($_) }
        }
    }
    
    if ($selection.Count -eq 0) {
        $Configurations | Select-Object BaseName, FullName | 
            Out-GridView -PassThru | Foreach-Object { $selection.Add($_) }
    }

    $Log = "$($env:COMPUTERNAME)-Config.log"
    $LogFile = Join-Path -Path $($env:SystemDrive) -ChildPath $Log

    foreach($json in $selection) {
        Set-ServerConfig -ConfigJson $json.FullName -LogFile $Logfile
    }
}