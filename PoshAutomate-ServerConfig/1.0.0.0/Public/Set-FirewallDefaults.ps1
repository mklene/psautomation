Function Set-FirewallDefaults {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandator = $true)]
        [UInt64] $LogSize
    )

    $FirewallSettings = [PSCustomObject]@{
        Enabled       = $false
        PublicBlocked = $false
        LogFileSet    = $false
        Errors        = $null
    }

    try {
        $NetFirewallProfile = @{
            Profile     = 'Domain','Public','Private'
            Enabled     = 'True'
            ErrorAction = 'Stop'
        }
        Set-NetFirewallProfile @NetFirewallProfile
        $FirewallSettings.Enabled = $true

        $NetFirewallProfile = @{
            Name                 = 'Public'
            DefaultInboundAction = 'Block'
            ErrorAction          = 'Stop'
        }
        Set-NetFirewallProfile @NetFirewallProfile
        $FirewallSettings.PublicBlocked = $true

        $log = '%windir%\system32\logfiles\firewall\pfirewall.log'
        $NetFirewallProfile = @{
            Name                = 'Domain','Public','Private'
            LogFileName         = $log
            LogBlocked          = 'True'
            LogMaxSizeKilobytes = $LogSize
            ErrorAction         = 'Stop'
        }
        Set-NetFirewallProfile @NetFirewallProfile
        $FirewallSettings.LogFileSet = $true

    }
    catch {
        $FirewallSettings.Errors = $_
    }

    $FirewallSettings
}