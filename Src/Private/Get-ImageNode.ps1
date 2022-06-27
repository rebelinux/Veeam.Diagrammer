Function Get-ImageNode {
    [CmdletBinding()]
    param(
        [hashtable[]]$Rows,
        [string]$Type,
        [String]$Name,
        [String]$Align
    )

    if ($images[$Type]) {
        $ICON = $images[$Type]
    } else {$ICON = "no_icon.png"}

    $TR = @()
    foreach ($r in $Rows) {
        $TR += $r.getEnumerator() | ForEach-Object {"<TR><TD align='$Align' colspan='1'><FONT POINT-SIZE='14'>$($_.Key): $($_.Value)</FONT></TD></TR>"}
    }

    if ($ICON) {
        "<TABLE border='0' cellborder='0' cellspacing='0' cellpadding='0'><TR><TD ALIGN='$Align' colspan='3'><img src='$($ICON)'/></TD></TR><TR><TD align='$Align'><B>$Name</B></TD></TR>$TR</TABLE>"
    }

}