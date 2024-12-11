function Get-VbrInfraDiagram {
    <#
    .SYNOPSIS
        Diagram the configuration of Veeam Backup & Replication infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
    .DESCRIPTION
        Diagram the configuration of Veeam Backup & Replication infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
    .NOTES
        Version:        0.6.17
        Author(s):      Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
        Credits:        Kevin Marquette (@KevinMarquette) -  PSGraph module
        Credits:        Prateek Singh (@PrateekKumarSingh) - AzViz module
    .LINK
        https://github.com/rebelinux/
        https://github.com/KevinMarquette/PSGraph
        https://github.com/PrateekKumarSingh/AzViz
    #>

    begin {
        Write-Verbose -Message "Collecting Backup Infrastructure information from $($VBRServer.Name)."
    }

    process {
        if ($VBRServer) {

            #-----------------------------------------------------------------------------------------------#
            #                                Graphviz Node Section                                          #
            #                 Nodes are Graphviz elements used to define a object entity                    #
            #                Nodes can have attribues like Shape, HTML Labels, Styles etc..                 #
            #               PSgraph: https://psgraph.readthedocs.io/en/latest/Command-Node/                 #
            #                     Graphviz: https://graphviz.org/doc/info/shapes.html                       #
            #-----------------------------------------------------------------------------------------------#

            # Get Veeam Backup Server Infrastructure Information
            # This create the Backup Server, Database and Enterprise Manager Objects
            # Here Veeam Pwershell Module are used to retreive the information
            Get-VBRBackupServerInfo

            # Build Backup Server Graphviz Cluster
            Get-DiagBackupServer

            # EntraID Graphviz Cluster
            if ($EntraID = Get-VbrBackupEntraIDInfo) {
                try {
                    $EntraIDNode = Node EntraID @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $EntraID.Name -Align "Center" -iconType "VBR_Microsoft_Entra_ID" -columnSize 2 -IconDebug $IconDebug -MultiIcon -AditionalInfo $EntraID.AditionalInfo -Subgraph -SubgraphLabel "Entra ID Tenants" -SubgraphLabelPos "top" -SubgraphIconType "VBR_Microsoft_Entra_ID" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1"); shape = 'plain'; fontname = "Segoe Ui" }
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
                        $ProxiesVi = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "vSphere" }) | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($Proxies.AditionalInfo | Where-Object { $_.Type -eq "vSphere" }) -Subgraph -SubgraphIconType "VBR_vSphere" -SubgraphLabel "VMware Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
                    }
                } catch {
                    Write-Verbose "Error: Unable to create ProxiesVSphere Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                try {
                    if (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "Off host" -or $_.AditionalInfo.Type -eq "On host" }).Name) {
                        $ProxiesHv = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "Off host" -or $_.AditionalInfo.Type -eq "On host" }).Name | ForEach-Object { $_.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($Proxies.AditionalInfo | Where-Object { $_.Type -eq "Off host" -or $_.Type -eq "On host" }) -Subgraph -SubgraphIconType "VBR_HyperV" -SubgraphLabel "Hyper-V Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
                    }
                } catch {
                    Write-Verbose "Error: Unable to create ProxiesHyperV Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }

                if ($NASProxies = Get-VbrNASProxyInfo) {
                    try {
                        $ProxiesNas = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject (($NASProxies).Name | ForEach-Object { $_.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($NASProxies.AditionalInfo) -Subgraph -SubgraphIconType "VBR_NAS" -SubgraphLabel "NAS Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
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
                    $ProxiesSubgraphNode = Node -Name "Proxies" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ProxyNodesArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Proxy' -Label 'Backup Proxies' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create SureBackup SubGraph Objects. Disabling the section"
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
                foreach ($vCenter in $vSphereObj | Where-Object { $_.Name -ne '192.168.5.2' }) {
                    $vCenterNodeArray = @()
                    $ViClustersNodes = @()
                    $vCenterNodeArray += $vCenter.Label
                    try {
                        $ViClustersChildsNodes = foreach ($ViCluster in $vCenter.Childs) {
                            if ($ViCluster.EsxiHost.Name) {
                                Get-DiaHTMLTable -ImagesObj $Images -Rows $ViCluster.EsxiHost.Name -Align 'Center' -ColumnSize 3 -IconDebug $IconDebug -Subgraph -SubgraphIconType "VBR_ESXi_Server" -SubgraphLabel $ViCluster.Name -SubgraphLabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold
                            } else {
                                Get-DiaHTMLTable -ImagesObj $Images -Rows 'No Esxi Host' -Align 'Center' -ColumnSize 3 -IconDebug $IconDebug -Subgraph -SubgraphIconType "VBR_ESXi_Server" -SubgraphLabel $ViCluster.Name -SubgraphLabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold
                            }
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create vSphere Esxi table Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                    try {
                        if ($ViClustersChildsNodes) {
                            $ViClustersNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ViClustersChildsNodes -Align 'Center' -IconDebug $IconDebug -Label 'vSphere Clusters' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3
                            $vCenterNodeArray += $ViClustersNodes
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create vSphere Clusters Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                    try {
                        if ($vCenterNodeArray) {
                            $VivCenterNodes += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $vCenterNodeArray -Align 'Center' -IconDebug $IconDebug -Label 'vCenter Server' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1
                        }
                    } catch {
                        Write-Verbose "Error: Unable to create vCenter Server Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                if ($VivCenterNodes) {
                    try {
                        $ViClustersSubgraphNode = Node -Name "ViInfra" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $VivCenterNodes -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_vSphere' -Label 'VMware vSphere Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create ViCluster Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }

                    if ($ViClustersSubgraphNode) {
                        $ViClustersSubgraphNode
                    }
                }
            }

            # Repository Graphviz Cluster
            SubGraph OnpremStorage -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Repository Infrastructure" -IconType "VBR_Veeam_Repository" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                # Repositories Graphviz Cluster
                if ($RepositoriesInfo = Get-VbrRepositoryInfo) {
                    try {
                        $RepositoriesNode = Node Repositories @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $RepositoriesInfo.Name -Align "Center" -iconType $RepositoriesInfo.IconType -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo $RepositoriesInfo.AditionalInfo); shape = 'plain'; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create Repositories Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
                if ($RepositoriesInfo -and $RepositoriesNode) {
                    SubGraph Repos -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Backup Repositories" -IconType "VBR_Repository" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                        $RepositoriesNode

                    }
                } else {
                    SubGraph Repos -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Backup Repositories" -IconType "VBR_Repository" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                        Node -Name Repositories -Attributes @{Label = 'No Backup Repositories'; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; penwidth = 0 }
                    }
                }

                # SOBR Graphviz Cluster
                if ($SOBR = Get-VbrSOBRInfo) {
                    try {
                        $SOBRNode = Node SOBRRepo @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $SOBR.Name -Align "Center" -iconType "VBR_SOBR_Repo" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $SOBR.AditionalInfo); shape = 'plain'; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create SOBR Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                if ($SOBR -and $SOBRNode) {
                    SubGraph SOBR -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Scale-Out Backup Repositories" -IconType "VBR_SOBR" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                        $SOBRNode
                    }
                }

                # SAN Infrastructure Graphviz Cluster
                if ($SAN = Get-VbrSANInfo) {
                    try {
                        $SANNode = Node SANRepo @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $SAN.Name -Align "Center" -iconType $SAN.IconType -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $SAN.AditionalInfo); shape = 'plain'; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create SAN Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }

                if ($SAN -and $SANNode) {
                    SubGraph SAN -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Storage Infrastructure" -IconType "VBR_SAN" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                        $SANNode
                    }
                }
            }

            # Object Repositories Graphviz Cluster
            if ($ObjectRepositoriesInfo = Get-VbrObjectRepoInfo) {
                try {
                    $ObjectRepositoriesNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ObjectRepositoriesInfo.Name -Align "Center" -iconType $ObjectRepositoriesInfo.Icontype -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ObjectRepositoriesInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_vSphere" -SubgraphLabel "Object Repositories" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
                } catch {
                    Write-Verbose "Error: Unable to create ObjectRepositories Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }

            # Archive Object Repositories Graphviz Cluster
            if ($ArchObjRepositoriesInfo = Get-VbrArchObjectRepoInfo) {
                try {
                    $ArchObjRepositoriesNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ArchObjRepositoriesInfo.Name -Align "Center" -iconType $ArchObjRepositoriesInfo.Icontype -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ArchObjRepositoriesInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_vSphere" -SubgraphLabel "Archives Object Repositories" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
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
                    $ObjStorageSubgraphNode = Node -Name "ObjectRepos" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ObjStorageNodeArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Object' -Label 'Object Storage' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
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
                    $WanAccelsNode = Node WanAccelServer @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($WanAccels | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Wan_Accel" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $WanAccels.AditionalInfo -Subgraph -SubgraphLabel "Wan Accelerators" -SubgraphLabelPos "top" -SubgraphIconType "VBR_Wan_Accel" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1"); shape = 'plain'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create WanAccelerators Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
            if ($WanAccels -and $WanAccelsNode) {
                $WanAccelsNode
            }

            # Tapes Graphviz Cluster
            if ($TapeServerInfo = Get-VbrTapeServersInfo) {
                try {
                    $TapeServerNode = Node TapeServer @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeServerInfo.Name -Align "Center" -iconType "VBR_Tape_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeServerInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Tape_Server" -SubgraphLabel "Tape Servers" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1"); shape = 'plain'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create TapeServers Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
                if ($TapeLibraryInfo = Get-VbrTapeLibraryInfo) {
                    try {
                        $TapeLibraryNode = Node TapeLibrary @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeLibraryInfo.Name -Align "Center" -iconType "VBR_Tape_Library" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeLibraryInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Tape_Library" -SubgraphLabel "Tape Libraries" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1"); shape = 'plain'; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create TapeLibrary Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
                if ($TapeVaultInfo = Get-VbrTapeVaultInfo) {
                    try {
                        $TapeVaultNode = Node TapeVault @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeVaultInfo.Name -Align "Center" -iconType "VBR_Tape_Vaults" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeVaultInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Tape_Vaults" -SubgraphLabel "Tape Vaults" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1"); shape = 'plain'; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create TapeVault Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
            }
            if ($TapeServerInfo -and $TapeServerNode) {
                $TapeServerNode

                if ($TapeLibraryInfo -and $TapeLibraryNode) {
                    $TapeLibraryNode
                }

                if ($TapeVaultInfo -and $TapeVaultNode) {
                    $TapeVaultNode
                }
            }

            # ServiceProvider Graphviz Cluster
            if ($ServiceProviderInfo = Get-VbrServiceProviderInfo) {
                try {
                    $ServiceProviderNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ServiceProviderInfo.Name -Align "Center" -iconType "VBR_Service_Providers_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ServiceProviderInfo.AditionalInfo
                } catch {
                    Write-Verbose "Error: Unable to create ServiceProvider Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
            if ($ServiceProviderInfo -and $ServiceProviderNode) {

                try {
                    $ServiceProviderSubgraphNode = Node -Name ServiceProviders -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ServiceProviderNode -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Service_Providers' -Label 'Service Providers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
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
                        $VirtualLabNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $VirtualLab.Name -Align "Center" -iconType $VirtualLab.IconType -columnSize 2 -IconDebug $IconDebug -MultiIcon -AditionalInfo $VirtualLab.AditionalInfo -Subgraph -SubgraphIconType "VBR_Virtual_Lab" -SubgraphLabel "Virtual Labs" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
                    } catch {
                        Write-Verbose "Error: Unable to create VirtualLab Objects. Disabling the section"
                        Write-Debug "Error Message: $($_.Exception.Message)"
                    }
                }
                if ($ApplicationGroups) {
                    try {
                        $ApplicationGroupsNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ApplicationGroups.Name -Align "Center" -iconType $ApplicationGroups.IconType -columnSize 2 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ApplicationGroups.AditionalInfo -Subgraph -SubgraphIconType "VBR_Virtual_Lab" -SubgraphLabel "Application Groups" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
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
                    $SureBackupSubgraphNode = Node -Name "SureBackup" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $SureBackupSubgraphNodeArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_SureBackup' -Label 'SureBackup' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
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
            Edge -From VBRStartPoint -To VBRServerPointSpace @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            Edge -From VBRServerPointSpace -To VBRProxyPoint @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            if ($ProxiesVi -and $ProxiesHv -and $ProxiesNas ) {
                Edge -From VBRProxyPoint -To VBRProxyPointSpace @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            } else {
                Edge -From VBRProxyPoint -To VBRProxyPointSpace @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            }
            Edge -From VBRProxyPointSpace -To VBRRepoPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            Edge -From VBRRepoPoint -To VBRRepoPointSpace @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }

            if ($TapeServerNode -and $WanAccelsNode -and $ServiceProviderNode -and ($VirtualLabNode -or $ApplicationGroupsNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRServiceProviderPoint -To VBRSureBackupPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'

            } elseif ($TapeServerNode -and $WanAccelsNode -and $ServiceProviderNode -and ( -Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'

            } elseif ($TapeServerNode -and $WanAccelsNode -and (-Not $ServiceProviderNode) -and ($VirtualLabNode -or $ApplicationGroupsNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRSureBackupPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'

            } elseif ($TapeServerNode -and $WanAccelsNode -and (-Not $ServiceProviderNode) -and (-Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'

            } elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode) -and ($VirtualLabNode -or $ApplicationGroupsNode)) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRSureBackupPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'

            } elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode) -and (-Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'

            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode) -and ($VirtualLabNode -or $ApplicationGroupsNode)) {
                Edge -From VBRRepoPointSpace -To VBRSureBackupPoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'

            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode) -and (-Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                $LastPoint = 'VBRRepoPointSpace'
                $LastPointMinLen = 12

            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and $ServiceProviderNode -and (($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRServiceProviderPoint -To VBRSureBackupPoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'
            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and $ServiceProviderNode -and ( -Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            }

            elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and $ServiceProviderNode -and (($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRServiceProviderPoint -To VBRSureBackupPoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'
            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and $ServiceProviderNode -and ( -Not ($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            }

            elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and (-Not $ServiceProviderNode) -and (($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRSureBackupPoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'
            }

            elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and $ServiceProviderNode -and (($VirtualLabNode -or $ApplicationGroupsNode))) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRServiceProviderPoint -To VBRSureBackupPoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRSureBackupPoint'
            }

            elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 18; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            } elseif ($TapeServerNode -and (-Not $WanAccels) -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'
            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'

            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRWanAccelPoint'
            } elseif ($TapeServerNode -and $WanAccelsNode -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'
            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode)) {
                $LastPoint = 'VBRRepoPointSpace'
                $LastPointMinLen = 12
            }

            ####################################################################################
            #                                                                                  #
            #      This section connect the Infrastructure component to the Dummy Points       #
            #                                                                                  #
            ####################################################################################

            # Connect Veeam Backup server to the Dummy line
            Edge -From $BackupServerInfo.Name -To VBRServerPointSpace @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }

            # Connect Microsoft Entra ID Node to the Dummy line
            if ($EntraIDNode) {
                Edge -From EntraID -To VBRProxyPoint @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            # Connect Veeam Proxies Server to the Dummy line
            if ($ProxiesSubgraphNode) {
                Edge -From VBRProxyPoint -To Proxies @{minlen = 1; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
            }

            # Connect vCenter Servers Cluster to the Dummy line
            if ($ViClustersSubgraphNode) {
                Edge -From Proxies -To ViInfra @{minlen = 1; arrowtail = 'dot'; arrowhead = 'dot'; style = 'dashed' }
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
                Edge -From VBRTapePoint -To TapeServer @{minlen = 1; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
                if ($TapeLibraryNode) {
                    Rank TapeServer, TapeLibrary
                    Edge -From TapeServer -To TapeLibrary @{minlen = 1; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
                }
                if ($TapeVaultNode) {
                    Edge -From TapeLibrary -To TapeVault @{minlen = 1; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
                }
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