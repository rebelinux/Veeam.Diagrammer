Function Get-HTMLLabel {
    param(
        [string]$Label,
        [string]$Port
    )

    return "<TABLE border='0' cellborder='0' cellspacing='0' cellpadding='0'><TR><TD ALIGN='center' colspan='1' PORT='$Port'>$Label</TD></TR></TABLE>"
}