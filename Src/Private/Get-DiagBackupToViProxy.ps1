function Get-DiagBackupToViProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.28
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
    }

    process {
        try {
            $VMwareBackupProxy = Get-VbrBackupProxyInfo -Type 'vmware'
            if ($BackupServerInfo) {
                if ($VMwareBackupProxy) {

                    $columnSize = & {
                        if (($VMwareBackupProxy | Measure-Object).count -le 1 ) {
                            return 1
                        } else {
                            return 4
                        }
                    }

                    Node ViProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($VMwareBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize $columnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $VMwareBackupProxy.AditionalInfo -Subgraph -SubgraphIconType "VBR_Proxy" -SubgraphLabel "VMware Backup Proxies" -SubgraphLabelFontsize 26 -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -fontSize 18); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                    Edge BackupServers -To ViProxies @{minlen = 2 }
                }

                # vSphere Graphviz Cluster
                if ($vSphereObj = Get-VbrBackupvSphereInfo | Sort-Object) {
                    $VivCenterNodes = @()
                    $VivCenterNodesAll = @()
                    foreach ($vCenter in $vSphereObj) {
                        $vCenterNodeArray = @()
                        $vCenterNodeArrayAll = @()
                        $ViClustersNodes = @()
                        $vCenterNodeArray += $vCenter.Label
                        try {
                            $ViClustersChildsNodes = foreach ($ViCluster in $vCenter.Childs) {
                                if ($ViCluster.EsxiHost.Name) {
                                    Get-DiaHTMLTable -ImagesObj $Images -Rows $ViCluster.EsxiHost.Name -Align 'Center' -ColumnSize 3 -IconDebug $IconDebug -Subgraph -SubgraphIconType "VBR_ESXi_Server" -SubgraphLabel $ViCluster.Name -SubgraphLabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -FontSize 18
                                } else {
                                    Get-DiaHTMLTable -ImagesObj $Images -Rows 'No Esxi Host' -Align 'Center' -ColumnSize 3 -IconDebug $IconDebug -Subgraph -SubgraphIconType "VBR_ESXi_Server" -SubgraphLabel $ViCluster.Name -SubgraphLabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -FontSize 18
                                }
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create vSphere Esxi table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {
                            if ($ViClustersChildsNodes) {
                                $ViClustersNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ViClustersChildsNodes -Align 'Center' -IconDebug $IconDebug -Label 'Clusters' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 20
                                $vCenterNodeArray += $ViClustersNodes
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create vSphere Clusters Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {
                            if ($vCenterNodeArray) {
                                $VivCenterNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $vCenterNodeArray -Align 'Center' -IconDebug $IconDebug -Label 'vCenter Server' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 22
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create vCenter Server Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }

                    try {
                        if ($VivCenterNodes) {
                            $VivCenterNodesAll += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VivCenterNodes -Align 'Center' -IconDebug $IconDebug -Label 'Management Servers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 24
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create vCenter Server Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                if ($vSphereServerObj = Get-VbrBackupvSphereStandAloneInfo | Sort-Object) {

                    $columnSize = & {
                        if (($vSphereServerObj | Measure-Object).count -le 1 ) {
                            return 1
                        } else {
                            return 4
                        }
                    }

                    try {
                        [array]$ViStandAloneNodes = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($vSphereServerObj | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_ESXi_Server" -columnSize $columnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $vSphereServerObj.AditionalInfo -Subgraph -SubgraphLabel " " -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1")
                    } catch {
                        Write-Verbose "Error: Unable to create vSphere StandAlone Table. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    if ($ViStandAloneNodes) {
                        try {
                            $VivCenterNodesAll += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ViStandAloneNodes -Align 'Center' -IconDebug $IconDebug -Label 'ESxi StandAlone Hosts' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $columnSize -fontSize 24
                        } catch {
                            Write-Verbose "Error: Unable to create vSphere StandAlone Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }
                }

                if ($VivCenterNodesAll) {
                    if ($Dir -eq 'LR') {
                        try {
                            $ViClustersSubgraphNode = Node -Name "ViCluster" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VivCenterNodesAll -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_vSphere' -Label 'VMware vSphere Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 26); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                        } catch {
                            Write-Verbose "Error: Unable to create ViCluster Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    } else {
                        try {
                            $ViClustersSubgraphNode = Node -Name "ViCluster" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VivCenterNodesAll -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_vSphere' -Label 'VMware vSphere Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 26); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                        } catch {
                            Write-Verbose "Error: Unable to create ViCluster Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }

                    if ($ViClustersSubgraphNode) {
                        $ViClustersSubgraphNode
                        Edge ViProxies -To ViCluster @{minlen = 2 }
                    }
                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}