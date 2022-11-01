function Get-DiagBackupToProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.4.0
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
                node DummyBackupProxy @{Label='Backup Proxies';fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                if ($VMwareBackupProxy -or $HyperVBackupProxy) {
                    SubGraph Proxies -Attributes @{Label=' '; style='dashed'; color=$SubGraphDebug.color; fontsize=22; penwidth=1} {
                        if ($VMwareBackupProxy) {
                            SubGraph VMware -Attributes @{Label=' '; style='dashed'; color=$SubGraphDebug.color; fontsize=18; penwidth=1.5} {
                                $VirtObjs = Get-VBRServer | Where-Object {$_.Type -eq 'VC'}
                                $EsxiObjs = Get-VBRServer | Where-Object {$_.Type -eq 'Esxi' -and $_.IsStandaloneEsx() -eq 'True'}
                                SubGraph VMwareProxies -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1.5} {
                                    node VMwareProxyMain @{Label='VMware Backup Proxies'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                    foreach ($ProxyObj in ($VMwareBackupProxy | Sort-Object)) {
                                        $PROXYHASHTABLE = @{}
                                        $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                        node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                        edge -From VMwareProxyMain -To $ProxyObj.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    }
                                    if ($VirtObjs -or $EsxiObjs) {
                                        # Dummy Node used for subgraph centering (Always hidden)
                                        node VMWAREBackupProxyMain @{Label='VMWAREBackupProxyMain';shape='plain'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        # Edge Lines from VMware Backup Proxies to Dummy Node VMWAREBackupProxyMain
                                        edge -from ($VMwareBackupProxy | Sort-Object).Name -to VMWAREBackupProxyMain @{style=$EdgeDebug.style; color=$EdgeDebug.color;}
                                    }
                                }

                                if ($VirtObjs -or $EsxiObjs) {
                                    SubGraph vSphereMAIN -Attributes @{Label=' '; fontsize=18; penwidth=1} {
                                        node vSphereVirtualInfrastructure @{Label='vSphere Virtual Infrastructure'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                        # Edge Lines from Dummy Node VMWAREBackupProxyMain to Dummy Node vSphere Virtual Infrastructure
                                        edge -From VMWAREBackupProxyMain -To vSphereVirtualInfrastructure @{style="dashed"; fontsize=18; penwidth=1}
                                        if ($EsxiObjs) {
                                            if ($EsxiObjs.count -le 4) {
                                                SubGraph ESXiMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                    # Dummy Node used for subgraph centering
                                                    node ESXiBackupProxy @{Label='Esxi Standalone Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                                    foreach ($ESxiHost in $EsxiObjs) {
                                                        $ESXiInfo = @{
                                                            Version = $ESxiHost.Info.ViVersion.ToString()
                                                            IP = $ESxiHost.getManagmentAddresses().IPAddressToString
                                                        }
                                                        node $ESxiHost.Name @{Label=(Get-NodeIcon -Name $ESxiHost.Name -Type 'VBR_ESXi_Server' -Align "Center" -Rows $ESXiInfo)}
                                                        edge -From ESXiBackupProxy -To $ESxiHost.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                                    }
                                                }
                                                edge -from vSphereVirtualInfrastructure -to ESXiBackupProxy @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                            }
                                            else {
                                                SubGraph ESXiMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                    # Dummy Node used for subgraph centering
                                                    node ESXiBackupProxy @{Label='Esxi Standalone Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                                    $Group = Split-array -inArray $EsxiObjs -size 4
                                                    $Number = 0
                                                    while ($Number -ne $Group.Length) {
                                                        SubGraph "SAESXiGroup$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                            $Group[$Number] | ForEach-Object { node $_.Name @{Label=(Get-NodeIcon -Name $_.Name -Type 'VBR_ESXi_Server' -Align "Center" -Rows ($ESXiInfo = @{Version = $_.Info.ViVersion.ToString(); IP = $_.getManagmentAddresses().IPAddressToString})) }}
                                                        }
                                                        $Number++
                                                    }
                                                    edge -From ESXiBackupProxy -To $Group[0].Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                                    $Start = 0
                                                    $ESXiNum = 1
                                                    while ($ESXiNum -ne $Group.Length) {
                                                        edge -From $Group[$Start].Name -To $Group[$ESXiNum].Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                                        $Start++
                                                        $ESXiNum++
                                                    }
                                                }
                                                edge -from vSphereVirtualInfrastructure -to ESXiBackupProxy @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                            }
                                        }
                                        if ($VirtObjs) {
                                            SubGraph VCENTERMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                # Dummy Node used for subgraph centering
                                                node vCenterServers @{Label='VMware vCenter Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                                foreach ($VirtManager in ($VirtObjs | Sort-Object)) {
                                                    $VCInfo = @{
                                                        Version = $VirtManager.Info.ViVersion.ToString()
                                                        IP = $VirtManager.getManagmentAddresses().IPAddressToString
                                                    }
                                                    $vCenterSubGraphName = Remove-SpecialChars -String $VirtManager.Name -SpecialChars '\-. '
                                                    SubGraph $vCenterSubGraphName -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                        node $VirtManager.Name @{Label=(Get-NodeIcon -Name $VirtManager.Name -Type 'VBR_vCenter_Server' -Align "Center" -Rows $VCInfo)}
                                                        # foreach ($ESXi in $VirtManager.getchilds()) {
                                                        if ($VirtManager.getchilds().Length -le 4) {
                                                            # Dummy Node used for subgraph centering
                                                            foreach ($ESXi in $VirtManager.getchilds()) {
                                                                $ESXiInfo = @{
                                                                    Version = $ESxi.Info.ViVersion.ToString()
                                                                    IP = $ESxi.getManagmentAddresses().IPAddressToString
                                                                }
                                                                node $ESXi.Name @{Label=(Get-NodeIcon -Name $ESXi.Name -Type 'VBR_ESXi_Server' -Align "Center" -Rows $ESXiInfo)}
                                                                edge -From $VirtManager.Name -To $ESXi.Name @{style='dashed'}
                                                            }
                                                        }
                                                        else {
                                                            $EsxiHosts = $VirtManager.getchilds()
                                                            $Group = Split-array -inArray $EsxiHosts -size 4
                                                            $Number = 0
                                                            while ($Number -ne $Group.Length) {
                                                                SubGraph "ESXiGroup$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                                    $Group[$Number] | ForEach-Object { node $_.Name @{Label=(Get-NodeIcon -Name $_.Name -Type 'VBR_ESXi_Server' -Align "Center" -Rows ($ESXiInfo = @{Version = $_.Info.ViVersion.ToString(); IP = $_.getManagmentAddresses().IPAddressToString}))}}
                                                                }
                                                                $Number++
                                                            }
                                                            edge -From $VirtManager.Name -To $Group[0].Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                                            $Start = 0
                                                            $ESXiNum = 1
                                                            while ($ESXiNum -ne $Group.Length) {
                                                                edge -From $Group[$Start].Name -To $Group[$ESXiNum].Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                                                $Start++
                                                                $ESXiNum++
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            # Edge Lines from Dummy Node vCenter Servers to Dummy Node vSphere Virtual Infrastructure
                                            edge -from vCenterServers -to $VirtObjs.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                            # Edge Lines from Dummy Node vSphere Virtual Infrastructure to Dummy Node vCenter Servers
                                            edge -from vSphereVirtualInfrastructure -to vCenterServers @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        }
                                    }
                                }
                            }
                        }
                        if ($HyperVBackupProxy) {
                            SubGraph HyperV -Attributes @{Label=' '; style='dashed'; color=$SubGraphDebug.color; fontsize=18; penwidth=1.5} {
                                $VirtObjs = Get-VBRServer | Where-Object {$_.Type -eq 'HvCluster'}
                                $HyperVObjs = Get-VBRServer | Where-Object {$_.Type -eq 'HvServer' -and $_.HasParent() -like 'False'}
                                SubGraph HyperVProxies -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1.5} {
                                    node HyperVProxyMain @{Label='HyperV Backup Proxies'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                    foreach ($ProxyObj in ($HyperVBackupProxy | Sort-Object)) {
                                        $PROXYHASHTABLE = @{}
                                        $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                        node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                        edge -From HyperVProxyMain -To $ProxyObj.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    }
                                    if ($VirtObjs -or $HyperVObjs) {
                                        # Dummy Node used for subgraph centering (Always hidden)
                                        node HyperVBackupProxyMain @{Label='HyperVBackupProxyMain';shape='plain'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    }
                                }

                                if ($VirtObjs -or $HyperVObjs) {
                                    SubGraph HyperVMAIN -Attributes @{Label=' '; fontsize=18; penwidth=1} {
                                        node HyperVVirtualInfrastructure @{Label='HyperV Virtual Infrastructure'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                        if ($HyperVObjs) {
                                            SubGraph HyperVHostMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                # Dummy Node used for subgraph centering
                                                node HyperVHostBackupProxy @{Label='HyperV Standalone Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                                foreach ($HyperVHost in $HyperVObjs) {
                                                    $HyperVInfo = @{
                                                        IP = Get-NodeIP -Hostname $HyperVHost.Name
                                                    }
                                                    node $HyperVHost.Name @{Label=(Get-NodeIcon -Name $HyperVHost.Name -Type 'VBR_HyperV_Server' -Align "Center" -Rows $HyperVInfo)}
                                                    edge -From HyperVHostBackupProxy -To $HyperVHost.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                                }
                                            }
                                            edge -from HyperVVirtualInfrastructure -to HyperVHostBackupProxy @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        }
                                        if ($VirtObjs) {
                                            SubGraph HyperVClusterMAIN -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                # Dummy Node used for subgraph centering
                                                node HyperVClusterServers @{Label='HyperV Cluster Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                                foreach ($VirtManager in ($VirtObjs | Sort-Object)) {
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
                                            # Edge Lines from HyperV Backup Proxies to Dummy Node HyperVBackupProxyMain
                                            edge -from ($HyperVBackupProxy | Sort-Object).Name -to HyperVBackupProxyMain @{style=$EdgeDebug.style; color=$EdgeDebug.color;}
                                            # Edge Lines from Dummy Node HyperVBackupProxyMain to Dummy Node HyperV Virtual Infrastructure
                                            edge -From HyperVBackupProxyMain -To HyperVVirtualInfrastructure @{style="dashed"; fontsize=18; penwidth=1}
                                            # Edge Lines from Dummy Node HyperV Cluster Servers to Dummy Node HyperV Virtual Infrastructure
                                            edge -from HyperVClusterServers -to $VirtObjs.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                            # Edge Lines from Dummy Node HyperV Virtual Infrastructure to Dummy Node HyperV Cluster Servers
                                            edge -from HyperVVirtualInfrastructure -to HyperVClusterServers @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
                edge -from $BackupServerInfo.Name -to DummyBackupProxy @{minlen=2}
                if ($VMwareBackupProxy) {
                    edge -from DummyBackupProxy -to VMware @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                }
                if ($HyperVBackupProxy) {
                    edge -from DummyBackupProxy -to HyperV @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                }

            }
        }
        catch {
            $_
        }
    }
    end {}
}