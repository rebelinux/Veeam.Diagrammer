function Get-DiagBackupToViProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.1
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
            $VMwareBackupProxy = Get-VbrBackupProxyInfo -Type 'vmware'
            if ($BackupServerInfo) {
                if ($VMwareBackupProxy) {
                    $ProxiesAttr = @{
                        Label = 'VMware Backup Proxies'
                        fontsize = 18
                        penwidth = 1.5
                        labelloc = 'b'
                        color = $SubGraphDebug.color
                        style = 'dashed,rounded'
                    }
                    SubGraph MainSubGraph -Attributes $ProxiesAttr -ScriptBlock {

                        Node ViProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($VMwareBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($VMwareBackupProxy.AditionalInfo )); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }

                    }

                    Edge $BackupServerInfo.Name -To ViProxies:n @{minlen = 3 }

                    # $VirtObjs = Get-VBRServer | Where-Object {$_.Type -eq 'VC'}
                    # $EsxiObjs = Get-VBRServer | Where-Object {$_.Type -eq 'Esxi' -and $_.IsStandaloneEsx() -eq 'True'}
                    # SubGraph MainVMwareProxies -Attributes @{Label=$DiagramLabel; style='dashed,rounded'; color=$SubGraphDebug.color; fontsize=18; penwidth=1.5} {
                    #     node DummyVMwareProxy @{Label='VMwareProxyMain'; shape='plain'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                    #     foreach ($ProxyObj in ($VMwareBackupProxy | Sort-Object)) {
                    #         $PROXYHASHTABLE = @{}
                    #         $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                    #         node $ProxyObj -NodeScript {$_.Name} @{Label=$PROXYHASHTABLE.Label}
                    #         edge -From DummyVMwareProxy -To $ProxyObj.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                    #     }
                    #     # if ($VirtObjs -or $EsxiObjs) {
                    #     #     # Dummy Node used for subgraph centering (Always hidden)
                    #     #     node VMWAREBackupProxyMain @{Label='VMWAREBackupProxyMain'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'}
                    #     #     # Edge Lines from VMware Backup Proxies to Dummy Node VMWAREBackupProxyMain
                    #     #     edge -from ($VMwareBackupProxy | Sort-Object).Name -to VMWAREBackupProxyMain:n @{style=$EdgeDebug.style; color=$EdgeDebug.color;}
                    #     # }
                    # }

                    # if ($VirtObjs -or $EsxiObjs) {
                    #     SubGraph vSphereMAIN -Attributes @{Label='vSphere Infrastructure'; style='dashed,rounded'; color=$SubGraphDebug.color; penwidth=1} {
                    #         if ($EsxiObjs) {
                    #             SubGraph ESXiMAIN -Attributes @{Label='Standalone Servers'; style='dashed,rounded'; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                    #                 # Dummy Node used for subgraph centering
                    #                 node ESXiBackupProxy @{Label='ESXiBackupProxy'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'}
                    #                 if (($EsxiObjs | Measure-Object).count -le 4) {
                    #                     foreach ($ESxiHost in $EsxiObjs) {
                    #                         $ESXiInfo = @{
                    #                             Version = $ESxiHost.Info.ViVersion.ToString()
                    #                             IP = try {$ESxiHost.getManagmentAddresses().IPAddressToString} catch {"Unknown"}
                    #                         }
                    #                         node $ESxiHost.Name @{Label=(Get-NodeIcon -Name $ESxiHost.Name -IconType 'VBR_ESXi_Server' -Align "Center" -Rows $ESXiInfo)}
                    #                         edge -From ESXiBackupProxy:s -To $ESxiHost.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                    #                     }
                    #                 }
                    #                 else {
                    #                     $Group = Split-array -inArray $EsxiObjs -size 4
                    #                     $Number = 0
                    #                     while ($Number -ne $Group.Length) {
                    #                         $Random = Get-Random
                    #                         SubGraph "SAESXiGroup$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                    #                             $Group[$Number] | ForEach-Object { node $_.Name @{Label=(Get-NodeIcon -Name $_.Name -IconType 'VBR_ESXi_Server' -Align "Center" -Rows ($ESXiInfo = @{Version = $_.Info.ViVersion.ToString(); IP = try {$_.getManagmentAddresses().IPAddressToString} catch {"Unknown"}})) }}
                    #                         }
                    #                         $Number++
                    #                     }
                    #                     edge -From ESXiBackupProxy:n -To $Group[0].Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                    #                     $Start = 0
                    #                     $ESXiNum = 1
                    #                     while ($ESXiNum -ne $Group.Length) {
                    #                         edge -From $Group[$Start].Name -To $Group[$ESXiNum].Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                    #                         $Start++
                    #                         $ESXiNum++
                    #                     }
                    #                 }
                    #             }
                    #             if ($EsxiObjs) {
                    #                 edge -from vSphereInfraDummy:s -to ESXiBackupProxy:n @{minlen=2; style='dashed'}
                    #             }
                    #         }

                    #         # Dummy Node used for subgraph centering
                    #         node vSphereInfraDummy @{Label='vSphereInfraDummy'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='box'}
                    #         edge -from VMWAREBackupProxyMain:s -to vSphereInfraDummy:n @{minlen=2; style=$EdgeDebug.style; color=$EdgeDebug.color}

                    #         if ($VirtObjs) {
                    #             SubGraph VCENTERMAIN -Attributes @{Label='VMware vCenter Servers'; style='dashed,rounded'; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                    #                 # Dummy Node used for subgraph centering
                    #                 node vCenterServers @{Label='vCenterServers'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'}
                    #                 foreach ($VirtManager in ($VirtObjs | Sort-Object)) {
                    #                     $VCInfo = @{
                    #                         Version = $VirtManager.Info.ViVersion.ToString()
                    #                         IP = try {$VirtManager.getManagmentAddresses().IPAddressToString} catch {"Unknown"}
                    #                     }
                    #                     $vCenterSubGraphName = Remove-SpecialChar -String $VirtManager.Name -SpecialChars '\-. '
                    #                     SubGraph $vCenterSubGraphName -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                    #                         node $VirtManager.Name @{Label=(Get-NodeIcon -Name $VirtManager.Name -IconType 'VBR_vCenter_Server' -Align "Center" -Rows $VCInfo)}
                    #                         # foreach ($ESXi in $VirtManager.getchilds()) {
                    #                         if ($VirtManager.getchilds().Length -le 4) {
                    #                             # Dummy Node used for subgraph centering
                    #                             foreach ($ESXi in $VirtManager.getchilds()) {
                    #                                 $ESXiInfo = @{
                    #                                     Version = $ESxi.Info.ViVersion.ToString()
                    #                                     IP = try {$ESxi.getManagmentAddresses().IPAddressToString} catch {"Unknown"}
                    #                                 }
                    #                                 node $ESXi.Name @{Label=(Get-NodeIcon -Name $ESXi.Name -IconType 'VBR_ESXi_Server' -Align "Center" -Rows $ESXiInfo)}
                    #                                 edge -From "$($VirtManager.Name):s" -To $ESXi.Name @{style='dashed'}
                    #                             }
                    #                         }
                    #                         else {
                    #                             $EsxiHosts = $VirtManager.getchilds()
                    #                             $Group = Split-array -inArray $EsxiHosts -size 4
                    #                             $Number = 0
                    #                             while ($Number -ne $Group.Length) {
                    #                                 $Random = Get-Random
                    #                                 SubGraph "ESXiGroup$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                    #                                     $Group[$Number] | ForEach-Object { node $_.Name @{Label=(Get-NodeIcon -Name $_.Name -IconType 'VBR_ESXi_Server' -Align "Center" -Rows ($ESXiInfo = @{Version = $_.Info.ViVersion.ToString(); IP = try {$_.getManagmentAddresses().IPAddressToString} catch {"Unknown"}}))}}
                    #                                 }
                    #                                 $Number++
                    #                             }
                    #                             edge -From $VirtManager.Name -To $Group[0].Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                    #                             $Start = 0
                    #                             $ESXiNum = 1
                    #                             while ($ESXiNum -ne $Group.Length) {
                    #                                 edge -From $Group[$Start].Name -To $Group[$ESXiNum].Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                    #                                 $Start++
                    #                                 $ESXiNum++
                    #                             }
                    #                         }
                    #                     }
                    #                 }
                    #             }
                    #             # Edge Lines from Dummy Node vCenter Servers to Dummy Node vSphere Virtual Infrastructure
                    #             edge -from vCenterServers:s -to $VirtObjs.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                    #             # Edge Lines from Dummy Node vSphere Virtual Infrastructure to Dummy Node vCenter Servers
                    #             edge -from vSphereInfraDummy:s -to vCenterServers:n @{minlen=2; style='dashed'}
                    #         }
                    #     }
                    # }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}