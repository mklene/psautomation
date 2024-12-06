Function Get-HotFixStatus {
    param(
        $Id,
        $Computer
    )

    $Found = $false
    try {
        $HotFix = @{
            Id           = $Id
            ComputerName = $Computer
            ErrorAction  = 'Stop'
        }
        Get-Hotfix @HotFix | Out-Null
        $Found = $true
    }
    catch {
        $NotFound = 'GetHotFixNoEntriesFound,' + 'Microsoft.PowerShell.Commands.GetHotFixCommand'
        if($_.FullyQualifiedErrorId -ne $NotFound) {
            throw $_
        }
    }
    $Found
}
