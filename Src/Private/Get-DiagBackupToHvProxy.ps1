function Get-DiagBackupToHvProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.6
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
    process {
        try {
            $HyperVBackupProxy = Get-VbrBackupProxyInfo -Type 'hyperv'
            if ($Dir -eq 'LR') {
                $DiagramLabel = 'Hyper-V Backup Proxies'
                $DiagramDummyLabel = ' '
            } else {
                $DiagramLabel = ' '
                $DiagramDummyLabel = 'Hyper-V Backup Proxies'
            }
            if ($HyperVBackupProxy) {
                $ProxiesAttr = @{
                    Label = $DiagramLabel
                    fontsize = 18
                    penwidth = 1.5
                    labelloc = 't'
                    color=$SubGraphDebug.color
                    style='dashed,rounded'
                }
                SubGraph MainSubGraph -Attributes $ProxiesAttr -ScriptBlock {
                    # Dummy Node used for subgraph centering
                    node DummyHyperVProxy @{Label=$DiagramDummyLabel; fontsize=18; fontname="Segoe Ui Black"; fontcolor='#005f4b'; shape='plain'}
                    if ($Dir -eq "TB") {
                        node HvLeft @{Label='HvLeft'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                        node HvLeftt @{Label='HvLeftt'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                        node HvRight @{Label='HvRight'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                        edge HvLeft,HvLeftt,DummyHyperVProxy,HvRight @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                        rank HvLeft,HvLeftt,DummyHyperVProxy,HvRight
                    }
                    foreach ($ProxyObj in $HyperVBackupProxy) {
                        $PROXYHASHTABLE = @{}
                        $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                        node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label; fontname="Segoe Ui"}
                        edge -From DummyHyperVProxy -To $ProxyObj.Name @{constraint="true"; minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                    }
                    Rank $HyperVBackupProxy.Name
                }

                if ($Dir -eq 'LR') {
                    edge $BackupServerInfo.Name -to DummyHyperVProxy @{minlen=3;}
                } else {
                    edge $BackupServerInfo.Name -to DummyHyperVProxy @{minlen=3;}
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}