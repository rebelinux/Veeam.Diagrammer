function Get-DiagBackupToHvProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.3
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
                if ($BackupServerInfo) {
                    node DummyBackupProxy @{Label='Backup Proxies';fontsize=22; fontname="Segoe Ui Black"; fontcolor='#005f4b'; shape='plain'}
                    if ($HyperVBackupProxy) {
                        $HvClusterObjs = Get-VBRServer | Where-Object {$_.Type -eq 'HvCluster'}
                        $HyperVServerObjs = Get-VBRServer | Where-Object {$_.Type -eq 'HvServer' -and $_.HasParent() -like 'False'}
                        if ($HyperVBackupProxy) {
                            SubGraph HyperVProxies -Attributes @{Label='HyperV Backup Proxies'; style='dashed'; color=$SubGraphDebug.color; fontsize=18; penwidth=1.5} {
                                node HyperVProxyMain @{Label='HyperVProxyMain'; shape='plain'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                foreach ($ProxyObj in ($HyperVBackupProxy | Sort-Object)) {
                                    $PROXYHASHTABLE = @{}
                                    $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                    node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                    edge -From HyperVProxyMain -To $ProxyObj.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                if ($HvClusterObjs -or $HyperVServerObjs) {
                                    # Dummy Node used for subgraph centering (Always hidden)
                                    node HyperVBackupProxyMain @{Label='HyperVBackupProxyMain'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'}
                                    # Edge Lines from HyperV Backup Proxies to Dummy Node HyperVBackupProxyMain
                                    edge -from ($HyperVBackupProxy | Sort-Object).Name -to HyperVBackupProxyMain:n @{style=$EdgeDebug.style; color=$EdgeDebug.color;}
                                }
                            }
                        }
                        if ($HvClusterObjs -or $HyperVServerObjs) {
                            SubGraph HyperVMAIN -Attributes @{Label='HyperV Infrastructure'; style='dashed'; color=$SubGraphDebug.color; fontsize=18; penwidth=1; labelloc='t'} {
                                # Dummy Node used for subgraph centering
                                if ($HyperVServerObjs) {
                                    SubGraph HyperVHostMAIN -Attributes @{Label='HyperV Standalone Servers'; style='dashed'; color=$SubGraphDebug.color; fontsize=18; penwidth=1; labelloc='t'} {
                                        # Dummy Node used for subgraph centering
                                        node HyperVInfraHost @{Label='HyperVInfraHost'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'}
                                        foreach ($HyperVHost in $HyperVServerObjs) {
                                            $HyperVInfo = @{
                                                IP = Get-NodeIP -Hostname $HyperVHost.Name
                                            }
                                            node $HyperVHost.Name @{Label=(Get-NodeIcon -Name $HyperVHost.Name -Type 'VBR_HyperV_Server' -Align "Center" -Rows $HyperVInfo)}
                                            edge -From HyperVInfraHost -To $HyperVHost.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        }
                                    }
                                    edge -from HyperVBackupProxyMain:s -to HyperVInfraHost:n @{minlen=2; style='dashed'}
                                }
                                node HyperVInfraDummy @{Label='HyperVInfraDummy'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='box'}
                                edge -from HyperVBackupProxyMain:s -to HyperVInfraDummy:n @{minlen=2; style=$EdgeDebug.style; color=$EdgeDebug.color}

                                if ($HvClusterObjs) {
                                    SubGraph HyperVClusterMAIN -Attributes @{Label='HyperV Cluster Servers'; style='dashed'; color=$SubGraphDebug.color; fontsize=18; penwidth=1; labelloc='t'} {
                                        # Dummy Node used for subgraph centering
                                        node HyperVInfraCluster @{Label='HyperVInfraCluster'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'}
                                        foreach ($VirtManager in ($HvClusterObjs | Sort-Object)) {
                                            $HyperVClusterInfo = @{
                                                IP = Get-NodeIP -Hostname $VirtManager.Name
                                            }
                                            $HyperVClusterSubGraphName = Remove-SpecialChars -String $VirtManager.Name -SpecialChars '\-. '
                                            SubGraph $HyperVClusterSubGraphName -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                node $VirtManager.Name @{Label=(Get-NodeIcon -Name $VirtManager.Name -Type 'VBR_HyperV_Server' -Align "Center" -Rows $HyperVClusterInfo)}
                                                foreach ($HyperV in $VirtManager.getchilds()) {
                                                    $HyperVInfo = @{
                                                        IP = Get-NodeIP -Hostname $HyperV.Name
                                                    }
                                                    node $HyperV.Name @{Label=(Get-NodeIcon -Name $HyperV.Name -Type 'VBR_HyperV_Server' -Align "Center" -Rows $HyperVInfo)}
                                                    edge -From $VirtManager.Name -To $HyperV.Name @{style='dashed'}
                                                }
                                            }
                                        }
                                    }

                                    # Edge Lines from Dummy Node HyperV Cluster Servers to Dummy Node HyperV Virtual Infrastructure
                                    edge -from HyperVInfraCluster -to $HvClusterObjs.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    # Edge Lines from Dummy Node HyperV Virtual Infrastructure to Dummy Node HyperV Cluster Servers
                                    edge -from HyperVBackupProxyMain:s -to HyperVInfraCluster:n @{minlen=2; style='dashed'}
                                }
                            }
                        }
                    }
                    edge -from $BackupServerInfo.Name -to DummyBackupProxy:n @{minlen=2}

                    if ($HyperVBackupProxy) {
                        edge -from DummyBackupProxy:s -to HyperVProxyMain:n @{minlen=2; style=$EdgeDebug.style; color=$EdgeDebug.color}
                    }
                }
        }
        catch {
            $_
        }
    }
    end {}
}