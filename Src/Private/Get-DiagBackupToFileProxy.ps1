function Get-DiagBackupToFileProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.0
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
        # Get Veeam Backup Server Object
        Get-DiagBackupServer
    }

    process {
        try {
            $FileBackupProxy = Get-VbrBackupProxyInfo -Type 'nas'
            if ($BackupServerInfo) {
                if ($FileBackupProxy) {
                    $ProxiesAttr = @{
                        Label = 'File Backup Proxies'
                        fontsize = 18
                        penwidth = 1.5
                        labelloc = 't'
                        color = $SubGraphDebug.color
                        style = 'dashed,rounded'
                    }
                    SubGraph MainSubGraph -Attributes $ProxiesAttr -ScriptBlock {
                        foreach ($ProxyObj in $FileBackupProxy) {
                            $PROXYHASHTABLE = @{}
                            $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                            Node $ProxyObj -NodeScript { $_.Name } @{Label = $PROXYHASHTABLE.Label; fontname = "Segoe Ui" }
                            Edge -From MainSubGraph:s -To $ProxyObj.Name @{constraint = "true"; minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        Rank $FileBackupProxy.Name
                    }

                    if ($Dir -eq 'LR') {
                        Edge $BackupServerInfo.Name -To 'MainSubGraph' @{minlen = 3 }
                    } else {
                        Edge $BackupServerInfo.Name -To 'MainSubGraph' @{minlen = 3 }
                    }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}