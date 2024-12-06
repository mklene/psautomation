Function New-WordTableFromObject {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [object]$object
    )

    $Properties = @($object.psobject.Properties)
    $Table = $Selection.Tables.Add($Word.Selection.Range, $Properties.Count, 2, 
        [Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior, 
        [Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent)

    for ($r = 0; $r -lt $Properties.Count; $r++) {
        $Table.Cell($r + 1, 1).Range.Text = $Properties[$r].Name.ToString()
        $Table.Cell($r + 1, 2).Range.Text = $Properties[$r].Value.ToString()
    }
    $Word.Selection.Start = $Document.Content.End
    $Selection.TypeParagraph()
}
