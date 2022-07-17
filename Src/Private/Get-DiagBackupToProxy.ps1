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

                SubGraph Proxies -Attributes @{Label=' '; style="dashed"; fontsize=18; penwidth=1} {
                    # Node used for subgraph centering
                    node BackupProxy @{Label='Backup Proxies'; fontsize=18; fontname="Comic Sans MS bold"; fontcolor='#005f4b'}
                    if ($VMwareBackupProxy -or $HyperVBackupProxy) {
                        if ($VMwareBackupProxy) {
                            $VirtObjs = Get-VBRServer | Where-Object {$_.Type -eq 'VC'}
                            SubGraph VMwareProxies -Attributes @{Label='VMware Backup Proxies'; style="dashed"; fontsize=18; penwidth=1.5} {
                                foreach ($ProxyObj in ($VMwareBackupProxy | Sort-Object)) {
                                    $PROXYHASHTABLE = @{}
                                    $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                    node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                }
                            }
                            if ($VirtObjs) {
                                SubGraph VCENTERMAIN -Attributes @{Label='VMware vCenter Servers'; style="dashed"; fontsize=18; penwidth=1} {
                                    foreach ($VirtManager in ($VirtObjs | Sort-Object)) {
                                        node $VirtManager.Name @{Label=(Get-NodeIcon -Name $VirtManager.Name -Type 'NoIcon' -Align "Center")}
                                        edge -from VMwareProxies -to $VirtManager.Name @{minlen=2}

                                    }
                                }
                            }
                            edge -from BackupProxy -to VMwareProxies @{minlen=1; style='invis'}
                        }
                        if ($HyperVBackupProxy) {
                            $VirtObjs = Get-VBRServer | Where-Object {$_.Type -eq 'HvCluster'}
                            SubGraph HyperVProxies -Attributes @{Label='Hyper-V Backup Proxies'; style="dashed"; fontsize=18; penwidth=1.5} {
                                foreach ($ProxyObj in ($HyperVBackupProxy | Sort-Object)) {
                                    $PROXYHASHTABLE = @{}
                                    $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                    node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                }
                            }
                            if ($VirtObjs) {
                                SubGraph HVCLUSTERMAIN -Attributes @{Label='Hyper-V Cluster Servers'; style="dashed"; fontsize=18; penwidth=1} {
                                    foreach ($HVCluster in ($VirtObjs | Sort-Object)) {
                                        node $HVCluster.Name @{Label=(Get-NodeIcon -Name $HVCluster.Name -Type 'NoIcon' -Align "Center")}
                                        edge -from ($HyperVBackupProxy.Name | Sort-Object) -to $HVCluster.Name @{minlen=2}

                                    }
                                }
                            }
                            edge -from BackupProxy -to HyperVProxies @{minlen=1; style='invis'}
                        }
                        edge -from $BackupServerInfo.Name -to BackupProxy @{minlen=3}
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