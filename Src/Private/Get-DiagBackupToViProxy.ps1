function Get-DiagBackupToViProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.36
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]

    param
    (

    )

    begin {
    }

    process {
        try {
            $VMwareBackupProxy = Get-VbrBackupProxyInfo -Type 'vmware'
            if ($BackupServerInfo) {
                if ($VMwareBackupProxy) {

                    if ($VMwareBackupProxy.Name.Count -eq 1) {
                        $VMwareBackupProxyColumnSize = 1
                    } elseif ($ColumnSize) {
                        $VMwareBackupProxyColumnSize = $ColumnSize
                    } else {
                        $VMwareBackupProxyColumnSize = $VMwareBackupProxy.Name.Count
                    }

                    Node ViProxies @{Label = (Add-DiaHtmlNodeTable -ImagesObj $Images -inputObject ($VMwareBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize $VMwareBackupProxyColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $VMwareBackupProxy.AditionalInfo -Subgraph -SubgraphIconType "VBR_Proxy" -SubgraphLabel "VMware Backup Proxies" -SubgraphLabelFontsize 26 -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -fontSize 18); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                    Edge BackupServers -To ViProxies @{minlen = 2 }
                }

                # vSphere Graphviz Cluster
                if ($vSphereObj = Get-VbrBackupvSphereInfo | Sort-Object) {
                    $VivCenterNodes = @()
                    $VivCenterNodesAll = @()
                    foreach ($vCenter in $vSphereObj) {
                        $vCenterNodeArray = @()
                        $ViClustersNodes = @()
                        $vCenterNodeArray += $vCenter.Label
                        try {
                            $ViClustersChildsNodes = foreach ($ViCluster in $vCenter.Childs) {
                                if ($ViCluster.EsxiHost.Name.Count -eq 1) {
                                    $ViClustersChildsNodesColumnSize = 1
                                } elseif ($ColumnSize) {
                                    $ViClustersChildsNodesColumnSize = $ColumnSize
                                } else {
                                    $ViClustersChildsNodesColumnSize = $ViCluster.EsxiHost.Name.Count
                                }
                                if ($ViCluster.EsxiHost.Name) {
                                    Add-DiaHtmlTable -ImagesObj $Images -Rows $ViCluster.EsxiHost.Name -Align 'Center' -ColumnSize $ViClustersChildsNodesColumnSize -IconDebug $IconDebug -Subgraph -SubgraphIconType "VBR_ESXi_Server" -SubgraphLabel $ViCluster.Name -SubgraphLabelPos "top" -FontColor '#000000' -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -FontSize 18
                                } else {
                                    Add-DiaHtmlTable -ImagesObj $Images -Rows 'No Esxi Host' -Align 'Center' -ColumnSize $ViClustersChildsNodesColumnSize -IconDebug $IconDebug -Subgraph -SubgraphIconType "VBR_ESXi_Server" -SubgraphLabel $ViCluster.Name -SubgraphLabelPos "top" -FontColor '#000000' -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -FontSize 18
                                }
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create vSphere Esxi table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {
                            if ($ViClustersChildsNodes) {
                                if ($ViClustersChildsNodes.Count -eq 1) {
                                    $ViClustersChildsNodesColumnSize = 1
                                } elseif ($ColumnSize) {
                                    $ViClustersChildsNodesColumnSize = $ColumnSize
                                } else {
                                    $ViClustersChildsNodesColumnSize = $ViClustersChildsNodes.Count
                                }
                                $ViClustersNodes += Add-DiaHtmlSubGraph -ImagesObj $Images -TableArray $ViClustersChildsNodes -Align 'Center' -IconDebug $IconDebug -Label 'Clusters' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $ViClustersChildsNodesColumnSize -fontSize 20
                                $vCenterNodeArray += $ViClustersNodes
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create vSphere Clusters Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {
                            if ($vCenterNodeArray) {
                                $VivCenterNodes += Add-DiaHtmlSubGraph -ImagesObj $Images -TableArray $vCenterNodeArray -Align 'Center' -IconDebug $IconDebug -Label 'vCenter Server' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 22
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create vCenter Server Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }

                    try {
                        if ($VivCenterNodes) {
                            if ($VivCenterNodes.Count -eq 1) {
                                $VivCenterNodesColumnSize = 1
                            } elseif ($ColumnSize) {
                                $VivCenterNodesColumnSize = $ColumnSize
                            } else {
                                $VivCenterNodesColumnSize = $VivCenterNodes.Count
                            }
                            $VivCenterNodesAll += Add-DiaHtmlSubGraph -ImagesObj $Images -TableArray $VivCenterNodes -Align 'Center' -IconDebug $IconDebug -Label 'Management Servers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $VivCenterNodesColumnSize -fontSize 24
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create vCenter Server Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                if ($vSphereServerObj = Get-VbrBackupvSphereStandAloneInfo | Sort-Object) {

                    if ($vSphereServerObj.Name.Count -le 1) {
                        $vSphereServerObjColumnSize = 1
                    } elseif ($ColumnSize) {
                        $vSphereServerObjColumnSize = $ColumnSize
                    } else {
                        $vSphereServerObjColumnSize = $vSphereServerObj.Name.Count
                    }

                    try {
                        [array]$ViStandAloneNodes = (Add-DiaHtmlNodeTable -ImagesObj $Images -inputObject ($vSphereServerObj | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_ESXi_Server" -columnSize $vSphereServerObjColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $vSphereServerObj.AditionalInfo -Subgraph -SubgraphLabel "Host" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1")
                    } catch {
                        Write-Verbose "Error: Unable to create vSphere StandAlone Table. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    if ($ViStandAloneNodes) {
                        try {
                            $VivCenterNodesAll += Add-DiaHtmlSubGraph -ImagesObj $Images -TableArray $ViStandAloneNodes -Align 'Center' -IconDebug $IconDebug -Label 'ESxi StandAlone Hosts' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 24
                        } catch {
                            Write-Verbose "Error: Unable to create vSphere StandAlone Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }
                }

                if ($VivCenterNodesAll) {

                    if ($Dir -eq 'LR') {
                        try {
                            $ViClustersSubgraphNode = Node -Name "ViCluster" -Attributes @{Label = (Add-DiaHtmlSubGraph -ImagesObj $Images -TableArray $VivCenterNodesAll -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_vSphere' -Label 'VMware vSphere Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 26); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                        } catch {
                            Write-Verbose "Error: Unable to create ViCluster Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    } else {
                        try {
                            $ViClustersSubgraphNode = Node -Name "ViCluster" -Attributes @{Label = (Add-DiaHtmlSubGraph -ImagesObj $Images -TableArray $VivCenterNodesAll -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_vSphere' -Label 'VMware vSphere Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 26); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
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