function Get-DiagBackupToSobr {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.0.2
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
                $Rank = @()
                if ($SobrRepo) {
                    SubGraph SOBR -Attributes @{Label=''; fontsize=18; penwidth=1.5; labelloc='t'; style = "dashed"} {
                        # Node used for subgraph centering
                        node SOBREPO @{Label='SOBR Repository'; fontsize=18; fontname="Comic Sans MS bold"; fontcolor='#005f4b'}
                        foreach ($SOBROBJ in $SobrRepo) {
                            $SubGraphName = Remove-SpecialChars -String $SOBROBJ.Name -SpecialChars '\- '
                            SubGraph $SubGraphName  -Attributes @{Label=$SOBROBJ.Name; fontsize=18; penwidth=1.5; labelloc='t'} {
                                $SOBRHASHTABLE = @{}
                                $SOBROBJ.psobject.properties | ForEach-Object { $SOBRHASHTABLE[$_.Name] = $_.Value }
                                node $SOBROBJ -NodeScript {$_.Name} @{Label=$SOBRHASHTABLE.Label}
                                if ($SOBROBJ.Performance) {
                                    SubGraph "$($SubGraphName)Performance" -Attributes @{Label="Performance Extent"; fontsize=18; penwidth=1.5; labelloc='b'} {

                                        $SOBROBJ.Performance | ForEach-Object {node $_.Name @{Label=Get-NodeIcon -Name $_.Name -Type $_.Icon -Align "Center" -Rows $_.Rows}}
                                    }
                                }
                                if ($SOBROBJ.Capacity) {
                                    SubGraph "$($SubGraphName)Capacity" -Attributes @{Label="Capacity Extent"; fontsize=18; penwidth=1.5; labelloc='b'} {

                                        $SOBROBJ.Capacity | ForEach-Object {node $_.Name @{Label=Get-NodeIcon -Name $_.Name -Type $_.Icon -Align "Center" -Rows $_.Rows}}
                                    }
                                }
                                if ($SOBROBJ.Archive) {
                                    SubGraph "$($SubGraphName)Archive" -Attributes @{Label="Archive Extent"; fontsize=18; penwidth=1.5; labelloc='b'} {

                                        $SOBROBJ.Archive | ForEach-Object {node $_.Name @{Label=Get-NodeIcon -Name $_.Name -Type $_.Icon -Align "Center" -Rows $_.Rows}}
                                    }
                                }

                                if ($SOBROBJ.Archive) {
                                    $SOBROBJ.Performance | ForEach-Object {edge -from $SOBROBJ.Name -to $SOBROBJ.Archive.Name,$SOBROBJ.Capacity.Name,$_.Name @{minlen=2}} | Select-Object -Unique

                                } else {$SOBROBJ.Performance | ForEach-Object {edge -from $SOBROBJ.Name -to $SOBROBJ.Capacity.Name,$_.Name @{minlen=2}} | Select-Object -Unique}
                            }
                            edge -From SOBREPO -To $SOBROBJ.Name @{minlen=1; style='invis'}
                        }
                    }
                    edge -from $BackupServerInfo.Name -to SOBREPO @{minlen=2}

                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}