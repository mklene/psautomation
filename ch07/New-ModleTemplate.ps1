Function New-ModuleTemplate {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)] [string] $ModuleName,
        [Parameter(Mandatory = $true)] [string] $ModuleVersion,
        [Parameter(Mandatory = $true)] [string] $PSVersion,
        [Parameter(Mandatory = $true)] [string[]] $Functions
    )
}