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