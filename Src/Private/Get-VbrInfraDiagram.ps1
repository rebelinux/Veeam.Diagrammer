function Get-VbrInfraDiagram {
    <#
    .SYNOPSIS
        Generates a diagram of the Veeam Backup & Replication infrastructure configuration in various formats using PSGraph and Graphviz.
    .DESCRIPTION
        This script creates a visual representation of the Veeam Backup & Replication infrastructure configuration. The output can be generated in PDF, SVG, DOT, or PNG formats. It leverages the PSGraph module for PowerShell and Graphviz for rendering the diagrams.
    .NOTES
        Version:        0.6.24
        Author(s):      Jonathan Colon
        Twitter:        @jcolonfzenpr
        GitHub:         rebelinux
        Credits:        Kevin Marquette (@KevinMarquette) - PSGraph module
                        Prateek Singh (@PrateekKumarSingh) - AzViz module
    .LINK
        GitHub Repository: https://github.com/rebelinux/
        PSGraph Module:    https://github.com/KevinMarquette/PSGraph
        AzViz Module:      https://github.com/PrateekKumarSingh/AzViz
    #>

    begin {
        Write-Verbose -Message "Collecting Backup Infrastructure information from $($VBRServer.Name)."
    }

    process {
        if ($VBRServer) {

            #-----------------------------------------------------------------------------------------------#
            #                                Graphviz Node Section                                          #
            #                 Nodes are Graphviz elements used to define an object entity                   #
            #                Nodes can have attributes like Shape, HTML Labels, Styles, etc.                #
            #               PSGraph: https://psgraph.readthedocs.io/en/latest/Command-Node/                 #
            #                     Graphviz: https://graphviz.org/doc/info/shapes.html                       #
            #-----------------------------------------------------------------------------------------------#

            # Blank Node used as filler
            $BlankFiller = Get-DiaNodeFiller -IconDebug $IconDebug

            # EntraID Graphviz Cluster
            if ($EntraID = Get-VbrBackupEntraIDInfo) {
                try {
                    $EntraIDNode = Node EntraID @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $EntraID.Name -Align "Center" -iconType "VBR_Microsoft_Entra_ID" -columnSize 2 -IconDebug $IconDebug -MultiIcon -AditionalInfo $EntraID.AditionalInfo -Subgraph -SubgraphLabel "Entra ID Tenants" -SubgraphLabelPos "top" -SubgraphIconType "VBR_Microsoft_Entra_ID" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18); shape = 'plain'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create EntraID Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
            if ($EntraID -and $EntraIDNode) {
                $EntraIDNode
            }

            # Proxy Graphviz Cluster
            if ($Proxies = Get-VbrProxyInfo) {

                try {
                    if (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "vSphere" }).Name) {
                        $ProxiesVi = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "vSphere" }) | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($Proxies.AditionalInfo | Where-Object { $_.Type -eq "vSphere" }) -Subgraph -SubgraphIconType "VBR_vSphere" -SubgraphLabel "VMware Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18
                    }
                } catch {
                    Write-Verbose "Error: Unable to create ProxiesVSphere Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                try {
                    if (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "Off host" -or $_.AditionalInfo.Type -eq "On host" }).Name) {
                        $ProxiesHv = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "Off host" -or $_.AditionalInfo.Type -eq "On host" }).Name | ForEach-Object { $_.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($Proxies.AditionalInfo | Where-Object { $_.Type -eq "Off host" -or $_.Type -eq "On host" }) -Subgraph -SubgraphIconType "VBR_HyperV" -SubgraphLabel "Hyper-V Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18
                    }
                } catch {
                    Write-Verbose "Error: Unable to create ProxiesHyperV Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($NASProxies = Get-VbrNASProxyInfo) {
                    try {
                        $ProxiesNas = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject (($NASProxies).Name | ForEach-Object { $_.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($NASProxies.AditionalInfo) -Subgraph -SubgraphIconType "VBR_NAS" -SubgraphLabel "NAS Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18
                    } catch {
                        Write-Verbose "Error: Unable to create ProxiesNas Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
            }

            if ($Proxies -and ($ProxiesVi -or $ProxiesHv -or $ProxiesNas)) {

                $ProxyNodesArray = @()

                if ($ProxiesVi) {
                    $ProxyNodesArray += $ProxiesVi
                }
                if ($ProxiesHv) {
                    $ProxyNodesArray += $ProxiesHv
                }
                if ($NASProxies) {
                    $ProxyNodesArray += $ProxiesNas
                }

                try {
                    $ProxiesSubgraphNode = Node -Name "Proxies" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ProxyNodesArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Proxy' -Label 'Backup Proxies' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 24); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create Proxies SubGraph Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($ProxiesSubgraphNode) {
                    $ProxiesSubgraphNode
                }

            } else {
                SubGraph ProxyServer -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Backup Proxies" -IconType "VBR_Proxy" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                    Node -Name Proxies -Attributes @{Label = 'No Backup Proxies'; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; penwidth = 0 }
                }
            }

            # vSphere Graphviz Cluster
            if ($vSphereObj = Get-VbrBackupvSphereInfo | Sort-Object) {
                $VivCenterNodes = @()
                foreach ($vCenter in $vSphereObj) {
                    $vCenterNodeArray = @()
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
                            $ViClustersNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ViClustersChildsNodes -Align 'Center' -IconDebug $IconDebug -Label 'vSphere Clusters' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 22
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

                if ($VivCenterNodes) {
                    try {
                        $ViClustersSubgraphNode = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VivCenterNodes -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_vSphere' -Label 'VMware vSphere Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 18
                    } catch {
                        Write-Verbose "Error: Unable to create ViCluster Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
            }

            # HyperV Graphviz Cluster
            if ($HyperVObj = Get-VbrBackupHyperVClusterInfo | Sort-Object) {
                $HvHyperVObjNodes = @()
                foreach ($HyperV in $HyperVObj) {
                    $HyperVNodeArray = @()
                    $HvClustersNodes = @()
                    $HyperVNodeArray += $HyperV.Label
                    try {
                        $HvClustersChildsNodes = & {
                            if ($HyperV.Childs.Name) {
                                Get-DiaHTMLTable -ImagesObj $Images -Rows $HyperV.Childs.Name -Align 'Center' -ColumnSize 3 -IconDebug $IconDebug -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "0" -NoFontBold -FontSize 18
                            } else {
                                Get-DiaHTMLTable -ImagesObj $Images -Rows 'No HyperV Host' -Align 'Center' -ColumnSize $columnSize -IconDebug $IconDebug -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "0" -NoFontBold -FontSize 18
                            }
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create HyperV host table Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                    try {
                        if ($HvClustersChildsNodes) {
                            $HvClustersNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $HvClustersChildsNodes -Align 'Center' -IconDebug $IconDebug -Label 'Hyper-V Servers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 22
                            $HyperVNodeArray += $HvClustersNodes
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create HyperV Hosts Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                    try {
                        if ($HyperVNodeArray) {
                            $HvHyperVObjNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $HyperVNodeArray -Align 'Center' -IconDebug $IconDebug -Label 'Hyper-V Cluster' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 22
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create HyperV Server Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                if ($HvHyperVObjNodes) {
                    try {
                        $HvClustersSubgraphNode = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $HvHyperVObjNodes -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_HyperV' -Label 'Microsoft HyperV Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3 -fontSize 18
                    } catch {
                        Write-Verbose "Error: Unable to create HvCluster Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
            }

            if ($HvClustersSubgraphNode -or $ViClustersSubgraphNode) {

                $VirtualNodesArray = @()

                if ($vSphereObj) {
                    $VirtualNodesArray += $ViClustersSubgraphNode
                }
                if ($HyperVObj) {
                    $VirtualNodesArray += $BlankFiller
                    $VirtualNodesArray += $HvClustersSubgraphNode
                }

                try {
                    $VirtualNodesArraySubgraphNode = Node -Name "VirtualInfra" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VirtualNodesArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Proxy' -Label 'Virtual Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 24); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create SureBackup SubGraph Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($VirtualNodesArraySubgraphNode) {
                    $VirtualNodesArraySubgraphNode
                }

            }

            # Repository Graphviz Cluster
            $OnpremStorageArray = @()

            # SOBR Graphviz Cluster
            if ($SOBR = Get-VbrSOBRInfo) {
                try {
                    $SOBRNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $SOBR.Name -Align "Center" -iconType "VBR_SOBR_Repo" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $SOBR.AditionalInfo -Subgraph -SubgraphLabel "Scale-Out Backup Repositories"  -SubgraphLabelFontsize 22 -fontSize 18 -SubgraphLabelPos top -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphIconType "VBR_SOBR"
                    $OnpremStorageArray += $SOBRNode
                    $OnpremStorageArray += $BlankFiller
                } catch {
                    Write-Verbose "Error: Unable to create SOBR Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }

            # SAN Infrastructure Graphviz Cluster
            if ($SAN = Get-VbrSANInfo) {
                try {
                    $SANNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $SAN.Name -Align "Center" -iconType $SAN.IconType -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $SAN.AditionalInfo -SubgraphLabelFontsize 22 -fontSize 18 -Subgraph -SubgraphLabel "Storage Infrastructure" -SubgraphLabelPos top -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphIconType "VBR_SAN"
                    $OnpremStorageArray += $SANNode
                    $OnpremStorageArray += $BlankFiller
                } catch {
                    Write-Verbose "Error: Unable to create SAN Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
                # Repositories Graphviz Cluster
                if ($RepositoriesInfo = Get-VbrRepositoryInfo) {
                    try {
                        $RepositoriesNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $RepositoriesInfo.Name -Align "Center" -iconType $RepositoriesInfo.IconType -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo $RepositoriesInfo.AditionalInfo -Subgraph -SubgraphLabel "Backup Repositories" -SubgraphLabelFontsize 22 -fontSize 18 -SubgraphLabelPos top -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphIconType "VBR_Repository"
                        $OnpremStorageArray += $RepositoriesNode
                    } catch {
                        Write-Verbose "Error: Unable to create Repositories Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

            }
            if ($OnpremStorageArray) {
                try {
                    $OnpremStorageSubgraphNode = Node -Name "Repositories" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $OnpremStorageArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Proxy' -Label 'On-Premises Storage Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 24); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create OnPremStorage SubGraph Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }



                if ($OnpremStorageSubgraphNode) {
                    $OnpremStorageSubgraphNode
                }
            }

            # Object Repositories Graphviz Cluster
            if ($ObjectRepositoriesInfo = Get-VbrObjectRepoInfo) {
                try {
                    $ObjectRepositoriesNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ObjectRepositoriesInfo.Name -Align "Center" -iconType $ObjectRepositoriesInfo.Icontype -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ObjectRepositoriesInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_vSphere" -SubgraphLabel "Object Repositories" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18
                } catch {
                    Write-Verbose "Error: Unable to create ObjectRepositories Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }

            # Archive Object Repositories Graphviz Cluster
            if ($ArchObjRepositoriesInfo = Get-VbrArchObjectRepoInfo) {
                try {
                    $ArchObjRepositoriesNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ArchObjRepositoriesInfo.Name -Align "Center" -iconType $ArchObjRepositoriesInfo.Icontype -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ArchObjRepositoriesInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_vSphere" -SubgraphLabel "Archives Object Repositories" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18
                } catch {
                    Write-Verbose "Error: Unable to create ArchiveObjectRepositories Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
            if (($ObjectRepositoriesInfo -or $ArchObjRepositoriesInfo) -and ($ObjectRepositoriesNode -or $ArchObjRepositoriesNode)) {
                $ObjStorageNodeArray = @()

                if ($ObjectRepositoriesNode) {
                    $ObjStorageNodeArray += $ObjectRepositoriesNode
                }

                if ($ArchObjRepositoriesNode) {
                    $ObjStorageNodeArray += $ArchObjRepositoriesNode
                }

                try {
                    $ObjStorageSubgraphNode = Node -Name "ObjectRepos" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ObjStorageNodeArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Object' -Label 'Object Storage' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2 -fontSize 24); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create SureBackup SubGraph Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($ObjStorageSubgraphNode) {
                    $ObjStorageSubgraphNode
                }
            }

            # WanAccels Graphviz Cluster
            if ($WanAccels = Get-VbrWanAccelInfo) {
                try {
                    $WanAccelsNode = Node WanAccelServer @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($WanAccels | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Wan_Accel" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $WanAccels.AditionalInfo -Subgraph -SubgraphLabel "Wan Accelerators" -SubgraphLabelPos "top" -SubgraphIconType "VBR_Wan_Accel" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18); shape = 'plain'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create WanAccelerators Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
            if ($WanAccels -and $WanAccelsNode) {
                $WanAccelsNode
            }

            # Tapes Graphviz Cluster
            $TapeInfraArray = @()

            if ($TapeServerInfo = Get-VbrTapeServersInfo) {
                try {
                    $TapeServerNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeServerInfo.Name -Align "Center" -iconType "VBR_Tape_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeServerInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Tape_Server" -SubgraphLabel "Tape Servers" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                    $TapeInfraArray += $TapeServerNode
                    $TapeInfraArray += $BlankFiller
                } catch {
                    Write-Verbose "Error: Unable to create TapeServers Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
                if ($TapeLibraryInfo = Get-VbrTapeLibraryInfo) {
                    try {
                        $TapeLibraryNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeLibraryInfo.Name -Align "Center" -iconType "VBR_Tape_Library" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeLibraryInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Tape_Library" -SubgraphLabel "Tape Libraries" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                        $TapeInfraArray += $TapeLibraryNode
                        $TapeInfraArray += $BlankFiller
                    } catch {
                        Write-Verbose "Error: Unable to create TapeLibrary Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
                if ($TapeVaultInfo = Get-VbrTapeVaultInfo) {
                    try {
                        $TapeVaultNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeVaultInfo.Name -Align "Center" -iconType "VBR_Tape_Vaults" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeVaultInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Tape_Vaults" -SubgraphLabel "Tape Vaults" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18
                        $TapeInfraArray += $TapeVaultNode
                    } catch {
                        Write-Verbose "Error: Unable to create TapeVault Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
            }
            if ($TapeServerInfo -and $TapeServerNode) {
                try {
                    $TapeServerSubGraph = Node -Name "TapeInfra" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $TapeInfraArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Tape' -Label 'Tape Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1 -fontSize 24); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create TapeInfra SubGraph Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($TapeServerSubGraph) {
                    $TapeServerSubGraph
                }
            }

            # ServiceProvider Graphviz Cluster
            if ($ServiceProviderInfo = Get-VbrServiceProviderInfo) {
                try {
                    $ServiceProviderNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ServiceProviderInfo.Name -Align "Center" -iconType "VBR_Service_Providers_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ServiceProviderInfo.AditionalInfo -SubgraphLabelFontsize 22 -fontSize 18
                } catch {
                    Write-Verbose "Error: Unable to create ServiceProvider Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
            if ($ServiceProviderInfo -and $ServiceProviderNode) {

                try {
                    $ServiceProviderSubgraphNode = Node -Name ServiceProviders -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ServiceProviderNode -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Service_Providers' -Label 'Service Providers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2 -fontSize 22); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create ServiceProviders SubGraph Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($ServiceProviderSubgraphNode) {
                    $ServiceProviderSubgraphNode
                }
            }

            # SureBackup Graphviz Cluster
            if (($VirtualLab = Get-VbrVirtualLabInfo -and ($ApplicationGroups = Get-VbrApplicationGroupsInfo))) {
                if ($VirtualLab) {
                    try {
                        $VirtualLabNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $VirtualLab.Name -Align "Center" -iconType $VirtualLab.IconType -columnSize 2 -IconDebug $IconDebug -MultiIcon -AditionalInfo $VirtualLab.AditionalInfo -Subgraph -SubgraphIconType "VBR_Virtual_Lab" -SubgraphLabel "Virtual Labs" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18
                    } catch {
                        Write-Verbose "Error: Unable to create VirtualLab Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
                if ($ApplicationGroups) {
                    try {
                        $ApplicationGroupsNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ApplicationGroups.Name -Align "Center" -iconType $ApplicationGroups.IconType -columnSize 2 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ApplicationGroups.AditionalInfo -Subgraph -SubgraphIconType "VBR_Virtual_Lab" -SubgraphLabel "Application Groups" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18
                    } catch {
                        Write-Verbose "Error: Unable to create VirtualLab Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                $SureBackupSubgraphNodeArray = @()

                # VirtualLab Graphviz Cluster
                if ($VirtualLab -and $VirtualLabNode) {

                    $SureBackupSubgraphNodeArray += $VirtualLabNode
                }
                # ApplicationGroups Graphviz Cluster
                if ($ApplicationGroups -and $ApplicationGroupsNode) {

                    $SureBackupSubgraphNodeArray += $ApplicationGroupsNode
                }

                try {
                    $SureBackupSubgraphNode = Node -Name "SureBackup" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $SureBackupSubgraphNodeArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_SureBackup' -Label 'SureBackup' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2 -fontSize 22); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create SureBackup SubGraph Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($SureBackupSubgraphNode) {
                    $SureBackupSubgraphNode
                }
            }

            if ($DiagramTheme -eq 'Black') {
                $NodeFillColor = 'White'
            } elseif ($DiagramTheme -eq 'Neon') {
                $NodeFillColor = 'Gold2'
            } else {
                $NodeFillColor = '#71797E'
            }

            # Veeam VBR elements point of connection (Dummy Nodes!)
            $Node = @('VBRServerPointSpace', 'VBRProxyPoint', 'VBRProxyPointSpace', 'VBRRepoPoint')

            if ($WanAccels) {
                $Node += 'VBRWanAccelPoint', 'VBRRepoPointSpace'
            } else {
                $Node += 'VBRRepoPointSpace'

            }

            if ($TapeServerInfo) {
                $Node += 'VBRTapePoint'
            }

            if ($ServiceProviderInfo) {
                $Node += 'VBRServiceProviderPoint'
            }

            if ($VirtualLabNode -or $ApplicationGroups) {
                $Node += 'VBRSureBackupPoint'
            }

            Node $Node -NodeScript { $_ } @{Label = { $_ } ; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = $NodeDebug.shape }

            $NodeStartEnd = @('VBRStartPoint', 'VBREndPointSpace')
            Node $NodeStartEnd -NodeScript { $_ } @{Label = { $_ }; fillColor = $Edgecolor; fontcolor = $NodeDebug.color; shape = 'point'; fixedsize = 'true'; width = .2 ; height = .2 }
            #---------------------------------------------------------------------------------------------#
            #                             Graphviz Rank Section                                           #
            #                     Rank allow to put Nodes on the same group level                         #
            #         PSgraph: https://psgraph.readthedocs.io/en/stable/Command-Rank-Advanced/            #
            #                     Graphviz: https://graphviz.org/docs/attrs/rank/                         #
            #---------------------------------------------------------------------------------------------#

            # Put the dummy node in the same rank to be able to create a horizontal line
            Rank $NodeStartEnd, $Node

            #---------------------------------------------------------------------------------------------#
            #                             Graphviz Edge Section                                           #
            #                   Edges are Graphviz elements use to interconnect Nodes                     #
            #                 Edges can have attribues like Shape, Size, Styles etc..                     #
            #              PSgraph: https://psgraph.readthedocs.io/en/latest/Command-Edge/                #
            #                      Graphviz: https://graphviz.org/docs/edges/                             #
            #---------------------------------------------------------------------------------------------#

            # LastPoint Min length
            $LastPointMinLen = 30
            # Connect the Dummy Node in a straight line
            # VBRStartPoint --- VBRServerPointSpace --- VBRProxyPoint --- VBRProxyPointSpace --- VBRRepoPoint --- VBREndPointSpace
            Edge -From VBRStartPoint -To VBRServerPointSpace @{minlen = 25; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            Edge -From VBRServerPointSpace -To VBRProxyPoint @{minlen = 25; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            if ($ProxiesVi -and $ProxiesHv -and $ProxiesNas ) {
                Edge -From VBRProxyPoint -To VBRProxyPointSpace @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            } else {
                Edge -From VBRProxyPoint -To VBRProxyPointSpace @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            }
            Edge -From VBRProxyPointSpace -To VBRRepoPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            Edge -From VBRRepoPoint -To VBRRepoPointSpace @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }

            if ($TapeServerNode -and $WanAccelsNode -and $ServiceProviderNode -and ($VirtualLabNode -or $ApplicationGroupsNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRServiceProviderPoint -To VBRSureBackupPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'

            } elseif ($TapeServerNode -and $WanAccelsNode -and $ServiceProviderNode -and ( -Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'

            } elseif ($TapeServerNode -and $WanAccelsNode -and (-Not $ServiceProviderNode) -and ($VirtualLabNode -or $ApplicationGroupsNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRSureBackupPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'

            } elseif ($TapeServerNode -and $WanAccelsNode -and (-Not $ServiceProviderNode) -and (-Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'

            } elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode) -and ($VirtualLabNode -or $ApplicationGroupsNode)) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 22; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRSureBackupPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'

            } elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode) -and (-Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'

            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode) -and ($VirtualLabNode -or $ApplicationGroupsNode)) {
                Edge -From VBRRepoPointSpace -To VBRSureBackupPoint @{minlen = 22; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'

            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode) -and (-Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                $LastPoint = 'VBRRepoPointSpace'
                $LastPointMinLen = 12

            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and $ServiceProviderNode -and (($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRServiceProviderPoint -To VBRSureBackupPoint @{minlen = 22; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'
            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and $ServiceProviderNode -and ( -Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            }

            elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and $ServiceProviderNode -and (($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRServiceProviderPoint -To VBRSureBackupPoint @{minlen = 22; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'
            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and $ServiceProviderNode -and ( -Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            }

            elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and (-Not $ServiceProviderNode) -and (($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRSureBackupPoint @{minlen = 22; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'
            }

            elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and $ServiceProviderNode -and (($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRServiceProviderPoint -To VBRSureBackupPoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'
            }

            elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 22; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            } elseif ($TapeServerNode -and (-Not $WanAccels) -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'
            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRServiceProviderPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'

            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRWanAccelPoint'
            } elseif ($TapeServerNode -and $WanAccelsNode -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'
            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode)) {
                $LastPoint = 'VBRRepoPointSpace'
                $LastPointMinLen = 16
            }

            ####################################################################################
            #                                                                                  #
            #      This section connect the Infrastructure component to the Dummy Points       #
            #                                                                                  #
            ####################################################################################

            # Connect Veeam Backup server to the Dummy line
            Edge -From BackupServers -To VBRServerPointSpace @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }

            # Connect Microsoft Entra ID Node to the Dummy line
            if ($EntraIDNode) {
                Edge -From EntraID -To VBRProxyPoint @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            # Connect Veeam Proxies Server to the Dummy line
            if ($ProxiesSubgraphNode) {
                Edge -From VBRProxyPoint -To Proxies @{minlen = 1; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
            }

            # Connect vCenter Servers Cluster to the Dummy line
            if ($ViClustersSubgraphNode -or $HvClustersSubgraphNode) {
                Edge -From Proxies -To VirtualInfra @{minlen = 1; arrowtail = 'dot'; arrowhead = 'dot'; style = 'dashed' }
            }

            # Connect Veeam Repository to the Dummy line
            Edge -From VBRRepoPoint -To Repositories @{minlen = 1; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }

            # Connect Veeam Object Repository to the Dummy line
            if ($ObjStorageSubgraphNode) {
                Edge -To VBRRepoPoint -From ObjectRepos @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            # Connect Veeam Wan Accelerator to the Dummy line
            if ($WanAccels -and $WanAccelsNode) {
                Edge -From WanAccelServer -To VBRWanAccelPoint @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            # Connect Veeam Tape Infra to VBRTapePoint Dummy line
            if ($TapeServerInfo -and $TapeServerNode) {
                Edge -From VBRTapePoint -To TapeInfra @{minlen = 1; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
            }

            # Connect Veeam ServiceProvider Infra to VBRServiceProviderPoint Dummy line
            if ($ServiceProviderSubgraphNode) {
                Edge -From ServiceProviders -To VBRServiceProviderPoint @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            # Connect Veeam Object Repository to the Dummy line
            if ($SureBackupSubgraphNode) {
                Edge -From SureBackup -To VBRSureBackupPoint @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            ####################################################################################
            #                                                                                  #
            #   This section connect the Last Infrastructure component to VBREndPointSpace     #
            #                                                                                  #
            ####################################################################################

            if ($LastPoint) {
                Edge -From $LastPoint -To VBREndPointSpace @{minlen = $LastPointMinLen; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            }
        }
    }
    end {}
}