Function Get-HTMLTable {
    param(
        [string[]] $Rows,
        [string] $Align = 'center',
        [int] $TableBorder= 1,
        [int] $CellBorder= 1,
        [int] $FontSize = 14,
        [string] $Logo
    )

    if ($images[$Logo]) {
        $ICON = $images[$Logo]
    } else {$ICON = $false}

    $TR = ''
    $flag = $true
    foreach ($r in $Rows) {
        Write-Verbose "Creating Node: $r"
        $TR += '<TR><TD valign="top" align="{0}" colspan="2"><B><FONT POINT-SIZE="{1}">{2}</FONT></B></TD></TR>' -f $Align, $FontSize, $r
    }

    if (!$ICON) {
        return '<TABLE border="{0}" cellborder="{1}" cellpadding="5">{2}</TABLE>' -f $TableBorder, $CellBorder, $TR
    } elseif ($URLIcon) {
        return '<TABLE COLOR="red" border="1" cellborder="1" cellpadding="5">{0}</TABLE>' -f $TR
    } else {
        return '<TABLE border="{0}" cellborder="{1}" cellpadding="5"><TR><TD fixedsize="true" width="120" height="120" ALIGN="{2}" colspan="1" rowspan="4"><img src="{3}"/></TD></TR>{4}</TABLE>' -f $TableBorder, $CellBorder, $Align, $Icon, $TR
    }
}