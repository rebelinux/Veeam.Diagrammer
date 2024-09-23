function Get-DiagBackupToHvProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.8
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
            $HyperVBackupProxy = Get-VbrBackupProxyInfo -Type 'hyperv'
            if ($HyperVBackupProxy) {
                $ProxiesAttr = @{
                    Label = 'Hyper-V Backup Proxies'
                    fontsize = 18
                    penwidth = 1.5
                    labelloc = 'b'
                    color = $SubGraphDebug.color
                    style = 'dashed,rounded'
                }
                SubGraph MainSubGraph -Attributes $ProxiesAttr -ScriptBlock {

                    Node HvProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($HyperVBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($HyperVBackupProxy.AditionalInfo )); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                }

                Edge $BackupServerInfo.Name -To HvProxies @{minlen = 3 }

            }
        } catch {
            $_
        }
    }
    end {}
}