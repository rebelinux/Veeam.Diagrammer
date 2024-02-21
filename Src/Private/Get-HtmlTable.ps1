Function Get-HTMLTable {
    <#
    .SYNOPSIS
        Function to convert a string array to a HTML Table with Graphviz Nodes split by Columns  (No Icons)
    .DESCRIPTION
        Takes an array and converts it to a HTML table used for GraphViz Node label
    .Example
        $SiteSubnets = @("192.68.5.0/24", "192.68.7.0/24", "10.0.0.0/24")
        Get-HTMLTable -Rows $DCs -Align "Center" -ColumnSize 2 -MultiColunms
            _________________________________
            |               |               |
            |192.168.5.0/24 |192.168.7.0/24 |
            ________________________________
            |               |               |
            |  10.0.0.0/24  |               |
            _________________________________

        $SiteSubnets = @("192.68.5.0/24", "192.68.7.0/24", "10.0.0.0/24")
        Get-HTMLTable -Rows $DCs -Align "Center"
            _________________
            |               |
            |192.168.5.0/24 |
            _________________
            |               |
            |192.168.7.0/24 |
            _________________
            |               |
            |  10.0.0.0/24  |
            _________________

    .NOTES
        Version:        0.5.9
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .PARAMETER Rows
        The array of object to proccess
    .PARAMETER Align
        Align content inside table cell
    .PARAMETER TableBorder
        The table line border
    .PARAMETER CellBorder
        The table cell border
    .PARAMETER FontSize
        The text fornt size used inside the cell
    .PARAMETER IconType
        Icon used to draw the node type
    .PARAMETER ColumnSize
        This number is used to specified how to split the object inside the HTML table
    .PARAMETER MultiColunms
        Split the object into a HTML table with custom ColumnSize
    .PARAMETER Port
        Used inside Graphviz to point the edge between nodes
    #>
    param(
        [string[]] $Rows,
        [string] $Align = 'center',
        [int] $TableBorder = 1,
        [int] $CellBorder = 1,
        [int] $FontSize = 14,
        [string] $Logo,
        [Switch]$MultiColunms,
        [int]$ColumnSize = 2
    )

    if ($MultiColunms) {
        if (($Rows | Measure-Object).Count -le 1) {
            $Group = $Rows
        } else {
            $Group = Split-array -inArray $Rows -size $ColumnSize
        }

        $Number = 0

        $TD = ''
        $TR = ''
        while ($Number -ne ($Group | Measure-Object).Count) {
            foreach ($Element in $Group[$Number]) {
                $TD += '<TD align="{0}" colspan="1"><FONT POINT-SIZE="{1}">{2}</FONT></TD>' -f $Align, $FontSize, $Element
            }
            $TR += '<TR>{0}</TR>' -f $TD
            $TD = ''
            $Number++
        }

        if ($URLIcon) {
            return '<TABLE COLOR="red" border="1" cellborder="1" cellpadding="5">{0}</TABLE>' -f $TR
        } else {
            return '<TABLE border="0" cellborder="0" cellpadding="5">{0}</TABLE>' -f $TR
        }

    } else {
        if ($images[$Logo]) {
            $ICON = $images[$Logo]
        } else { $ICON = $false }

        $TR = ''
        foreach ($r in $Rows) {
            Write-Verbose "Creating Node: $r"
            $TR += '<TR><TD valign="top" align="{0}" colspan="2"><B><FONT POINT-SIZE="{1}">{2}</FONT></B></TD></TR>' -f $Align, $FontSize, $r
        }

        if (!$ICON) {
            return '<TABLE STYLE="ROUNDED" border="{0}" cellborder="{1}" cellpadding="5">{2}</TABLE>' -f $TableBorder, $CellBorder, $TR
        } elseif ($URLIcon) {
            return '<TABLE STYLE="ROUNDED" COLOR="red" border="1" cellborder="1" cellpadding="5"><TR><TD fixedsize="true" width="80" height="80" ALIGN="center" colspan="1" rowspan="4">Logo</TD></TR>{0}</TABLE>' -f $TR

        } else {
            return '<TABLE STYLE="ROUNDED" border="{0}" cellborder="{1}" cellpadding="5"><TR><TD fixedsize="true" width="80" height="80" ALIGN="{2}" colspan="1" rowspan="4"><img src="{3}"/></TD></TR>{4}</TABLE>' -f $TableBorder, $CellBorder, $Align, $Icon, $TR
        }
    }
}