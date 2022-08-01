Function Get-HTMLLabel {
    param(
        [string]$Label,
        [string]$Type
    )

    if ($images[$Type]) {
        $ICON = $images[$Type]
    } else {$ICON = "no_icon.png"}

    return "<TABLE border='0' cellborder='0' cellspacing='20' cellpadding='10'><TR><TD ALIGN='center' colspan='1'><img src='$($ICON)'/></TD></TR><TR><TD ALIGN='center'>$Label</TD></TR></TABLE>"
}