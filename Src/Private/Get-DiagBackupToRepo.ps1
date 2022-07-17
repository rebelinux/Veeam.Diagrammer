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
            $SANBackupRepo = Get-VbrBackupRepoInfo | Where-Object {$_.Role -like 'SAN'}
            $ObjStorage = Get-VbrBackupObjectRepoInfo
            $ArchiveObjStorage = Get-VbrBackupArchObjRepoInfo

            if ($BackupServerInfo) {

                if ($BackupRepo) {
                    SubGraph MainRepos -Attributes @{Label=''; fontsize=18; penwidth=1; labelloc='b'} {
                        # Node used for subgraph centering
                        node BackupRepository @{Label='Backup Repositories'; fontsize=18; fontname="Comic Sans MS bold"; fontcolor='#005f4b'}
                        $Rank = @()
                        if ($LocalBackupRepo) {
                            SubGraph LocalRepos -Attributes @{Label='Local Repository'; fontsize=18; penwidth=1.5; labelloc='t'} {
                                foreach ($REPOOBJ in ($LocalBackupRepo | Sort-Object)) {
                                    $REPOHASHTABLE = @{}
                                    $REPOOBJ.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                    node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label}
                                }
                            }
                            $Rank += 'LocalRepos'
                            edge -from BackupRepository -to $LocalBackupRepo.Name @{minlen=1; style='invis'}
                        }
                        if ($RemoteBackupRepo) {
                            SubGraph RemoteRepos -Attributes @{Label='Deduplicating Storage Appliances'; fontsize=18; penwidth=1.5; labelloc='t'} {
                                foreach ($REPOOBJ in ($RemoteBackupRepo | Sort-Object)) {
                                    $REPOHASHTABLE = @{}
                                    $REPOOBJ.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                    node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label;}
                                }
                            }
                            $Rank += 'RemoteRepos'
                            edge -from BackupRepository -to $RemoteBackupRepo.Name @{minlen=1; style='invis'}

                        }
                        if ($SANBackupRepo) {
                            SubGraph SANRepos -Attributes @{Label='SAN Repository'; fontsize=18; penwidth=1.5; labelloc='t'} {
                                foreach ($REPOOBJ in ($SANBackupRepo | Sort-Object)) {
                                    $REPOHASHTABLE = @{}
                                    $REPOOBJ.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                    node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label}
                                }
                            }
                            $Rank += 'SANRepos'
                            edge -from BackupRepository -to $SANBackupRepo.Name @{minlen=1; style='invis'}
                        }
                        if ($ObjStorage) {
                            SubGraph ObjectStorage -Attributes @{Label='Object Repository'; fontsize=18; penwidth=1.5; labelloc='t'} {
                                foreach ($STORAGEOBJ in ($ObjStorage | Sort-Object)) {
                                    $OBJHASHTABLE = @{}
                                    $STORAGEOBJ.psobject.properties | ForEach-Object { $OBJHASHTABLE[$_.Name] = $_.Value }
                                    node $STORAGEOBJ -NodeScript {$_.Name} @{Label=$OBJHASHTABLE.Label}
                                }
                            }
                            $Rank += 'ObjectStorage'
                            edge -from BackupRepository -to $ObjStorage.Name @{minlen=1; style='invis'}

                        }
                        if ($ArchiveObjStorage) {
                            SubGraph ArchiveObjectStorage -Attributes @{Label='Archive Object Repository'; fontsize=18; penwidth=1.5; labelloc='t'} {
                                foreach ($STORAGEArchiveOBJ in ($ArchiveObjStorage | Sort-Object)) {
                                    $ARCHOBJHASHTABLE = @{}
                                    $STORAGEArchiveOBJ.psobject.properties | ForEach-Object { $ARCHOBJHASHTABLE[$_.Name] = $_.Value }
                                    node $STORAGEArchiveOBJ -NodeScript {$_.Name} @{Label=$ARCHOBJHASHTABLE.Label}
                                }
                            }
                            $Rank += 'ArchiveObjectStorage'
                            edge -from BackupRepository -to $ArchiveObjStorage.Name @{minlen=1; style='invis'}

                        }
                        rank $Rank
                    }
                    edge -from $BackupServerInfo.Name -to BackupRepository @{minlen=3}
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}