function Get-DiagBackupToTape {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.10
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
        # Get Veeam Backup Server Object
        Get-DiagBackupServer
    }

    process {
        try {
            $BackupTapeServers = Get-VbrBackupTapeServerInfo
            $BackupTapeLibrary = Get-VbrBackupTapeLibraryInfo
            $BackupTapeDrives = Get-VbrBackupTapeDrivesInfo

            if ($BackupServerInfo) {
                if ($BackupTapeServers) {
                    $TapeArray = @()
                    foreach ($TSOBJ in ($BackupTapeServers | Sort-Object -Property Name)) {
                        $TapeNodesArray = @()

                        $TapeServerNode = $TSOBJ.Label

                        if ($BackupTapeLibrary) {
                            $BKPTLOBJ = ($BackupTapeLibrary | Where-Object { $_.TapeServerId -eq $TSOBJ.Id } | Sort-Object -Property Name)
                            foreach ($TSLibraryOBJ in $BKPTLOBJ) {

                                $TapeLibraryNodesArray = @()
                                $TapeLibrarySubArrayTable = @()

                                $TapeLibraryOBJNode = $TSLibraryOBJ.Label

                                if ($TapeLibraryOBJNode) {
                                    $TapeLibraryNodesArray += $TapeLibraryOBJNode
                                }

                                if ($BackupTapeDrives) {

                                    $TapeLibraryDrives = ($BackupTapeDrives | Where-Object { $_.LibraryId -eq $TSLibraryOBJ.Id } | Sort-Object -Property Name)

                                    $TapeLibraryDrivesNode = try {
                                        Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject $TapeLibraryDrives.Name -Align "Center" -iconType "VBR_Tape_Drive" -columnSize $TapeLibraryDrives.Name.Count -IconDebug $IconDebug -MultiIcon -AditionalInfo $TapeLibraryDrives.AditionalInfo -Subgraph -SubgraphLabel "Tape Drives" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"

                                    } catch {
                                        Write-Verbose "Error: Unable to create Tape Library Drives Objects. Disabling the section"
                                        Write-Verbose "Error Message: $($_.Exception.Message)"
                                    }

                                    if ($TapeLibraryDrivesNode) {
                                        $TapeLibraryNodesArray += $TapeLibraryDrivesNode
                                    }
                                }

                                $TapeLibrarySubgraph = try {
                                    Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $TapeLibraryNodesArray -Align 'Center' -IconDebug $IconDebug -Label "Tape Library" -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1
                                } catch {
                                    Write-Verbose "Error: Unable to create Tape Library SubGraph Objects. Disabling the section"
                                    Write-Verbose "Error Message: $($_.Exception.Message)"
                                }

                                if ($TapeLibrarySubgraph) {
                                    $TapeNodesArray += $TapeLibrarySubgraph
                                }
                            }
                        }

                        $TapeLibrarySubgraphArray = try {
                            Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $TapeNodesArray  -Align 'Center' -IconDebug $IconDebug -Label " " -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "0" -columnSize 3
                        } catch {
                            Write-Verbose "Error: Unable to create Tape Library SubGraph Array Objects. Disabling the section"
                            Write-Verbose "Error Message: $($_.Exception.Message)"
                        }

                        if ($TapeServerNode) {
                            $TapeLibrarySubArrayTable += $TapeServerNode
                        }

                        if ($TapeLibrarySubgraphArray) {
                            $TapeLibrarySubArrayTable += $TapeLibrarySubgraphArray
                        }

                        $TapeServerSubgraph = try {
                            Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $TapeLibrarySubArrayTable  -Align 'Center' -IconDebug $IconDebug -Label $TSOBJ.Name -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1
                        } catch {
                            Write-Verbose "Error: Unable to create Tape Server SubGraph Objects. Disabling the section"
                            Write-Verbose "Error Message: $($_.Exception.Message)"
                        }

                        if ($TapeServerSubgraph) {
                            $TapeArray += $TapeServerSubgraph
                        }
                    }
                    $TapeSubgraph = try {
                        Node -Name Tape -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $TapeArray  -Align 'Center' -IconDebug $IconDebug -Label 'Tape Servers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                    } catch {
                        Write-Verbose "Error: Unable to create Tape SubGraph Objects. Disabling the section"
                        Write-Verbose "Error Message: $($_.Exception.Message)"
                    }
                    if ($TapeSubgraph) {
                        $TapeSubgraph
                        Edge -From $BackupServerInfo.Name -To Tape @{minlen = 3 }
                    }
                }
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}