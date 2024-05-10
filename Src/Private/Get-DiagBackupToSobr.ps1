function Get-DiagBackupToSobr {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.0
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
            $SobrRepo = Get-VbrBackupSobrInfo

            if ($SobrRepo) {
                if ($Dir -eq 'LR') {
                    $DiagramLabel = 'SOBR Repository'
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = 'SOBR Repository'
                }
                if ($SobrRepo) {
                    SubGraph MainSubGraph -Attributes @{Label = $DiagramLabel ; fontsize = 22; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        # Dummy Node used for subgraph centering
                        Node DummySOBREPO @{Label = $DiagramDummyLabel; fontsize = 22; fontname = "Segoe Ui Black"; fontcolor = '#005f4b'; shape = 'plain' }
                        if ($Dir -eq 'TB') {
                            Node SobrRepoLeft @{Label = 'SobrRepoLeft'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Node SobrRepoLeftt @{Label = 'SobrRepoLeftt'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Node SobrRepoRight @{Label = 'SobrRepoRight'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            Edge SobrRepoLeft, SobrRepoLeftt, DummySOBREPO, SobrRepoRight @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                            Rank SobrRepoLeft, SobrRepoLeftt, DummySOBREPO, SobrRepoRight
                        }
                        foreach ($SOBROBJ in $SobrRepo) {
                            $SubGraphName = Remove-SpecialChar -String $SOBROBJ.Name -SpecialChars '\- '
                            SubGraph $SubGraphName  -Attributes @{Label = $SOBROBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                $SOBRHASHTABLE = @{}
                                $SOBROBJ.psobject.properties | ForEach-Object { $SOBRHASHTABLE[$_.Name] = $_.Value }
                                Node $SOBROBJ -NodeScript { $_.Name } @{Label = $SOBRHASHTABLE.Label; fontname = "Segoe Ui"; shape = "plain"; }
                                if ($SOBROBJ.Performance) {
                                    SubGraph "$($SubGraphName)Performance" -Attributes @{Label = "Performance Extent"; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = "dashed,rounded"; } {

                                        $SOBROBJ.Performance | ForEach-Object { Node $_.Name @{Label = Get-DiaNodeIcon -Name $_.Name -IconType $_.Icon -Align "Center" -Rows $_.Rows -ImagesObj $Images -IconDebug $IconDebug; fontname = "Segoe Ui"; shape = "plain" } }
                                    }
                                }
                                if ($SOBROBJ.Capacity) {
                                    SubGraph "$($SubGraphName)Capacity" -Attributes @{Label = "Capacity Extent"; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = "dashed,rounded" } {

                                        $SOBROBJ.Capacity | ForEach-Object { Node $_.Name @{Label = Get-DiaNodeIcon -Name $_.Name -IconType $_.Icon -Align "Center" -Rows $_.Rows -ImagesObj $Images -IconDebug $IconDebug; fontname = "Segoe Ui"; shape = "plain" } }
                                    }
                                }
                                if ($SOBROBJ.Archive) {
                                    SubGraph "$($SubGraphName)Archive" -Attributes @{Label = "Archive Extent"; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = "dashed,rounded" } {

                                        $SOBROBJ.Archive | ForEach-Object { Node $_.Name @{Label = Get-DiaNodeIcon -Name $_.Name -IconType $_.Icon -Align "Center" -Rows $_.Rows -ImagesObj $Images -IconDebug $IconDebug; fontname = "Segoe Ui"; shape = "plain" } }
                                    }
                                }

                                if ($SOBROBJ.Archive) {
                                    $SOBROBJ.Performance | ForEach-Object { Edge -From $SOBROBJ.Name -To $SOBROBJ.Archive.Name, $SOBROBJ.Capacity.Name, $_.Name @{minlen = 2 } } | Select-Object -Unique

                                } else { $SOBROBJ.Performance | ForEach-Object { Edge -From $SOBROBJ.Name -To $SOBROBJ.Capacity.Name, $_.Name @{minlen = 2 } } | Select-Object -Unique }
                            }
                            Edge -From DummySOBREPO -To $SOBROBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                    }
                    Edge -From $BackupServerInfo.Name -To DummySOBREPO @{minlen = 3 }

                }
            }
        } catch {
            $_
        }
    }
    end {}
}