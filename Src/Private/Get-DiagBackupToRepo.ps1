function Get-DiagBackupToRepo {
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

            $BackupRepo = Get-VbrBackupRepoInfo
            $LocalBackupRepo = Get-VbrBackupRepoInfo | Where-Object {$_.Role -like '*Local'}
            $RemoteBackupRepo = Get-VbrBackupRepoInfo | Where-Object {$_.Role -like 'Dedup*'}
            $SobrRepo = Get-VbrSobrInfo
            $ObjStorage = Get-VbrBackupObjectRepoInfo

            if ($BackupServerInfo) {

                if ($BackupRepo) {
                    if ($LocalBackupRepo) {
                        SubGraph LocalRepos -Attributes @{Label='Local Repository'; fontsize=18; penwidth=1.5; labelloc='b'} {
                            foreach ($REPOOBJ in $LocalBackupRepo) {
                                $REPOHASHTABLE = @{}
                                $REPOOBJ.psobject.properties | Foreach {$REPOHASHTABLE[$_.Name] = $_.Value }
                                node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label}
                            }
                            rank $LocalBackupRepo.Name -NodeScript {$_.Name}
                        }
                    }
                    if ($RemoteBackupRepo) {
                        SubGraph RemoteRepos -Attributes @{Label='Deduplicating Storage Appliances'; fontsize=18; penwidth=1.5; labelloc='b'; rank='LR'} {
                            foreach ($REPOOBJ in $RemoteBackupRepo) {
                                $REPOHASHTABLE = @{}
                                $REPOOBJ.psobject.properties | Foreach { $REPOHASHTABLE[$_.Name] = $_.Value }
                                node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label}
                            }
                            rank $RemoteBackupRepo.Name -NodeScript {$_.Name}
                        }
                    }
                    if ($ObjStorage) {
                        SubGraph ObjectStorage -Attributes @{Label='Object Repository'; fontsize=18; penwidth=1.5; labelloc='t'} {
                            foreach ($STORAGEOBJ in $ObjStorage) {
                                $OBJHASHTABLE = @{}
                                $STORAGEOBJ.psobject.properties | Foreach { $OBJHASHTABLE[$_.Name] = $_.Value }
                                node $STORAGEOBJ -NodeScript {$_.Name} @{Label=$OBJHASHTABLE.Label}
                            }
                            rank $ObjStorage.Name -NodeScript {$_.Name}
                        }
                    }

                    if ($SobrRepo) {
                        SubGraph SOBR -Attributes @{Label='SOBR Repository'; fontsize=18; penwidth=1.5; labelloc='t'} {
                            foreach ($SOBROBJ in $SobrRepo) {
                                $SOBRHASHTABLE = @{}
                                $SOBROBJ.psobject.properties | Foreach { $SOBRHASHTABLE[$_.Name] = $_.Value }
                                node $SOBROBJ -NodeScript {$_.Name} @{Label=$SOBRHASHTABLE.Label}
                                edge -from $SOBROBJ.Name -to $SOBROBJ.Capacity,$SOBROBJ.Performance @{minlen=3}
                            }
                            rank $SobrRepo.Name -NodeScript {$_.Name}
                        }

                        edge -from $BackupServerInfo.Name -to $SobrRepo.Name @{minlen=3}
                    }

                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}