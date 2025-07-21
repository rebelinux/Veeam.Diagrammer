function Get-DiagBackupToCloudConnectTenant {
    <#
    .SYNOPSIS
        Function to build Backup Server to Cloud Connect tenant diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.30
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

        if ($CCPerTenantInfo = Get-VbrBackupCCPerTenantInfo -TenantName $TenantName) {

            # Create Tenant Node

            try {
                $TenantInfo = Node -Name 'TenantInfo' -Attributes @{
                    Label = $CCPerTenantInfo.Label;
                    shape = 'plain';
                    fillColor = 'transparent';
                    fontsize = 14;
                    fontname = 'Segoe Ui'
                }
                if ($TenantInfo) {
                    $TenantInfo
                    Edge -From 'TenantInfo' -To 'TenantGateway' -Attributes @{
                        color = $Edgecolor;
                        style = 'dashed';
                        fontname = 'Segoe Ui';
                        fontsize = 14;
                        arrowtail = 'dot';
                        arrowhead = 'dot';
                        minlen = 5;
                    }
                }

            } catch {
                Write-Verbose 'Error: Unable to create TenantInfo Objects. Panic!'
                Write-Debug "Error Message: $($_.Exception.Message)"
                throw
            }

            # Create Tenant Gateway Server Node
            if (($CGServerInfo = $CCPerTenantInfo.CloudGatewayServers) -and $CCPerTenantInfo.CloudGatewaySelectionType -eq 'StandaloneGateway') {
                if ($CGServerInfo.Name.Count -eq 1) {
                    $CGServerNodeColumnSize = 1
                } elseif ($ColumnSize) {
                    $CGServerNodeColumnSize = $ColumnSize
                } else {
                    $CGServerNodeColumnSize = $CGServerInfo.Name.Count
                }
                try {
                    $CGServerNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CGServerInfo.Name -Align "Center" -iconType "VBR_Cloud_Connect_Gateway" -columnSize $CGServerNodeColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CGServerInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Service_Providers_Server" -SubgraphLabel "Gateway Servers" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                    if ($CGServerNode) {
                        Node 'TenantGateway' -Attributes @{
                            Label = $CGServerNode;
                            shape = 'plain';
                            fillColor = 'transparent';
                            fontsize = 14;
                            fontname = 'Segoe Ui'
                        }

                        Edge -From 'TenantGateway' -To 'TenantGatewayConnector' -Attributes @{
                            color = $Edgecolor;
                            style = 'dashed';
                            fontname = 'Segoe Ui';
                            fontsize = 14
                            arrowtail = 'dot';
                            arrowhead = 'none';
                        }
                    }
                } catch {
                    Write-Verbose "Error: Unable to create CloudGateway Server Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }

            # Create Tenant Gateway Pool Node
            if (($CGPoolInfo = $CCPerTenantInfo.CloudGatewayPools) -and $CCPerTenantInfo.CloudGatewaySelectionType -eq 'GatewayPool') {
                try {
                    $CGPoolNode = foreach ($CGPool in $CGPoolInfo) {
                        if ($CGPoolInfo.CloudGateways) {
                            if ($CGPoolInfo.CloudGateways.count -le 5) {
                                $CGPoolInfocolumnSize = $CGPoolInfo.CloudGateways.count
                            } elseif ($ColumnSize) {
                                $CGPoolInfocolumnSize = $ColumnSize
                            } else {
                                $CGPoolInfocolumnSize = 5
                            }
                            Add-DiaHTMLTable -ImagesObj $Images -Rows $CGPool.CloudGateways.Name.split(".")[0] -Align 'Center' -ColumnSize $CGPoolInfocolumnSize -IconDebug $IconDebug -Subgraph -SubgraphIconType 'VBR_Cloud_Connect_Gateway' -SubgraphLabel $CGPool.Name -SubgraphLabelPos "top" -fontColor $Fontcolor -TableStyle 'dashed,rounded' -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -FontSize 18
                        } else {
                            Add-DiaHTMLTable -ImagesObj $Images -Rows 'No Cloud Gateway Server' -Align 'Center' -ColumnSize 1 -IconDebug $IconDebug -Subgraph -SubgraphIconType 'VBR_Cloud_Connect_Gateway' -SubgraphLabel $CGPool.Name -SubgraphLabelPos "top" -fontColor $Fontcolor -TableStyle 'dashed,rounded' -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -FontSize 18
                        }
                    }
                } catch {
                    Write-Verbose 'Error: Unable to create CGPoolInfo Objects. Disabling the section'
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
                try {
                    if ($CGPoolNode) {
                        if ($CGPoolNode.count -le 5) {
                            $CGPoolNodecolumnSize = $CGPoolNode.count
                        } elseif ($ColumnSize) {
                            $CGPoolNodecolumnSize = $ColumnSize
                        } else {
                            $CGPoolNodecolumnSize = 5
                        }
                        $CGPoolNodesSubGraph += Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CGPoolNode -Align 'Center' -IconDebug $IconDebug -Label 'Gateway Pools' -LabelPos 'top' -fontColor $Fontcolor -TableStyle 'dashed,rounded' -TableBorderColor $Edgecolor -TableBorder '1' -columnSize $CGPoolNodecolumnSize -fontSize 22 -IconType 'VBR_Cloud_Connect_Gateway_Pools'

                        if ($CGPoolNodesSubGraph) {
                            Node 'TenantGateway' -Attributes @{
                                Label = $CGPoolNodesSubGraph;
                                shape = 'plain';
                                fillColor = 'transparent';
                                fontsize = 14;
                                fontname = 'Segoe Ui'
                            }

                            Edge -From 'TenantGateway' -To 'TenantGatewayConnector' -Attributes @{
                                color = $Edgecolor;
                                style = 'dashed';
                                fontname = 'Segoe Ui';
                                fontsize = 14
                                arrowtail = 'dot';
                                arrowhead = 'none';
                            }
                        }
                    }
                } catch {
                    Write-Verbose 'Error: Unable to create CGPoolInfo SubGraph Objects. Disabling the section'
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }

            # Create Tenant Backup Storage Node
            if ($CCBackupStorageObj = $CCPerTenantInfo.BackupResources) {
                $CloudRepoSubgraphNode = @()
                $CloudConnectTenantRRSubTenantArray = @()
                foreach ($CCBackupStorageInfo in $CCBackupStorageObj) {
                    $CloudConnectTenantBSArray = @()
                    $CloudConnectTenantBRArray = @()

                    $CloudRepoOBJNode = $CCBackupStorageInfo.Label

                    if ($CloudRepoOBJNode) {
                        $CloudConnectTenantBRArray += $CloudRepoOBJNode
                    }

                    if (($CCBackupStorageInfo.Repositories | Measure-Object).Count -le 5) {
                        $BackupRepositorycolumnSize = ($CCBackupStorageInfo.Repositories | Measure-Object).Count
                    } elseif ($ColumnSize) {
                        $BackupRepositorycolumnSize = $ColumnSize
                    } else {
                        $BackupRepositorycolumnSize = 5
                    }
                    try {
                        $CCBackupRepositoryNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCBackupStorageInfo.Repositories.Name -Align "Center" -iconType $CCBackupStorageInfo.Repositories.IconType -columnSize $BackupRepositorycolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCBackupStorageInfo.Repositories.AditionalInfo -Subgraph -SubgraphIconType "VBR_Repository" -SubgraphLabel "Backup Repositories" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                        if ($CCBackupRepositoryNode) {
                            $CloudConnectTenantBSArray += $CCBackupRepositoryNode
                        }
                    } catch {
                        Write-Verbose 'Error: Unable to create CCBackupRepositoryNode Objects. Disabling the section'
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                    if ($CCBackupStorageInfo.WanAccelerationEnabled) {
                        if (($CCBackupStorageInfo.WanAccelerator | Measure-Object).Count -le 5) {
                            $CCBSWancolumnSize = ($CCBackupStorageInfo.WanAccelerator | Measure-Object).Count
                        } elseif ($ColumnSize) {
                            $CCBSWancolumnSize = $ColumnSize
                        } else {
                            $CCBSWancolumnSize = 5
                        }
                        try {
                            $CCCloudWanAcceleratorNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCBackupStorageInfo.WanAccelerator.Name -Align "Center" -iconType $CCBackupStorageInfo.WanAccelerator.IconType -columnSize $CCBSWancolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCBackupStorageInfo.WanAccelerator.AditionalInfo -Subgraph -SubgraphIconType "VBR_Wan_Accel" -SubgraphLabel "Wan Accelerators" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                            if ($CCCloudWanAcceleratorNode) {
                                $CloudConnectTenantBSArray += $CCCloudWanAcceleratorNode
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create CCCloudWanAcceleratorNode Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }

                    try {
                        if ($CloudConnectTenantBSArray) {
                            if (($CloudConnectTenantBSArray | Measure-Object).Count -le 5) {
                                $CloudConnectTenantBSArraycolumnSize = ($CloudConnectTenantBSArray | Measure-Object).Count
                            } elseif ($ColumnSize) {
                                $CloudConnectTenantBSArraycolumnSize = $ColumnSize
                            } else {
                                $CloudConnectTenantBSArraycolumnSize = 5
                            }
                            $CloudConnectTenantBSSubGraph = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantBSArray -Align 'Center' -IconDebug $IconDebug -Label "Resources" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $CloudConnectTenantBSArraycolumnSize -fontSize 22

                            if ($CloudConnectTenantBSSubGraph) {
                                $CloudConnectTenantBRArray += $CloudConnectTenantBSSubGraph
                            }

                        }
                    } catch {
                        Write-Verbose "Error: Unable to create CloudConnectTenantBSSubGraph SubGraph Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    try {
                        $CloudRepoSubgraphNode += Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantBRArray  -Align 'Center' -IconDebug $IconDebug -Label $CCBackupStorageInfo.Name -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 20
                    } catch {
                        Write-Verbose "Error: Unable to create Cloud Resource SubGraph Nodes Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    if ($CCBackupStorageInfo.SubTenant) {
                        if (($CCBackupStorageInfo.SubTenant.Name | Measure-Object).Count -le 5) {
                            $CCRRNetExtcolumnSize = ($CCBackupStorageInfo.SubTenant.Name | Measure-Object).Count
                        } elseif ($ColumnSize) {
                            $CCRRNetExtcolumnSize = $ColumnSize
                        } else {
                            $CCRRNetExtcolumnSize = 5
                        }
                        try {
                            $CCCloudSubTenantNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCBackupStorageInfo.SubTenant.Name -Align "Center" -iconType $CCBackupStorageInfo.SubTenant.IconType -columnSize $CCRRNetExtcolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCBackupStorageInfo.SubTenant.AditionalInfo -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                            if ($CCCloudSubTenantNode) {
                                $CloudConnectTenantRRSubTenantArray += $CCCloudSubTenantNode
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create CCCloudSubTenantNode Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }
                }
                try {
                    $CloudRepoSubgraph = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudRepoSubgraphNode  -Align 'Center' -IconDebug $IconDebug -Label "Backup Resources" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4 -fontSize 22 -IconType 'VBR_Cloud_Storage'
                } catch {
                    Write-Verbose "Error: Unable to create Cloud Resource SubGraph Nodes Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($CloudConnectTenantRRSubTenantArray) {
                    try {
                        $CloudConnectTenantRRSubTenantSubgraphNode = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantRRSubTenantArray  -Align 'Center' -IconDebug $IconDebug -Label "SubTenants" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4 -fontSize 22 -IconType 'VBR_Cloud_Storage'
                    } catch {
                        Write-Verbose "Error: Unable to create SubTenants SubGraph Nodes Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                if ($CloudRepoSubgraph) {
                    Node 'TenantBackupStorage' -Attributes @{
                        Label = $CloudRepoSubgraph;
                        shape = 'plain';
                        fillColor = 'transparent';
                        fontsize = 14;
                        fontname = 'Segoe Ui'
                    }
                }
                # Create SubTenant Node
                if ($CloudConnectTenantRRSubTenantSubgraphNode) {
                    Node 'TenantBackupStorageSubTenant' -Attributes @{
                        Label = $CloudConnectTenantRRSubTenantSubgraphNode;
                        shape = 'plain';
                        fillColor = 'transparent';
                        fontsize = 14;
                        fontname = 'Segoe Ui'
                    }

                    Edge -From 'TenantBackupStorage' -To 'TenantBackupStorageSubTenant' -Attributes @{
                        color = $Edgecolor;
                        style = 'dashed';
                        fontname = 'Segoe Ui';
                        fontsize = 14
                        arrowtail = 'dot';
                        arrowhead = 'dot';
                        minlen = 2;
                    }
                }

            }

            # Create Tenant Replica Resources Node
            if ($CCReplicaResourcesObj = $CCPerTenantInfo.ReplicationResources.HardwarePlanOptions) {
                $CloudResourcesSubgraphNode = @()
                $CloudConnectTenantRRArraySubgraph = @()

                $CloudConnectTenantRRNetworkExtensionArray = @()


                foreach ($CCReplicaResourcesInfo in $CCReplicaResourcesObj) {
                    $CloudConnectTenantReplicaResourceArray = @()
                    $CloudConnectTenantRRArray = @()

                    $CloudConnectTenantReplicaResourceArray += $CCReplicaResourcesInfo.Label

                    try {
                        if (($CCReplicaResourcesInfo.Host | Measure-Object).Count -le 5) {
                            $CCReplicaResourcesInfocolumnSize = ($CCReplicaResourcesInfo.Host | Measure-Object).Count
                        } elseif ($ColumnSize) {
                            $CCReplicaResourcesInfocolumnSize = $ColumnSize
                        } else {
                            $CCReplicaResourcesInfocolumnSize = 5
                        }

                        if ($CCReplicaResourcesInfo.Host) {
                            $CCRRHostNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCReplicaResourcesInfo.Host.Name -Align "Center" -iconType $CCReplicaResourcesInfo.Host.IconType -columnSize $CCReplicaResourcesInfocolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCReplicaResourcesInfo.Host.AditionalInfo -Subgraph -SubgraphIconType "VBR_Cloud_Connect_VM" -SubgraphLabel "Host or Cluster" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                            $CloudConnectTenantRRArray += $CCRRHostNode
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create CCRRHostNode Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    try {
                        if (($CCReplicaResourcesInfo.Storage | Measure-Object).Count -le 5) {
                            $CCReplicaResourcesInfocolumnSize = ($CCReplicaResourcesInfo.Storage | Measure-Object).Count
                        } elseif ($ColumnSize) {
                            $CCReplicaResourcesInfocolumnSize = $ColumnSize
                        } else {
                            $CCReplicaResourcesInfocolumnSize = 5
                        }

                        if ($CCReplicaResourcesInfo.Storage) {
                            $CCRRStorageNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCReplicaResourcesInfo.Storage.Name -Align "Center" -iconType "VBR_Cloud_Repository" -columnSize $CCReplicaResourcesInfocolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCReplicaResourcesInfo.Storage.AditionalInfo -Subgraph -SubgraphIconType "VBR_Cloud_Repository" -SubgraphLabel "Storage" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                            $CloudConnectTenantRRArray += $CCRRStorageNode
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create CCRRStorageNode Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    if ($CCReplicaResourcesInfo.WanAcceleration) {
                        if (($CCReplicaResourcesInfo.WanAcceleration | Measure-Object).Count -le 5) {
                            $CCRRWancolumnSize = ($CCReplicaResourcesInfo.WanAcceleration | Measure-Object).Count
                        } elseif ($ColumnSize) {
                            $CCRRWancolumnSize = $ColumnSize
                        } else {
                            $CCRRWancolumnSize = 5
                        }
                        try {
                            $CCCloudWanAcceleratorNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCReplicaResourcesInfo.WanAcceleration.Name -Align "Center" -iconType $CCReplicaResourcesInfo.WanAcceleration.IconType -columnSize $CCRRWancolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCReplicaResourcesInfo.WanAcceleration.AditionalInfo -Subgraph -SubgraphIconType "VBR_Wan_Accel" -SubgraphLabel "Wan Accelerators" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                            if ($CCCloudWanAcceleratorNode) {
                                $CloudConnectTenantRRArray += $CCCloudWanAcceleratorNode
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create CCCloudWanAcceleratorNode Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }

                    try {
                        if ($CloudConnectTenantRRArray) {
                            if (($CloudConnectTenantRRArray | Measure-Object).Count -le 5) {
                                $CloudConnectTenantRRArraycolumnSize = ($CloudConnectTenantRRArray | Measure-Object).Count
                            } elseif ($ColumnSize) {
                                $CloudConnectTenantRRArraycolumnSize = $ColumnSize
                            } else {
                                $CloudConnectTenantRRArraycolumnSize = 5
                            }
                            $CloudConnectTenantRRSubGraph = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantRRArray -Align 'Center' -IconDebug $IconDebug -Label "Resources" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $CloudConnectTenantRRArraycolumnSize -fontSize 22

                            if ($CloudConnectTenantRRSubGraph) {
                                $CloudConnectTenantReplicaResourceArray += $CloudConnectTenantRRSubGraph
                            }

                        }
                    } catch {
                        Write-Verbose "Error: Unable to create CloudConnectTenantRRSubGraph SubGraph Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    try {
                        if ($CloudConnectTenantReplicaResourceArray) {
                            $CloudConnectTenantRRArraySubgraph += Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantReplicaResourceArray  -Align 'Center' -IconDebug $IconDebug -Label $CCReplicaResourcesInfo.Name -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 22

                        }
                    } catch {
                        Write-Verbose "Error: Unable to create CCRRNode Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    if ($CCReplicaResourcesInfo.NetworkExtensions) {
                        if (($CCReplicaResourcesInfo.NetworkExtensions.Name | Measure-Object).Count -le 5) {
                            $CCRRNetExtcolumnSize = ($CCReplicaResourcesInfo.NetworkExtensions.name | Measure-Object).Count
                        } elseif ($ColumnSize) {
                            $CCRRNetExtcolumnSize = $ColumnSize
                        } else {
                            $CCRRNetExtcolumnSize = 5
                        }
                        try {
                            $CCCloudNetworkExtensionsNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCReplicaResourcesInfo.NetworkExtensions.Name -Align "Center" -iconType $CCReplicaResourcesInfo.NetworkExtensions.IconType -columnSize $CCRRNetExtcolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCReplicaResourcesInfo.NetworkExtensions.AditionalInfo -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                            if ($CCCloudNetworkExtensionsNode) {
                                $CloudConnectTenantRRNetworkExtensionArray += $CCCloudNetworkExtensionsNode
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create CCCloudNetworkExtensionsNode Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }
                }

                if ($CloudConnectTenantRRNetworkExtensionArray) {
                    try {
                        $CloudConnectTenantRRNExtensionSubgraphNode = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantRRNetworkExtensionArray  -Align 'Center' -IconDebug $IconDebug -Label "Network Extension Appliances" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4 -fontSize 22 -IconType 'VBR_Hardware_Resources'
                    } catch {
                        Write-Verbose "Error: Unable to create Cloud Resource SubGraph Nodes Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                try {
                    $CloudResourcesSubgraphNode = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantRRArraySubgraph  -Align 'Center' -IconDebug $IconDebug -Label "Replica Resources" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4 -fontSize 22 -IconType 'VBR_Hardware_Resources'
                } catch {
                    Write-Verbose "Error: Unable to create Cloud Resource SubGraph Nodes Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($CloudResourcesSubgraphNode) {
                    Node 'TenantReplicaResources' -Attributes @{
                        Label = $CloudResourcesSubgraphNode;
                        shape = 'plain';
                        fillColor = 'transparent';
                        fontsize = 14;
                        fontname = 'Segoe Ui'
                    }
                }

                if ($CloudConnectTenantRRNExtensionSubgraphNode) {
                    Node 'TenantReplicaResourcesNetworkExtension' -Attributes @{
                        Label = $CloudConnectTenantRRNExtensionSubgraphNode;
                        shape = 'plain';
                        fillColor = 'transparent';
                        fontsize = 14;
                        fontname = 'Segoe Ui'
                    }

                    Edge -From 'TenantReplicaResources' -To 'TenantReplicaResourcesNetworkExtension' -Attributes @{
                        color = $Edgecolor;
                        style = 'dashed';
                        fontname = 'Segoe Ui';
                        fontsize = 14
                        arrowtail = 'dot';
                        arrowhead = 'dot';
                        minlen = 3;
                    }
                }
            }


            # Create Tenant vCD Replica Resources Node
            if ($CCvCDReplicaResourcesObj = $CCPerTenantInfo.vCDReplicationResources.OrganizationvDCOptions) {
                $CloudvCDResourcesSubgraphNode = @()
                $CloudConnectTenantvCDRRArraySubgraph = @()

                $CloudConnectTenantvCDRRNetworkExtensionArray = @()


                foreach ($CCvCDReplicaResourcesInfo in $CCvCDReplicaResourcesObj) {
                    $CloudConnectTenantvCDReplicaResourceArray = @()
                    $CloudConnectTenantvCDRRArray = @()

                    $CloudConnectTenantvCDReplicaResourceArray += $CCvCDReplicaResourcesInfo.Label

                    if ($CCvCDReplicaResourcesInfo.WanAcceleration) {
                        if (($CCvCDReplicaResourcesInfo.WanAcceleration | Measure-Object).Count -le 5) {
                            $CCvCDRRWancolumnSize = ($CCvCDReplicaResourcesInfo.WanAcceleration | Measure-Object).Count
                        } elseif ($ColumnSize) {
                            $CCvCDRRWancolumnSize = $ColumnSize
                        } else {
                            $CCvCDRRWancolumnSize = 5
                        }
                        try {
                            $CCCloudvCDWanAcceleratorNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCvCDReplicaResourcesInfo.WanAcceleration.Name -Align "Center" -iconType $CCvCDReplicaResourcesInfo.WanAcceleration.IconType -columnSize $CCvCDRRWancolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCvCDReplicaResourcesInfo.WanAcceleration.AditionalInfo -Subgraph -SubgraphIconType "VBR_Wan_Accel" -SubgraphLabel "Wan Accelerators" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                            if ($CCCloudvCDWanAcceleratorNode) {
                                $CloudConnectTenantvCDRRArray += $CCCloudvCDWanAcceleratorNode
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create CCCloudvCDWanAcceleratorNode Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }

                    try {
                        if ($CloudConnectTenantvCDRRArray) {
                            if (($CloudConnectTenantvCDRRArray | Measure-Object).Count -le 5) {
                                $CloudConnectTenantvCDRRArraycolumnSize = ($CloudConnectTenantvCDRRArray | Measure-Object).Count
                            } elseif ($ColumnSize) {
                                $CloudConnectTenantvCDRRArraycolumnSize = $ColumnSize
                            } else {
                                $CloudConnectTenantvCDRRArraycolumnSize = 5
                            }
                            $CloudConnectTenantvCDRRSubGraph = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantvCDRRArray -Align 'Center' -IconDebug $IconDebug -Label "Resources" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $CloudConnectTenantvCDRRArraycolumnSize -fontSize 22

                            if ($CloudConnectTenantvCDRRSubGraph) {
                                $CloudConnectTenantvCDReplicaResourceArray += $CloudConnectTenantvCDRRSubGraph
                            }

                        }
                    } catch {
                        Write-Verbose "Error: Unable to create CloudConnectTenantvCDRRSubGraph SubGraph Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    try {
                        if ($CloudConnectTenantvCDReplicaResourceArray) {
                            $CloudConnectTenantvCDRRArraySubgraph += Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantvCDReplicaResourceArray  -Align 'Center' -IconDebug $IconDebug -Label $CCvCDReplicaResourcesInfo.Name -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 22

                        }
                    } catch {
                        Write-Verbose "Error: Unable to create CloudConnectTenantvCDRRArraySubgraph Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    if ($CCvCDReplicaResourcesInfo.NetworkExtensions) {
                        if (($CCvCDReplicaResourcesInfo.NetworkExtensions.Name | Measure-Object).Count -le 5) {
                            $CCvCDRRNetExtcolumnSize = ($CCvCDReplicaResourcesInfo.NetworkExtensions.Name | Measure-Object).Count
                        } elseif ($ColumnSize) {
                            $CCvCDRRNetExtcolumnSize = $ColumnSize
                        } else {
                            $CCvCDRRNetExtcolumnSize = 5
                        }
                        try {
                            $CCCloudvCDNetworkExtensionsNode = Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCvCDReplicaResourcesInfo.NetworkExtensions.Name -Align "Center" -iconType $CCvCDReplicaResourcesInfo.NetworkExtensions.IconType -columnSize $CCvCDRRNetExtcolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCvCDReplicaResourcesInfo.NetworkExtensions.AditionalInfo -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                            if ($CCCloudvCDNetworkExtensionsNode) {
                                $CloudConnectTenantvCDRRNetworkExtensionArray += $CCCloudvCDNetworkExtensionsNode
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create CCCloudvCDNetworkExtensionsNode Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }
                }

                if ($CloudConnectTenantvCDRRNetworkExtensionArray) {
                    try {
                        $CloudConnectTenantvCDRRNExtensionSubgraphNode = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantvCDRRNetworkExtensionArray  -Align 'Center' -IconDebug $IconDebug -Label "Network Extension Appliances" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4 -fontSize 22 -IconType 'VBR_Hardware_Resources'
                    } catch {
                        Write-Verbose "Error: Unable to create CloudvCDRRNExtensionSubgraphNode Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                try {
                    $CloudvCDResourcesSubgraphNode = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectTenantvCDRRArraySubgraph  -Align 'Center' -IconDebug $IconDebug -Label "vDC Replica Resources" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4 -fontSize 22 -IconType 'VBR_Hardware_Resources'
                } catch {
                    Write-Verbose "Error: Unable to create CloudvCDResourcesSubgraphNode Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($CloudvCDResourcesSubgraphNode) {
                    Node 'TenantReplicaResources' -Attributes @{
                        Label = $CloudvCDResourcesSubgraphNode;
                        shape = 'plain';
                        fillColor = 'transparent';
                        fontsize = 14;
                        fontname = 'Segoe Ui'
                    }
                }

                if ($CloudConnectTenantvCDRRNExtensionSubgraphNode) {
                    Node 'TenantReplicaResourcesNetworkExtension' -Attributes @{
                        Label = $CloudConnectTenantvCDRRNExtensionSubgraphNode;
                        shape = 'plain';
                        fillColor = 'transparent';
                        fontsize = 14;
                        fontname = 'Segoe Ui'
                    }

                    Edge -From 'TenantReplicaResources' -To 'TenantReplicaResourcesNetworkExtension' -Attributes @{
                        color = $Edgecolor;
                        style = 'dashed';
                        fontname = 'Segoe Ui';
                        fontsize = 14
                        arrowtail = 'dot';
                        arrowhead = 'dot';
                        minlen = 3;
                    }
                }
            }

            if (($CloudResourcesSubgraphNode -or $CloudvCDResourcesSubgraphNode) -and $CloudRepoSubgraph) {
                Rank 'TenantBackupStorage', 'TenantBackupStorageConnector'
                Rank 'TenantReplicaResources', 'TenantReplicaResourcesConnector'
                # Create Edge Connector Nodes
                Add-DiaInvertedTShapeLine -InvertedTStart 'TenantBackupStorageConnector' -InvertedTStartLineLength 5 -InvertedTMiddleTop 'TenantGatewayConnector' -InvertedTEndLineLength 5 -LineColor $Edgecolor -LineStyle 'dashed' -IconDebug $IconDebug -LineWidth $EdgeLineWidth -InvertedTEnd 'TenantReplicaResourcesConnector'

                Edge -From 'TenantReplicaResourcesConnector' -To 'TenantReplicaResources' -Attributes @{
                    color = $Edgecolor;
                    style = 'dashed';
                    fontname = 'Segoe Ui';
                    fontsize = 14
                    arrowtail = 'none';
                    arrowhead = 'dot';
                }
                Edge -From 'TenantBackupStorage' -To 'TenantBackupStorageConnector' -Attributes @{
                    color = $Edgecolor;
                    style = 'dashed';
                    fontname = 'Segoe Ui';
                    fontsize = 14
                    arrowtail = 'dot';
                    arrowhead = 'none';
                }
            } elseif ($CloudResourcesSubgraphNode -or $CloudvCDResourcesSubgraphNode) {
                # Create Edge Connector Nodes
                Add-DiaVerticalLine -VStart 'TenantGatewayConnector' -VEnd 'TenantReplicaResourcesConnector' -LineColor $Edgecolor -LineStyle 'dashed' -IconDebug $IconDebug -LineWidth $EdgeLineWidth

                Edge -From 'TenantReplicaResourcesConnector' -To 'TenantReplicaResources' -Attributes @{
                    color = $Edgecolor;
                    style = 'dashed';
                    fontname = 'Segoe Ui';
                    fontsize = 14
                    arrowtail = 'none';
                    arrowhead = 'dot';
                }
            } elseif ($CloudRepoSubgraph) {
                # Create Edge Connector Nodes
                Add-DiaVerticalLine -VStart 'TenantGatewayConnector' -VEnd 'TenantBackupStorageConnector' -LineColor $Edgecolor -LineStyle 'dashed' -IconDebug $IconDebug -LineWidth $EdgeLineWidth

                Edge -From 'TenantBackupStorageConnector' -To 'TenantBackupStorage' -Attributes @{
                    color = $Edgecolor;
                    style = 'dashed';
                    fontname = 'Segoe Ui';
                    fontsize = 14
                    arrowtail = 'none';
                    arrowhead = 'dot';
                }
            }
        }
    }
    end {}
}