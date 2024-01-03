Function Get-HTMLLabel {
    param(
        [string]$Label,
        [string]$Type,
        [string]$PortPos
    )

    if ($Type -eq 'NoIcon') {
        $ICON = 'NoIcon'
    } elseif ($URLIcon) {
        $ICON = 'NoIcon'
    }
    elseif ($images[$Type]) {
        $ICON = $images[$Type]
    } else {$ICON = "no_icon.png"}

    if ($ICON -ne 'NoIcon') {
        return "<TABLE border='0' cellborder='0' cellspacing='20' cellpadding='10'><TR><TD ALIGN='center' colspan='1'><img src='$($ICON)'/></TD></TR><TR><TD ALIGN='center'>$Label</TD></TR></TABLE>"
    } else {
        return "<TABLE border='0' cellborder='0' cellspacing='20' cellpadding='10' ><TR><TD bgcolor='#FFCCCC' ALIGN='center' colspan='1'>Veeam Logo</TD></TR><TR><TD bgcolor='#FFCCCC' ALIGN='center'>$Label</TD></TR><TR><TD ALIGN='center'><font color='red'>Debug ON</font></TD></TR></TABLE>"
    }
}