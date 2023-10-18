$Path = Join-Path $PSScriptRoot 'Public'
$Functions = Get-ChildItem -Path $Path -Filter '*.ps1'

foreach ($import in $Functions) {
    try {
        Write-Verbose "dot-sourcing file '$($import.FullName)"
        . $import.FullName
    }
    catch {
        Write-Error -Message "failed to import $($import.Name)"
    }
}