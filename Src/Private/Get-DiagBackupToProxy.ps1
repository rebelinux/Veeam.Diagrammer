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

                SubGraph VMwareProxies -Attributes @{Label='VMware Backup Proxies'; style="dashed"; fontsize=18; penwidth=1.5} {

                    if ($VMwareBackupProxy -or $HyperVBackupProxy) {
                        if ($VMwareBackupProxy) {
                            SubGraph VMwareProxies -Attributes @{Label='VMware Backup Proxies'; style="dashed"; fontsize=18; penwidth=1.5} {
                                foreach ($ProxyObj in $VMwareBackupProxy) {
                                    $PROXYHASHTABLE = @{}
                                    $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                    node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                }
                            }
                            edge -from $BackupServerInfo.Name -to $VMwareBackupProxy.Name @{minlen=3}
                        }
                        if ($HyperVBackupProxy) {
                            SubGraph HyperVProxies -Attributes @{Label='Hyper-V Backup Proxies'; style="dashed"; fontsize=18; penwidth=1.5} {
                                foreach ($ProxyObj in $HyperVBackupProxy) {
                                    $PROXYHASHTABLE = @{}
                                    $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                    node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                                }
                            }
                            edge -from $BackupServerInfo.Name -to $HyperVBackupProxy.Name @{minlen=3}
                        }
                        #Invisible Edge between internal Proxy member used to split content vertically
                        edge -from VMwareProxies -to HyperVProxies @{style="invis"; minlen=0}
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