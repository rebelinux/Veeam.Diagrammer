function Get-DiagBackupToFileProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.29
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]

    Param
    (

    )

    begin {
    }

    process {
        try {
            $FileBackupProxy = Get-VbrBackupProxyInfo -Type 'nas'
            if ($BackupServerInfo) {
                if ($FileBackupProxy) {

                    if ($FileBackupProxy.Name.Count -le 1) {
                        $FileBackupProxyColumnSize = 1
                    } elseif ($ColumnSize) {
                        $FileBackupProxyColumnSize = $ColumnSize
                    } else {
                        $FileBackupProxyColumnSize = $FileBackupProxy.Name.Count
                    }

                    Node FileProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($FileBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize $FileBackupProxyColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $FileBackupProxy.AditionalInfo -Subgraph -SubgraphIconType "VBR_Proxy" -SubgraphLabel "File Backup Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -fontSize 18 -SubgraphLabelFontsize 26); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                    Edge BackupServers -To FileProxies @{minlen = 3 }

                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}