function Get-DiagBackupToHvProxy {
    <#
    .SYNOPSIS
        Function to build Backup Server to Proxy diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.26
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
            $HyperVBackupProxy = Get-VbrBackupProxyInfo -Type 'hyperv'
            if ($HyperVBackupProxy) {

                $columnSize = & {
                    if (($HyperVBackupProxy | Measure-Object).count -le 1 ) {
                        return 1
                    } else {
                        return 4
                    }
                }

                Node HvProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($HyperVBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize $columnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $HyperVBackupProxy.AditionalInfo -Subgraph -SubgraphIconType "VBR_HyperV" -SubgraphLabel "Hyper-V Backup Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -fontSize 18 -SubgraphLabelFontsize 22); shape = 'plain'; fontsize = 18; fontname = "Segoe Ui" }

                Edge BackupServers -To HvProxies @{minlen = 3 }
            }

            # Hyper-V Graphviz Cluster
            if ($vSphereObj = Get-VbrBackupHyperVClusterInfo | Sort-Object) {
                $VivCenterNodes = @()
                $VivCenterNodesAll = @()
                foreach ($vCenter in $vSphereObj) {
                    $vCenterNodeArray = @()
                    $ViClustersNodes = @()
                    $vCenterNodeArray += $vCenter.Label
                    try {
                        $ViClustersChildsNodes = Get-DiaHTMLTable -ImagesObj $Images -Rows $vCenter.Childs.Name -Align 'Center' -ColumnSize 3 -IconDebug $IconDebug -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -fontSize 18
                    } catch {
                        Write-Verbose "Error: Unable to create Hyper-V Hosts table Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                    try {
                        if ($ViClustersChildsNodes) {
                            $ViClustersNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ViClustersChildsNodes -Align 'Center' -IconDebug $IconDebug -Label 'Hosts' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 18
                            $vCenterNodeArray += $ViClustersNodes
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create Hyper-V Hosts Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                    try {
                        if ($vCenterNodeArray) {
                            $VivCenterNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $vCenterNodeArray -Align 'Center' -IconDebug $IconDebug -Label 'Cluster Servers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 20
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create Hyper-V Cluster Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                try {
                    if ($vCenterNodeArray) {
                        $VivCenterNodesAll += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VivCenterNodes -Align 'Center' -IconDebug $IconDebug -Label 'Hyper-V Clusters' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 22
                    }
                } catch {
                    Write-Verbose "Error: Unable to create Hyper-V Cluster Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }

            if ($HyperVServerObj = Get-VbrBackupHyperVStandAloneInfo | Sort-Object) {

                $columnSize = & {
                    if (($HyperVServerObj | Measure-Object).count -le 1 ) {
                        return 1
                    } else {
                        return 4
                    }
                }

                try {

                    $ViStandAloneNodes = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($HyperVServerObj | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_HyperV_Server" -columnSize $columnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $HyperVServerObj.AditionalInfo -Subgraph -SubgraphLabel " " -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1")
                } catch {
                    Write-Verbose "Error: Unable to create Hyper-V StandAlone Hosts Table. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($ViStandAloneNodes) {
                    try {
                        $VivCenterNodesAll += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ViStandAloneNodes -Align 'Center' -IconDebug $IconDebug -Label 'Hyper-V StandAlone Hosts' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $columnSize -fontSize 22
                    } catch {
                        Write-Verbose "Error: Unable to create Hyper-V StandAlone Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
            }

            if ($VivCenterNodesAll) {
                if ($Dir -eq 'LR') {
                    try {
                        $ViClustersSubgraphNode = Node -Name "HvCluster" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VivCenterNodesAll -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_HyperV' -Label 'Microsoft Hyper-V Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 24); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create HvCluster Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                } else {
                    try {
                        $ViClustersSubgraphNode = Node -Name "HvCluster" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VivCenterNodesAll -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_HyperV' -Label 'Microsoft Hyper-V Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 24); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create HvCluster Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                if ($ViClustersSubgraphNode) {
                    $ViClustersSubgraphNode
                    if ($HyperVBackupProxy) {
                        Edge HvProxies -To HvCluster @{minlen = 2 }
                    } else {
                        Edge BackupServers -To HvCluster @{minlen = 3 }
                    }
                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}