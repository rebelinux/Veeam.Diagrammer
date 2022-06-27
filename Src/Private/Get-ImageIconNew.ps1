Function Get-ImageIconNew {
    param(
        [string]$Type,
        [string]$Name,
        [string]$Role,
        [string]$Align,
        [string]$IP
    )

    if ($images[$Type]) {
        $ICON = $images[$Type]
    } else {$ICON = "no_icon.png"}

    if ($Align -eq "Center") {
        return "<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='$($ICON)'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>$Name</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role: $Role</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP: $IP</TD></TR></TABLE>"
    }

    elseif ($Align -eq "Left") {
        "<TABLE border='0' cellborder='0' cellspacing='0' cellpadding='0'><TR><TD ALIGN='left' rowspan='3'><img src='$($ICON)'/></TD><TD align='left' valign='Bottom'><B> $Name</B></TD></TR><TR><TD align='left'> Role: $Role</TD></TR><TR><TD align='left' valign='Top'> IP: $IP</TD></TR></TABLE>"
    }
    else{@{Label=$Name; Image=$($ICON)}}
}