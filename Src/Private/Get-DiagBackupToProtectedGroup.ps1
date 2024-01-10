function Get-DiagBackupToProtectedGroup {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Protected Group diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.7
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
    process {
        try {

            $ProtectedGroups = Get-VbrBackupProtectedGroupInfo
            $ADContainer = $ProtectedGroups | Where-Object {$_.Container -eq 'ActiveDirectory'}
            $ManualContainer = $ProtectedGroups | Where-Object {$_.Container -eq 'ManuallyDeployed'}
            $IndividualContainer = $ProtectedGroups | Where-Object {$_.Container -eq 'IndividualComputers'}
            $CSVContainer = $ProtectedGroups | Where-Object {$_.Container -eq 'CSV'}

            if ($ProtectedGroups) {
                if ($Dir -eq 'LR') {
                    $DiagramLabel = 'Protected Groups'
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = 'Protected Groups'
                }

                if ($ProtectedGroups) {
                    SubGraph MainSubGraph -Attributes @{Label=$DiagramLabel; fontsize=22; penwidth=1; labelloc='t'; style='dashed,rounded'; color=$SubGraphDebug.color} {
                        # Node used for subgraph centering
                        node ProtectedGroup @{Label=$DiagramDummyLabel; fontsize=22; fontname="Segoe Ui Black"; fontcolor='#005f4b'; shape='plain'}
                        if ($Dir -eq "TB") {
                            node DummyPGLeft @{Label='DummyPGLeft'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node DummyPGLeftt @{Label='DummyPGLeftt'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node DummyPGRight @{Label='DummyPGRight'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            edge DummyPGLeft,DummyPGLeftt,ProtectedGroup,DummyPGRight @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                            rank DummyPGLeft,DummyPGLeftt,ProtectedGroup,DummyPGRight
                        }
                        if ($ADContainer) {
                            SubGraph ADContainer -Attributes @{Label=(Get-HTMLLabel -Label 'Active Directory Computers' -Type "VBR_AGENT_AD_Logo" -SubgraphLabel); fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                # Node used for subgraph centering
                                node DummyADContainer @{Label='DummyADC'; style=$SubGraphDebug.style; color=$SubGraphDebug.color; shape='plain'}
                                if ($ADContainer.count -le 3) {
                                    foreach ($PGOBJ in ($ADContainer | Sort-Object -Property Name)) {
                                        $PGHASHTABLE = @{}
                                        $PGOBJ.psobject.properties | ForEach-Object {$PGHASHTABLE[$_.Name] = $_.Value }
                                        node $PGOBJ -NodeScript {$_.Name} @{Label=$PGHASHTABLE.Label; fontname="Segoe Ui"}
                                        # Main Forest Root Node
                                        $Rows = @(
                                            "<B>Domain</B> : PHAMRAX"
                                            "<B>OUs</B> : OU=VDI-Computers,DC=pharmax,DC=local"
                                        )

                                        Convert-TableToHTML -Label "Objects" -Name "$($PGOBJ.Name)Objects" -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14

                                        edge -from $PGOBJ.Name -to "$($PGOBJ.Name)Objects"
                                    }

                                    edge -from DummyADContainer -to $ADContainer.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($ADContainer | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ADGroup$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $PGHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {PGHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$PGHASHTABLE.Label; fontname="Segoe Ui"}
                                            }
                                        }
                                        $Number++
                                    }

                                    edge -From DummyADContainer -To $Group[0].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $LocalPGNum = 1
                                    while ($LocalPGNum -ne $Group.Length) {
                                        edge -From $Group[$Start].Name -To $Group[$LocalPGNum].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $LocalPGNum++
                                    }
                                }
                            }
                            edge -from ProtectedGroup -to DummyADContainer @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        if ($ManualContainer) {
                            SubGraph MCContainer -Attributes @{Label=(Get-HTMLLabel -Label 'Manual Computers' -Type "VBR_AGENT_MC" -SubgraphLabel); fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                # Node used for subgraph centering
                                node DummyMCContainer @{Label='DummyMC'; style=$SubGraphDebug.style; color=$SubGraphDebug.color; shape='plain'}
                                if ($ManualContainer.count -le 3) {
                                    foreach ($PGOBJ in ($ManualContainer | Sort-Object -Property Name)) {
                                        $PGHASHTABLE = @{}
                                        $PGOBJ.psobject.properties | ForEach-Object {$PGHASHTABLE[$_.Name] = $_.Value }
                                        node $PGOBJ -NodeScript {$_.Name} @{Label=$PGHASHTABLE.Label; fontname="Segoe Ui"}
                                    }

                                    edge -from DummyMCContainer -to $ManualContainer.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($ManualContainer | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "MCGroup$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $PGHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {PGHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$PGHASHTABLE.Label; fontname="Segoe Ui"}
                                            }
                                        }
                                        $Number++
                                    }

                                    edge -From DummyMCContainer -To $Group[0].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $LocalPGNum = 1
                                    while ($LocalPGNum -ne $Group.Length) {
                                        edge -From $Group[$Start].Name -To $Group[$LocalPGNum].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $LocalPGNum++
                                    }
                                }
                            }
                            edge -from ProtectedGroup -to DummyMCContainer @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        if ($IndividualContainer) {
                            SubGraph ICContainer -Attributes @{Label=(Get-HTMLLabel -Label 'Individial Computers' -Type "VBR_AGENT_IC" -SubgraphLabel); fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                # Node used for subgraph centering
                                node DummyICContainer @{Label='DummyIC'; style=$SubGraphDebug.style; color=$SubGraphDebug.color; shape='plain'}
                                if ($IndividualContainer.count -le 3) {
                                    foreach ($PGOBJ in ($IndividualContainer | Sort-Object -Property Name)) {
                                        $PGHASHTABLE = @{}
                                        $PGOBJ.psobject.properties | ForEach-Object {$PGHASHTABLE[$_.Name] = $_.Value }
                                        node $PGOBJ -NodeScript {$_.Name} @{Label=$PGHASHTABLE.Label; fontname="Segoe Ui"}
                                    }

                                    edge -from DummyICContainer -to $IndividualContainer.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($IndividualContainer | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ICGroup$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $PGHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {PGHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$PGHASHTABLE.Label; fontname="Segoe Ui"}
                                            }
                                        }
                                        $Number++
                                    }

                                    edge -From DummyICContainer -To $Group[0].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $LocalPGNum = 1
                                    while ($LocalPGNum -ne $Group.Length) {
                                        edge -From $Group[$Start].Name -To $Group[$LocalPGNum].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $LocalPGNum++
                                    }
                                }
                            }
                            edge -from ProtectedGroup -to DummyICContainer @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        if ($CSVContainer) {
                            SubGraph CSVContainer -Attributes @{Label=(Get-HTMLLabel -Label 'CSV Computers' -Type "VBR_AGENT_CSV_Logo" -SubgraphLabel); fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                # Node used for subgraph centering
                                node DummyCSVContainer @{Label='DummyCSVC'; style=$SubGraphDebug.style; color=$SubGraphDebug.color; shape='plain'}
                                if ($CSVContainer.count -le 3) {
                                    foreach ($PGOBJ in ($CSVContainer | Sort-Object -Property Name)) {
                                        $PGHASHTABLE = @{}
                                        $PGOBJ.psobject.properties | ForEach-Object {$PGHASHTABLE[$_.Name] = $_.Value }
                                        node $PGOBJ -NodeScript {$_.Name} @{Label=$PGHASHTABLE.Label; fontname="Segoe Ui"}
                                    }

                                    edge -from DummyCSVContainer -to $CSVContainer.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($CSVContainer | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "CSVGroup$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $PGHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {PGHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$PGHASHTABLE.Label; fontname="Segoe Ui"}
                                            }
                                        }
                                        $Number++
                                    }

                                    edge -From DummyCSVContainer -To $Group[0].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $LocalPGNum = 1
                                    while ($LocalPGNum -ne $Group.Length) {
                                        edge -From $Group[$Start].Name -To $Group[$LocalPGNum].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $LocalPGNum++
                                    }
                                }
                            }
                            edge -from ProtectedGroup -to DummyCSVContainer @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                    }

                    edge -from $BackupServerInfo.Name -to ProtectedGroup @{minlen=3}
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}