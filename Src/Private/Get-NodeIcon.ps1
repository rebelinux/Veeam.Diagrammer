Function Get-NodeIcon {

    [CmdletBinding()]
    [OutputType([System.String])]

    param(
        [hashtable[]]$Rows,
        [string]$Type,
        [String]$Name,
        [String]$Align
    )


    if ($Type -eq 'NoIcon') {
        $ICON = 'NoIcon'
    } elseif ($URLIcon) {
        $ICON = 'NoIcon'
    } elseif ($images[$Type]) {
        $ICON = $images[$Type]
    } else {$ICON = "no_icon.png"}

    $TR = @()
    foreach ($r in $Rows) {
        $TR += $r.getEnumerator() | ForEach-Object {"<TR><TD align='$Align' colspan='1'><FONT POINT-SIZE='14'>$($_.Key): $($_.Value)</FONT></TD></TR>"}
    }

    if ($ICON -ne 'NoIcon') {
        if ($Align -eq "Center") {
            "<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='$Align' colspan='1'><img src='$($ICON)'/></TD></TR><TR><TD align='$Align'><B>$Name</B></TD></TR>$TR</TABLE>"
        }
        else {
            "<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='$Align' rowspan='4' valign='Bottom'><img src='$($ICON)'/></TD></TR><TR><TD align='$Align'><B> $Name</B></TD></TR> $TR</TABLE>"
        }
    } else {
        if ($Align -eq "Center") {
            "<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='$Align' colspan='1'></TD></TR><TR><TD align='$Align'><B>$Name</B></TD></TR>$TR</TABLE>"
        }
        else {
            "<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='$Align' rowspan='4' valign='Bottom'></TD></TR><TR><TD align='$Align'><B> $Name</B></TD></TR> $TR</TABLE>"
        }
    }

}