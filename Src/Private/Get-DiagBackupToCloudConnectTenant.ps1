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

    Param
    (

    )

    begin {
    }

    process {
        # Cloud Connect Graphviz Cluster
        $CloudConnectTenantArray = @()


        if ($CCPerTenantInfo = Get-VbrBackupCCPerTenantInfo -TenantName $TenantName) {

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
                    Edge -From 'TenantInfo' -To 'InvertedTMiddleTop' -Attributes @{
                        color = $Edgecolor;
                        style = 'dashed';
                        fontname = 'Segoe Ui';
                        fontsize = 14;
                        arrowtail = 'dot';
                        arrowhead = 'none';
                    }
                }

            } catch {
                Write-Verbose 'Error: Unable to create TenantInfo Objects. Panic!'
                Write-Debug "Error Message: $($_.Exception.Message)"
                throw
            }

            Add-DiaInvertedTShapeLine -InvertedTEnd 'TenantGatewayPoolConnector' -InvertedTEndLineLength 5 -LineColor $Edgecolor -LineStyle 'dashed' -IconDebug $IconDebug -LineWidth $EdgeLineWidth

            if ($CGPoolInfo = $CCPerTenantInfo.CloudGatewayPools) {
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
                            Node 'TenantGatewayPool' -Attributes @{
                                Label = $CGPoolNodesSubGraph;
                                shape = 'plain';
                                fillColor = 'transparent';
                                fontsize = 14;
                                fontname = 'Segoe Ui'
                            }

                            Rank 'TenantGatewayPool', 'TenantGatewayPoolConnector'

                            Edge -From 'TenantGatewayPoolConnector' -To 'TenantGatewayPool' -Attributes @{
                                color = $Edgecolor;
                                style = 'dashed';
                                fontname = 'Segoe Ui';
                                fontsize = 14
                                arrowtail = 'none';
                                arrowhead = 'dot';
                            }
                        }
                    }
                } catch {
                    Write-Verbose 'Error: Unable to create CGPoolInfo SubGraph Objects. Disabling the section'
                    Write-Debug "Error Message: $($_.Exception.Message)"
                }
            }
        }
    }
    end {}
}