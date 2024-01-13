function Get-DiagBackupToFileProxy {
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
            $FileBackupProxy = Get-VbrBackupProxyInfo -Type 'nas'
            if ($BackupServerInfo) {
                if ($Dir -eq 'LR') {
                    $DiagramLabel = 'File Backup Proxies'
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = 'File Backup Proxies'
                }
                if ($FileBackupProxy) {
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
                        node DummyFileProxy @{Label=$DiagramDummyLabel; fontsize=18; fontname="Segoe Ui Black"; fontcolor='#005f4b'; shape='plain'}
                        if ($Dir -eq "TB") {
                            node FileLeft @{Label='FileLeft'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node FileLeftt @{Label='FileLeftt'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node FileRight @{Label='FileRight'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            edge FileLeft,FileLeftt,DummyFileProxy,FileRight @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                            rank FileLeft,FileLeftt,DummyFileProxy,FileRight
                        }
                        foreach ($ProxyObj in $FileBackupProxy) {
                            $PROXYHASHTABLE = @{}
                            $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                            node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label; fontname="Segoe Ui"}
                            edge -From DummyFileProxy -To $ProxyObj.Name @{constraint="true"; minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        Rank $FileBackupProxy.Name
                    }

                    if ($Dir -eq 'LR') {
                        edge $BackupServerInfo.Name -to DummyFileProxy @{minlen=3;}
                    } else {
                        edge $BackupServerInfo.Name -to DummyFileProxy @{minlen=3;}
                    }
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}