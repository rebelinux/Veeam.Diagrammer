function Get-DiagBackupToSobr {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.19
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
            $SobrRepo = Get-VbrBackupSobrInfo

            if ($SobrRepo) {
                if ($SobrRepo) {
                    $SOBRArray = @()
                    foreach ($SOBROBJ in $SobrRepo) {

                        $SOBRExtentNodesArray = @()
                        $SOBRNodesArray = @()

                        $SOBROBJNode = $SOBROBJ.Label

                        if ($SOBROBJNode) {
                            $SOBRNodesArray += $SOBROBJNode
                        }

                        if ($SOBROBJ.Performance) {
                            try {
                                $Performance = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $SOBROBJ.Performance.Name -Align "Center" -iconType $SOBROBJ.Performance.IconType -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $SOBROBJ.Performance.AditionalInfo -Subgraph -SubgraphLabel "Performance Extent" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
                            } catch {
                                Write-Verbose "Error: Unable to create SOBR Performance Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }

                            if ($Performance) {
                                $SOBRExtentNodesArray += $Performance
                            }
                        }
                        if ($SOBROBJ.Capacity) {

                            try {
                                $Capacity = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $SOBROBJ.Capacity.Name -Align "Center" -iconType $SOBROBJ.Capacity.IconType -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $SOBROBJ.Capacity.AditionalInfo -Subgraph -SubgraphLabel "Capacity Extent" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"
                            } catch {
                                Write-Verbose "Error: Unable to create SOBR Capacity Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }

                            if ($Capacity) {
                                $SOBRExtentNodesArray += $Capacity
                            }
                        }
                        if ($SOBROBJ.Archive) {

                            try {
                                $Archive = Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $SOBROBJ.Archive.Name -Align "Center" -iconType $SOBROBJ.Archive.IconType -columnSize 3 -IconDebug $IconDebug -MultiIcon -AditionalInfo $SOBROBJ.Archive.AditionalInfo -Subgraph -SubgraphLabel "Archive Extent" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"

                            } catch {
                                Write-Verbose "Error: Unable to create SOBR Archive Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }

                            if ($Archive) {
                                $SOBRExtentNodesArray += $Archive
                            }
                        }

                        try {
                            $SOBRExtentSubgraphNode = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $SOBRExtentNodesArray  -Align 'Center' -IconDebug $IconDebug -Label 'Extents' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3
                        } catch {
                            Write-Verbose "Error: Unable to create SOBR Extents SubGraph Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($SOBRExtentSubgraphNode) {
                            $SOBRNodesArray += $SOBRExtentSubgraphNode
                        }

                        try {
                            $SOBRSubgraphNode = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $SOBRNodesArray  -Align 'Center' -IconDebug $IconDebug -Label $SOBROBJ.Name -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1
                        } catch {
                            Write-Verbose "Error: Unable to create SOBR SubGraph Nodes Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($SOBRSubgraphNode) {
                            $SOBRArray += $SOBRSubgraphNode
                        }
                    }

                    if ($Dir -eq 'LR') {
                        try {
                            $SOBRSubgraph = Node -Name SOBRRepo -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $SOBRArray  -Align 'Center' -IconDebug $IconDebug -Label 'SOBR Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                        } catch {
                            Write-Verbose "Error: Unable to create SubGraph Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    } else {
                        try {
                            $SOBRSubgraph = Node -Name SOBRRepo -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $SOBRArray  -Align 'Center' -IconDebug $IconDebug -Label 'SOBR Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                        } catch {
                            Write-Verbose "Error: Unable to create SubGraph Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                    }

                    if ($SOBRSubgraph) {
                        $SOBRSubgraph
                    }

                    Edge -From $BackupServerInfo.Name -To SOBRRepo @{minlen = 3 }

                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}