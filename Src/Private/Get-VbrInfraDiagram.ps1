function Get-VbrInfraDiagram {
    <#
    .SYNOPSIS
        Diagram the configuration of Veeam Backup & Replication infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
    .DESCRIPTION
        Diagram the configuration of Veeam Backup & Replication infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
    .NOTES
        Version:        0.6.5
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
            Get-VBRBackupServerObj

            # Build Backup Server Graphviz Cluster
            Get-VbrBackupSvrDiagramObj

            # Proxy Graphviz Cluster
            if ($Proxies = Get-VbrProxyInfo) {
                $ProxiesVi = try {
                    Node ViProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "vSphere" }) | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($Proxies.AditionalInfo | Where-Object { $_.Type -eq "vSphere" })); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create ProxiesVSphere Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }

                $ProxiesHv = try {
                    Node HvProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject (($Proxies | Where-Object { $_.AditionalInfo.Type -eq "Off host" -or $_.AditionalInfo.Type -eq "On host" }).Name | ForEach-Object { $_.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($Proxies.AditionalInfo | Where-Object { $_.Type -eq "Off host" -or $_.Type -eq "On host" })); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create ProxiesHyperV Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }
            }

            if ($Proxies -and ($ProxiesVi -or $ProxiesHv)) {

                SubGraph ProxyServer -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Backup Proxies" -IconType "VBR_Proxy" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                    if ($Proxies | Where-Object { $_.AditionalInfo.Type -eq "vSphere" }) {
                        SubGraph ViProxyServer -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "VMware Proxies" -IconType "VBR_vSphere" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                            $ProxiesVi

                        }
                    }

                    if ($Proxies.AditionalInfo | Where-Object { $_.Type -eq "Off host" -or $_.Type -eq "On host" }) {
                        SubGraph HvProxyServer -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Hyper-V Proxies" -IconType "VBR_HyperV" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                            $ProxiesHv
                        }
                    }
                }
            } else {
                SubGraph ProxyServer -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Backup Proxies" -IconType "VBR_Proxy" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                    Node -Name Proxies -Attributes @{Label = 'No Backup Proxies'; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                }
            }

            # SOBR Graphviz Cluster
            if ($SOBR = Get-VbrSOBRInfo) {
                $SOBRNode = try {
                    Node SOBRRepo @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $SOBR.Name -Align "Center" -iconType "VBR_SOBR_Repo" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $SOBR.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create SOBR Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }
            }

            if ($SOBR -and $SOBRNode) {
                SubGraph SOBR -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Scale-Out Backup Repositories" -IconType "VBR_SOBR" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                    $SOBRNode
                }
            }

            # Repositories Graphviz Cluster
            if ($RepositoriesInfo = Get-VbrRepositoryInfo) {
                $RepositoriesNode = try {
                    Node Repositories @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $RepositoriesInfo.Name -Align "Center" -iconType $RepositoriesInfo.IconType -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $RepositoriesInfo.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create Repositories Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }
            }
            if ($RepositoriesInfo -and $RepositoriesNode) {
                SubGraph Repos -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Backup Repositories" -IconType "VBR_Repository" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                    $RepositoriesNode

                }
            } else {
                SubGraph Repos -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Backup Repositories" -IconType "VBR_Repository" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                    Node -Name Repositories -Attributes @{Label = 'No Backup Repositories'; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "3"; height = "2"; fillColor = 'transparent'; penwidth = 0 }
                }
            }

            # Object Repositories Graphviz Cluster
            if ($ObjectRepositoriesInfo = Get-VbrObjectRepoInfo) {
                $ObjectRepositoriesNode = try {
                    Node ObjectRepositories @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ObjectRepositoriesInfo.Name -Align "Center" -iconType $ObjectRepositoriesInfo.Icontype -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ObjectRepositoriesInfo.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create ObjectRepositories Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }
            }

            # Archive Object Repositories Graphviz Cluster
            if ($ArchObjRepositoriesInfo = Get-VbrArchObjectRepoInfo) {
                $ArchObjRepositoriesNode = try {
                    Node ArchObjectRepositories @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ArchObjRepositoriesInfo.Name -Align "Center" -iconType $ArchObjRepositoriesInfo.Icontype -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ArchObjRepositoriesInfo.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create ArchiveObjectRepositories Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }
            }
            if (($ObjectRepositoriesInfo -or $ArchObjRepositoriesInfo) -and ($ObjectRepositoriesNode -or $ArchObjRepositoriesNode)) {
                SubGraph ObjectRepos -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Object Storage" -IconType "VBR_Object" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                    if ($ObjectRepositoriesInfo) {
                        SubGraph ObjectRepo -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Object Repositories" -IconType "VBR_Object_Repository" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                            $ObjectRepositoriesNode

                        }
                    }

                    if ($ArchObjRepositoriesInfo) {
                        SubGraph ArchObjectRepo -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Archives Object Repositories" -IconType "VBR_Object_Repository" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                            $ArchObjRepositoriesNode

                        }
                    }
                }
            } else {
                SubGraph ObjectRepos -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Object Storage" -IconType "VBR_Object" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                    Node -Name ObjectRepo -Attributes @{Label = 'No Object Storage Repositories'; shape = "rectangle"; labelloc = 'c'; fixedsize = $true; width = "4"; height = "3"; fillColor = 'transparent'; penwidth = 0 }
                }
            }

            # WanAccels Graphviz Cluster
            if ($WanAccels = Get-VbrWanAccelInfo) {
                $WanAccelsNode = try {
                    Node WanAccelServer @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($WanAccels | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Wan_Accel" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $WanAccels.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create WanAccelerators Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }
            }
            if ($WanAccels -and $WanAccelsNode) {
                SubGraph WanAccels -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Wan Accelerators" -IconType "VBR_Wan_Accel" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                    $WanAccelsNode

                }
            }

            # Tapes Graphviz Cluster
            if ($TapeServerInfo = Get-VbrTapeServersInfo) {
                $TapeServerNode = try {
                    Node TapeServer @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeServerInfo.Name -Align "Center" -iconType "VBR_Tape_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeServerInfo.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create TapeServers Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }
                if ($TapeLibraryInfo = Get-VbrTapeLibraryInfo) {
                    $TapeLibraryNode = try {
                        Node TapeLibrary @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeLibraryInfo.Name -Align "Center" -iconType "VBR_Tape_Library" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeLibraryInfo.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create TapeLibrary Objects. Disabling the section"
                        Write-Verbose "Error Message: $($_.Exception.Message)"
                    }
                }
                if ($TapeVaultInfo = Get-VbrTapeVaultInfo) {
                    $TapeVaultNode = try {
                        Node TapeVault @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeVaultInfo.Name -Align "Center" -iconType "VBR_Tape_Vaults" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeVaultInfo.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create TapeVault Objects. Disabling the section"
                        Write-Verbose "Error Message: $($_.Exception.Message)"
                    }
                }
            }
            if ($TapeServerInfo -and $TapeServerNode) {
                SubGraph TapeInfra -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Tape Infrastructure" -IconType "VBR_Tape" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {
                    SubGraph TapeServers -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Tape Servers" -IconType "VBR_Tape_Server" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                        $TapeServerNode
                    }

                    if ($TapeLibraryInfo -and $TapeLibraryNode) {
                        SubGraph TapeLibraries -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Tape Library" -IconType "VBR_Tape_Library" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                            $TapeLibraryNode

                        }
                    }

                    if ($TapeVaultInfo -and $TapeVaultNode) {
                        SubGraph TapeVaults -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Tape Vaults" -IconType "VBR_Tape_Vaults" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = 'dashed,rounded' } {

                            $TapeVaultNode

                        }
                    }
                }
            }

            # ServiceProvider Graphviz Cluster
            if ($ServiceProviderInfo = Get-VbrServiceProviderInfo) {
                $ServiceProviderNode = try {
                    Node ServiceProvider @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $ServiceProviderInfo.Name -Align "Center" -iconType "VBR_Service_Providers_Server" -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $ServiceProviderInfo.AditionalInfo); shape = 'plain'; fillColor = 'transparent'; fontname = "Segoe Ui" }
                } catch {
                    Write-Verbose "Error: Unable to create ServiceProvider Objects. Disabling the section"
                    Write-Verbose "Error Message: $($_.Exception.Message)"
                }
            }
            if ($ServiceProviderInfo -and $ServiceProviderNode) {
                SubGraph ServiceProviders -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label "Service Providers" -IconType "VBR_Service_Providers" -SubgraphLabel -IconDebug $IconDebug); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                    $ServiceProviderNode

                }
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

            Node $Node -NodeScript { $_ } @{Label = { $_ } ; fontcolor = $NodeDebug.color; fillColor = $NodeDebug.style; shape = $NodeDebug.shape }

            $NodeStartEnd = @('VBRStartPoint', 'VBREndPointSpace')
            Node $NodeStartEnd -NodeScript { $_ } @{Label = { $_ }; fillColor = '#71797E'; fontcolor = $NodeDebug.color; shape = 'point'; fixedsize = 'true'; width = .2 ; height = .2 }
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

            # Connect the Dummy Node in a straight line
            # VBRStartPoint --- VBRServerPointSpace --- VBRProxyPoint --- VBRProxyPointSpace --- VBRRepoPoint --- VBREndPointSpace
            Edge -From VBRStartPoint -To VBRServerPointSpace @{minlen = 20; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            Edge -From VBRServerPointSpace -To VBRProxyPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            Edge -From VBRProxyPoint -To VBRProxyPointSpace @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            Edge -From VBRProxyPointSpace -To VBRRepoPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            Edge -From VBRRepoPoint -To VBRRepoPointSpace @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }

            if ($TapeServerNode -and $WanAccelsNode -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'

            } elseif ($TapeServerNode -and (-Not $WanAccelsNode) -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRTapePoint -To VBRServiceProviderPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            } elseif ($TapeServerNode -and (-Not $WanAccels) -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRTapePoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'
            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRServiceProviderPoint @{minlen = 16; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'
            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and $ServiceProviderNode) {
                Edge -From VBRRepoPointSpace -To VBRServiceProviderPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRServiceProviderPoint'

            } elseif ((-Not $TapeServerNode) -and $WanAccelsNode -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRWanAccelPoint'
            } elseif ($TapeServerNode -and $WanAccelsNode -and (-Not $ServiceProviderNode)) {
                Edge -From VBRRepoPointSpace -To VBRWanAccelPoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                Edge -From VBRWanAccelPoint -To VBRTapePoint @{minlen = 12; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
                $LastPoint = 'VBRTapePoint'
            } elseif ((-Not $TapeServerNode) -and (-Not $WanAccelsNode) -and (-Not $ServiceProviderNode)) {
                $LastPoint = 'VBRRepoPointSpace'
            }

            ####################################################################################
            #                                                                                  #
            #      This section connect the Infrastructure component to the Dummy Points       #
            #                                                                                  #
            ####################################################################################

            # Connect Veeam Backup server to the Dummy line
            Edge -From $BackupServerInfo.Name -To VBRServerPointSpace @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }

            # Connect Veeam Proxies Server to the Dummy line
            if ($Proxies | Where-Object { $_.AditionalInfo.Type -eq 'vSphere' }) {
                Edge -From VBRProxyPoint -To ViProxies @{minlen = 2; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
            } elseif (-Not ($Proxies | Where-Object { $_.AditionalInfo.Type -eq 'vSphere' }) -and ($Proxies.AditionalInfo | Where-Object { $_.Type -eq "Off host" -or $_.Type -eq "On host" })) {
                Edge -From VBRProxyPoint -To HvProxies @{minlen = 2; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
            } else {
                Edge -From VBRProxyPoint -To Proxies @{minlen = 2; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }

            }
            # Connect Veeam Repository to the Dummy line
            Edge -From VBRRepoPoint -To Repositories @{minlen = 2; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }

            # Connect Veeam Object Repository to the Dummy line
            if ($ObjectRepositoriesInfo -and $ObjectRepositoriesNode) {
                Edge -To VBRRepoPoint -From ObjectRepositories @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }

            } elseif ($ArchObjRepositoriesInfo -and $ArchObjRepositoriesNode) {
                Edge -To VBRRepoPoint -From ArchObjectRepositories @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            } else {
                Edge -To VBRRepoPoint -From ObjectRepo @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            # Connect Veeam Wan Accelerator to the Dummy line
            if ($WanAccels -and $WanAccelsNode) {
                Edge -From WanAccelServer -To VBRWanAccelPoint @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            # Connect Veeam Scale-Out Backup Repository to the Dummy line
            if ($SOBR -and $SOBRNode) {
                Edge -From VBRRepoPointSpace -To SOBRRepo @{minlen = 2; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
            }

            # Connect Veeam Tape Infra to VBRTapePoint Dummy line
            if ($TapeServerInfo -and $TapeServerNode) {
                Edge -From VBRTapePoint -To TapeServer @{minlen = 2; arrowtail = 'none'; arrowhead = 'dot'; style = 'dashed' }
            }

            # Connect Veeam ServiceProvider Infra to VBRServiceProviderPoint Dummy line
            if ($ServiceProviderInfo -and $ServiceProviderNode) {
                Edge -From ServiceProvider -To VBRServiceProviderPoint @{minlen = 2; arrowtail = 'dot'; arrowhead = 'none'; style = 'dashed' }
            }

            ####################################################################################
            #                                                                                  #
            #   This section connect the Last Infrastructure component to VBREndPointSpace     #
            #                                                                                  #
            ####################################################################################

            if ($LastPoint) {
                Edge -From $LastPoint -To VBREndPointSpace @{minlen = 30; arrowtail = 'none'; arrowhead = 'none'; style = 'filled' }
            }
        }
    }
    end {}
}