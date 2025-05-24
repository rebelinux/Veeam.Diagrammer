function Get-DiagBackupToCloudConnect {
    <#
    .SYNOPSIS
        Function to build Backup Server to Cloud Connect diagram.
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

    Param
    (

    )

    begin {
    }

    process {
        # Cloud Connect Graphviz Cluster
        $CloudConnectInfraArray = @()

        if ($CGServerInfo = Get-VbrBackupCGServerInfo) {
            if ($CGServerInfo.Name.Count -eq 1) {
                $CGServerNodeColumnSize = 1
            } elseif ($ColumnSize) {
                $CGServerNodeColumnSize = $ColumnSize
            } else {
                $CGServerNodeColumnSize = $CGServerInfo.Name.Count
            }
            try {
                $CGServerNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CGServerInfo.Name -Align "Center" -iconType "VBR_Cloud_Connect_Gateway" -columnSize $CGServerNodeColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CGServerInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Service_Providers_Server" -SubgraphLabel "Gateway Servers" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                $CloudConnectInfraArray += $CGServerNode
                # $CloudConnectInfraArray += $BlankFiller
            } catch {
                Write-Verbose "Error: Unable to create CloudGateway server Objects. Disabling the section"
                Write-Debug "Error Message: $($_.Exception.Message)"
            }
            if ($CGPoolInfo = Get-VbrBackupCGPoolInfo) {
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
                            Get-DiaHTMLTable -ImagesObj $Images -Rows $CGPool.CloudGateways.Name.split(".")[0] -Align 'Center' -ColumnSize $CGPoolInfocolumnSize -IconDebug $IconDebug -Subgraph -SubgraphIconType "VBR_Cloud_Connect_Gateway" -SubgraphLabel $CGPool.Name -SubgraphLabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -FontSize 18
                        } else {
                            Get-DiaHTMLTable -ImagesObj $Images -Rows 'No Cloud Gateway Server' -Align 'Center' -ColumnSize 1 -IconDebug $IconDebug -Subgraph -SubgraphIconType "VBR_Cloud_Connect_Gateway" -SubgraphLabel $CGPool.Name -SubgraphLabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -NoFontBold -FontSize 18
                        }
                    }
                } catch {
                    Write-Verbose "Error: Unable to create CGPoolInfo Objects. Disabling the section"
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
                        $CGPoolNodesSubGraph += Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CGPoolNode -Align 'Center' -IconDebug $IconDebug -Label 'Gateway Pools' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $CGPoolNodecolumnSize -fontSize 22 -IconType "VBR_Cloud_Connect_Gateway_Pools"

                        $CloudConnectInfraArray += $CGPoolNodesSubGraph
                        # $CloudConnectInfraArray += $BlankFiller
                    }
                } catch {
                    Write-Verbose "Error: Unable to create CGPoolInfo SubGraph Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }

            if ($CCBSInfo = Get-VbrBackupCCBackupStorageInfo) {
                if ($CCBSInfo.Name.count -le 5) {
                    $CCBSInfocolumnSize = $CCBSInfo.Name.count
                } elseif ($ColumnSize) {
                    $CCBSInfocolumnSize = $ColumnSize
                } else {
                    $CCBSInfocolumnSize = 5
                }
                try {
                    $CCBSNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCBSInfo.Name -Align "Center" -iconType $CCBSInfo.IconType -columnSize $CCBSInfocolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCBSInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Repository" -SubgraphLabel "Backup Storage" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                    $CloudConnectInfraArray += $CCBSNode
                    # $CloudConnectInfraArray += $BlankFiller
                } catch {
                    Write-Verbose "Error: Unable to create CCBSNode Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
            if ($CCRRInfo = Get-VbrBackupCCReplicaResourcesInfo) {
                if ($CCRRInfo.Name.count -le 5) {
                    $CCRRInfocolumnSize = $CCRRInfo.Name.count
                } elseif ($ColumnSize) {
                    $CCRRInfocolumnSize = $ColumnSize
                } else {
                    $CCRRInfocolumnSize = 5
                }
                try {
                    $CCRRNode = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $CCRRInfo.Name -Align "Center" -iconType "VBR_Hardware_Resources" -columnSize $CCRRInfocolumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $CCRRInfo.AditionalInfo -Subgraph -SubgraphIconType "VBR_Hardware_Resources" -SubgraphLabel "Replica Resources" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -TableBorderColor "#71797E" -TableBorder "1" -SubgraphLabelFontsize 22 -fontSize 18

                    $CloudConnectInfraArray += $CCRRNode
                    # $CloudConnectInfraArray += $BlankFiller
                } catch {
                    Write-Verbose "Error: Unable to create CCRRNode Objects. Disabling the section"
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
        }
        if ($CGServerInfo -and $CGServerNode) {
            if ($CloudConnectInfraArray.count -le 5) {
                $CGServerSubGraphcolumnSize = $CloudConnectInfraArray.count
            } elseif ($ColumnSize) {
                $CGServerSubGraphcolumnSize = $ColumnSize
            } else {
                $CGServerSubGraphcolumnSize = 4
            }
            try {
                $CGServerSubGraph = Node -Name "CloudConnectInfra" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudConnectInfraArray -Align 'Center' -IconDebug $IconDebug -IconType 'VBR_Cloud_Connect' -Label 'Cloud Connect Infrastructure' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $CGServerSubGraphcolumnSize -fontSize 24); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
            } catch {
                Write-Verbose "Error: Unable to create CloudConnectInfra SubGraph Objects. Disabling the section"
                Write-Debug "Error Message: $($_.Exception.Message)"
            }

            if ($CGServerSubGraph) {
                $CGServerSubGraph
                Edge BackupServers -To CloudConnectInfra @{minlen = 3; }
            }
        }
    }
    end {}
}