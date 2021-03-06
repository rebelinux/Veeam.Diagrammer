function Get-DiagBackupToProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.0.2
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
            $VMwareBackupProxy = Get-VbrBackupProxyInfo -Type 'vmware'
            $HyperVBackupProxy = Get-VbrBackupProxyInfo -Type 'hyperv'
            if ($BackupServerInfo) {
                if ($VMwareBackupProxy -or $HyperVBackupProxy) {
                    # Dummy Node used for subgraph centering
                    node BackupProxy @{Label='Backup Proxies'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                    SubGraph Proxies -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                        if ($VMwareBackupProxy) {
                            $VirtObjs = Get-VBRServer | Where-Object {$_.Type -eq 'VC'}
                            $EsxiObjs = Get-VBRServer | Where-Object {$_.Type -eq 'Esxi' -and $_.IsStandaloneEsx() -eq 'True'}
                            SubGraph VMwareProxies -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1.5} {
                                node VMwareProxyMain @{Label='VMware Backup Proxies'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                foreach ($ProxyObj in ($VMwareBackupProxy | Sort-Object)) {
                                    $PROXYHASHTABLE = @{}
                                    $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                    node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                    edge -From VMwareProxyMain -To $ProxyObj.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                if ($VirtObjs) {
                                    # Dummy Node used for subgraph centering (Always hidden)
                                    node VMWAREBackupProxyMain @{Label='VMWAREBackupProxyMain';shape='plain'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                            }
                            # Dummy Edge used for subgraph centering (Always hidden)
                            edge -from BackupProxy -to VMwareProxyMain @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                            if ($VirtObjs -or $EsxiObjs) {
                                SubGraph vSphereMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                    node vSphereVirtualInfrastructure @{Label='vSphere Virtual Infrastructure'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                    if ($EsxiObjs) {
                                        SubGraph ESXiMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            # Dummy Node used for subgraph centering
                                            node ESXiBackupProxy @{Label='Esxi Standalone Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                            foreach ($ESxiHost in $EsxiObjs) {
                                                node $ESxiHost.Name @{Label=(Get-NodeIcon -Name $ESxiHost.Name -Type 'VBR_ESXi_Server' -Align "Center")}
                                                edge -From ESXiBackupProxy -To $ESxiHost.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                            }
                                        }
                                        edge -from vSphereVirtualInfrastructure -to ESXiBackupProxy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    }
                                    if ($VirtObjs) {
                                        SubGraph VCENTERMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            # Dummy Node used for subgraph centering
                                            node vCenterServers @{Label='VMware vCenter Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                            foreach ($VirtManager in ($VirtObjs | Sort-Object)) {
                                                $vCenterSubGraphName = Remove-SpecialChars -String $VirtManager.Name -SpecialChars '\-. '
                                                SubGraph $vCenterSubGraphName -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                    node $VirtManager.Name @{Label=(Get-NodeIcon -Name $VirtManager.Name -Type 'VBR_vCenter_Server' -Align "Center")}
                                                    foreach ($ESXi in $VirtManager.getchilds()) {
                                                        node $ESXi.Name @{Label=(Get-NodeIcon -Name $ESXi.Name -Type 'VBR_ESXi_Server' -Align "Center")}
                                                        edge -From $VirtManager.Name -To $ESXi.Name @{minlen=2; style='dashed'}
                                                    }
                                                }
                                            }
                                        }
                                        # Edge Lines from VMware Backup Proxies to Dummy Node VMWAREBackupProxyMain
                                        edge -from ($VMwareBackupProxy | Sort-Object).Name -to VMWAREBackupProxyMain @{style=$EdgeDebug.style; color=$EdgeDebug.color; minlen=1}
                                        # Edge Lines from Dummy Node VMWAREBackupProxyMain to Dummy Node vSphere Virtual Infrastructure
                                        edge -From VMWAREBackupProxyMain -To vSphereVirtualInfrastructure @{minlen=2; style="dashed"; fontsize=18; penwidth=1}
                                        # Edge Lines from Dummy Node vCenter Servers to Dummy Node vSphere Virtual Infrastructure
                                        edge -from vCenterServers -to $VirtObjs.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        # Edge Lines from Dummy Node vSphere Virtual Infrastructure to Dummy Node vCenter Servers
                                        edge -from vSphereVirtualInfrastructure -to vCenterServers @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    }
                                }
                            }
                        }
                        if ($HyperVBackupProxy) {
                            $VirtObjs = Get-VBRServer | Where-Object {$_.Type -eq 'HvCluster'}
                            $HyperVObjs = Get-VBRServer | Where-Object {$_.Type -eq 'HvServer' -and $_.HasParent() -like 'False'}
                            SubGraph HyperVProxies -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1.5} {
                                node HyperVProxyMain @{Label='HyperV Backup Proxies'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                foreach ($ProxyObj in ($HyperVBackupProxy | Sort-Object)) {
                                    $PROXYHASHTABLE = @{}
                                    $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                    node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                    edge -From HyperVProxyMain -To $ProxyObj.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                if ($VirtObjs) {
                                    # Dummy Node used for subgraph centering (Always hidden)
                                    node HyperVBackupProxyMain @{Label='HyperVBackupProxyMain';shape='plain'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                            }
                            # Dummy Edge used for subgraph centering (Always hidden)
                            edge -from BackupProxy -to HyperVProxyMain @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                            if ($VirtObjs -or $HyperVObjs) {
                                SubGraph HyperVMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                    node HyperVVirtualInfrastructure @{Label='HyperV Virtual Infrastructure'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                    if ($HyperVObjs) {
                                        SubGraph HyperVHostMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            # Dummy Node used for subgraph centering
                                            node HyperVHostBackupProxy @{Label='HyperV Standalone Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                            foreach ($HyperVHost in $HyperVObjs) {
                                                node $HyperVHost.Name @{Label=(Get-NodeIcon -Name $HyperVHost.Name -Type 'VBR_HyperV_Server' -Align "Center")}
                                                edge -From HyperVHostBackupProxy -To $HyperVHost.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                            }
                                        }
                                        edge -from HyperVVirtualInfrastructure -to HyperVHostBackupProxy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    }
                                    if ($VirtObjs) {
                                        SubGraph HyperVClusterMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            # Dummy Node used for subgraph centering
                                            node HyperVClusterServers @{Label='HyperV Cluster Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                            foreach ($VirtManager in ($VirtObjs | Sort-Object)) {
                                                $HyperVClusterSubGraphName = Remove-SpecialChars -String $VirtManager.Name -SpecialChars '\-. '
                                                SubGraph $HyperVClusterSubGraphName -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                    node $VirtManager.Name @{Label=(Get-NodeIcon -Name $VirtManager.Name -Type 'VBR_HyperV_Server' -Align "Center")}
                                                    foreach ($HyperV in $VirtManager.getchilds()) {
                                                        node $HyperV.Name @{Label=(Get-NodeIcon -Name $HyperV.Name -Type 'VBR_HyperV_Server' -Align "Center")}
                                                        edge -From $VirtManager.Name -To $HyperV.Name @{minlen=2; style='dashed'}
                                                    }
                                                }
                                            }
                                        }
                                        # Edge Lines from HyperV Backup Proxies to Dummy Node HyperVBackupProxyMain
                                        edge -from ($HyperVBackupProxy | Sort-Object).Name -to HyperVBackupProxyMain @{style=$EdgeDebug.style; color=$EdgeDebug.color; minlen=1}
                                        # Edge Lines from Dummy Node HyperVBackupProxyMain to Dummy Node HyperV Virtual Infrastructure
                                        edge -From HyperVBackupProxyMain -To HyperVVirtualInfrastructure @{minlen=2; style="dashed"; fontsize=18; penwidth=1}
                                        # Edge Lines from Dummy Node HyperV Cluster Servers to Dummy Node HyperV Virtual Infrastructure
                                        edge -from HyperVClusterServers -to $VirtObjs.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        # Edge Lines from Dummy Node HyperV Virtual Infrastructure to Dummy Node HyperV Cluster Servers
                                        edge -from HyperVVirtualInfrastructure -to HyperVClusterServers @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    }
                                }
                            }
                        }
                        edge -from $BackupServerInfo.Name -to BackupProxy @{minlen=2}
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