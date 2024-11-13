function Get-DiagBackupToHvProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.9
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

                Node HvProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($HyperVBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo $HyperVBackupProxy.AditionalInfo -Subgraph -SubgraphIconType "VBR_Proxy" -SubgraphLabel "Hyper-V Backup Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }


                Edge $BackupServerInfo.Name -To HvProxies @{minlen = 3 }

            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}