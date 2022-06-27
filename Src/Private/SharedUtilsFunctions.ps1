
function Remove-SpecialChars {
    <#
    .SYNOPSIS
        Used by As Built Report to remove bad characters.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Prateek Singh
    .EXAMPLE
    .LINK
    #>
    param(
        [string]$String,
        [string]$SpecialChars = "()[]{}&."
    )

    $String -replace $($SpecialChars.ToCharArray().ForEach( { [regex]::Escape($_) }) -join "|"), ""
}