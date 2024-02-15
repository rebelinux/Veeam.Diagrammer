Function Get-HTMLLabel {
    <#
    .SYNOPSIS
        Used to set the Report Main Logo
    .DESCRIPTION
        Takes a string and converts it to a HTML table used for the report main logo an title
    .Example
        $MainGraphLabel = Switch ($DiagramType) {
            'Forest' { $translate.forestgraphlabel }
            'Domain' { $translate.domaingraphlabel }
            'Sites' { $translate.sitesgraphlabel }
            'SitesTopology' { $translate.sitesgraphlabel }
        }
        $CustomLogo = "Logo Path"
        $URLIcon = False
        Get-HTMLLabel -Label $MainGraphLabel -IconType $CustomLogo -URLIcon $URLIcon
                    __________________
                    |                |
                    |   Main Logo    |
                    _________________
                    |                |
                    | Diagram Title  |
                    __________________
    .NOTES
        Version:        0.5.9
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .PARAMETER Label
        The string used to set the Diagram Title
    .PARAMETER SubgraphLabel
        Allow to create a table used to add a logo to a Graphviz subgraph
    .PARAMETER IconType
        Main Diagram Logo
    #>
    param(
        [string] $Label,
        [string] $IconType,
        [Switch] $SubgraphLabel,
        [string] $IconWidth = 40,
        [string] $IconHeight = 40
    )

    if ($IconType -eq 'NoIcon') {
        $ICON = 'NoIcon'
    } elseif ($URLIcon) {
        $ICON = 'NoIcon'
    } elseif ($images[$IconType]) {
        $ICON = $images[$IconType]
    } else { $ICON = "no_icon.png" }

    if (-Not $SubgraphLabel) {
        if ($ICON -ne 'NoIcon') {
            return "<TABLE border='0' cellborder='0' cellspacing='20' cellpadding='10'><TR><TD ALIGN='center' colspan='1'><img src='$($ICON)'/></TD></TR><TR><TD ALIGN='center'>$Label</TD></TR></TABLE>"
        } else {
            return "<TABLE border='0' cellborder='0' cellspacing='20' cellpadding='10'><TR><TD bgcolor='#FFCCCC' ALIGN='center' colspan='1'>Veeam Logo</TD></TR><TR><TD bgcolor='#FFCCCC' ALIGN='center'>$Label</TD></TR><TR><TD ALIGN='center'><font color='red'>Debug ON</font></TD></TR></TABLE>"
        }
    }
    if ($SubgraphLabel) {
        if ($ICON -ne 'NoIcon') {
            return "<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='5'><TR><TD ALIGN='center' colspan='1' fixedsize='true' width='$($IconWidth)' height='$($IconHeight)'><img src='$($ICON)'/></TD><TD ALIGN='center'>$Label</TD></TR></TABLE>"
        } else {
            return "<TABLE border='0' cellborder='0' cellspacing='20' cellpadding='10'><TR><TD bgcolor='#FFCCCC' ALIGN='center' colspan='1'>Subgraph Logo</TD><TD bgcolor='#FFCCCC' ALIGN='center'>$Label</TD></TR></TABLE>"
        }
    }
}