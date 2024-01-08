function Get-DiagBackupToSobr {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.6
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
                    SubGraph MainSubGraph -Attributes @{Label=$DiagramLabel ; fontsize=22; penwidth=1.5; labelloc='t'; style='dashed,rounded'; color=$SubGraphDebug.color} {
                        # Dummy Node used for subgraph centering
                        node DummySOBREPO @{Label=$DiagramDummyLabel; fontsize=22; fontname="Segoe Ui Black"; fontcolor='#005f4b'; shape='plain'}
                        if ($Dir -eq 'TB') {
                            node SobrRepoLeft @{Label='SobrRepoLeft'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node SobrRepoLeftt @{Label='SobrRepoLeftt'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node SobrRepoRight @{Label='SobrRepoRight'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            edge SobrRepoLeft,SobrRepoLeftt,DummySOBREPO,SobrRepoRight @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                            rank SobrRepoLeft,SobrRepoLeftt,DummySOBREPO,SobrRepoRight
                        }
                        foreach ($SOBROBJ in $SobrRepo) {
                            $SubGraphName = Remove-SpecialChar -String $SOBROBJ.Name -SpecialChars '\- '
                            SubGraph $SubGraphName  -Attributes @{Label=$SOBROBJ.Name; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                $SOBRHASHTABLE = @{}
                                $SOBROBJ.psobject.properties | ForEach-Object { $SOBRHASHTABLE[$_.Name] = $_.Value }
                                node $SOBROBJ -NodeScript {$_.Name} @{Label=$SOBRHASHTABLE.Label; fontname="Segoe Ui"; shape="plain";}
                                if ($SOBROBJ.Performance) {
                                    SubGraph "$($SubGraphName)Performance" -Attributes @{Label="Performance Extent"; fontsize=18; penwidth=1.5; labelloc='b'; style="dashed,rounded";} {

                                        $SOBROBJ.Performance | ForEach-Object {node $_.Name @{Label=Get-NodeIcon -Name $_.Name -Type $_.Icon -Align "Center" -Rows $_.Rows; fontname="Segoe Ui"; shape="plain"}}
                                    }
                                }
                                if ($SOBROBJ.Capacity) {
                                    SubGraph "$($SubGraphName)Capacity" -Attributes @{Label="Capacity Extent"; fontsize=18; penwidth=1.5; labelloc='b'; style="dashed,rounded"} {

                                        $SOBROBJ.Capacity | ForEach-Object {node $_.Name @{Label=Get-NodeIcon -Name $_.Name -Type $_.Icon -Align "Center" -Rows $_.Rows; fontname="Segoe Ui"; shape="plain"}}
                                    }
                                }
                                if ($SOBROBJ.Archive) {
                                    SubGraph "$($SubGraphName)Archive" -Attributes @{Label="Archive Extent"; fontsize=18; penwidth=1.5; labelloc='b'; style="dashed,rounded"} {

                                        $SOBROBJ.Archive | ForEach-Object {node $_.Name @{Label=Get-NodeIcon -Name $_.Name -Type $_.Icon -Align "Center" -Rows $_.Rows; fontname="Segoe Ui"; shape="plain"}}
                                    }
                                }

                                if ($SOBROBJ.Archive) {
                                    $SOBROBJ.Performance | ForEach-Object {edge -from $SOBROBJ.Name -to $SOBROBJ.Archive.Name,$SOBROBJ.Capacity.Name,$_.Name @{minlen=2}} | Select-Object -Unique

                                } else {$SOBROBJ.Performance | ForEach-Object {edge -from $SOBROBJ.Name -to $SOBROBJ.Capacity.Name,$_.Name @{minlen=2}} | Select-Object -Unique}
                            }
                            edge -From DummySOBREPO -To $SOBROBJ.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                    }
                    edge -from $BackupServerInfo.Name -to DummySOBREPO @{minlen=3}

                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}