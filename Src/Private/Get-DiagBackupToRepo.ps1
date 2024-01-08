function Get-DiagBackupToRepo {
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

            $BackupRepo = Get-VbrBackupRepoInfo
            $LocalBackupRepo = Get-VbrBackupRepoInfo | Where-Object {$_.Role -like '*Local'}
            $RemoteBackupRepo = Get-VbrBackupRepoInfo | Where-Object {$_.Role -like 'Dedup*'}
            $ObjStorage = Get-VbrBackupObjectRepoInfo
            $ArchiveObjStorage = Get-VbrBackupArchObjRepoInfo

            if ($BackupServerInfo) {
                if ($Dir -eq 'LR') {
                    $DiagramLabel = 'Backup Repositories'
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = 'Backup Repository'
                }

                if ($BackupRepo) {
                    SubGraph MainSubGraph -Attributes @{Label=$DiagramLabel; fontsize=22; penwidth=1; labelloc='t'; style='dashed,rounded'; color=$SubGraphDebug.color} {
                        # Node used for subgraph centering
                        node BackupRepository @{Label=$DiagramDummyLabel; fontsize=22; fontname="Segoe Ui Black"; fontcolor='#005f4b'; shape='plain'}
                        if ($Dir -eq "TB") {
                            node RepoLeft @{Label='RepoLeft'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node RepoLeftt @{Label='RepoLeftt'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            node RepoRight @{Label='RepoRight'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                            edge RepoLeft,RepoLeftt,BackupRepository,RepoRight @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                            rank RepoLeft,RepoLeftt,BackupRepository,RepoRight
                        }
                        if ($LocalBackupRepo) {
                            SubGraph LocalRepos -Attributes @{Label='Local Repository'; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                # Node used for subgraph centering
                                node LocalReposDummy @{Label='LocalReposDummy'; style=$SubGraphDebug.style; color=$SubGraphDebug.color; shape='plain'}
                                if ($LocalBackupRepo.count -le 3) {
                                    foreach ($REPOOBJ in ($LocalBackupRepo | Sort-Object -Property Name)) {
                                        $REPOHASHTABLE = @{}
                                        $REPOOBJ.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                        node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label; fontname="Segoe Ui"}
                                    }

                                    edge -from LocalReposDummy -to $LocalBackupRepo.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($LocalBackupRepo | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "LocalBackupGroup$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$REPOHASHTABLE.Label; fontname="Segoe Ui"}
                                            }
                                        }
                                        $Number++
                                    }

                                    edge -From LocalReposDummy -To $Group[0].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $LocalRepoNum = 1
                                    while ($LocalRepoNum -ne $Group.Length) {
                                        edge -From $Group[$Start].Name -To $Group[$LocalRepoNum].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $LocalRepoNum++
                                    }
                                }
                            }
                            edge -from BackupRepository -to LocalReposDummy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        if ($RemoteBackupRepo) {
                            SubGraph RemoteRepos -Attributes @{Label='Deduplicating Storage Appliances'; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                node RemoteReposDummy @{Label='RemoteReposDummy'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'}
                                if ($RemoteBackupRepo.count -le 3) {
                                    foreach ($REPOOBJ in ($RemoteBackupRepo | Sort-Object -Property Name)) {
                                        $REPOHASHTABLE = @{}
                                        $REPOOBJ.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                        node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label; fontname="Segoe Ui"}
                                    }

                                    edge -from RemoteReposDummy -to $RemoteBackupRepo.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($RemoteBackupRepo| Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "RemoteBackupRepo$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$REPOHASHTABLE.Label; fontname="Segoe Ui"}
                                            }
                                        }
                                        $Number++
                                    }

                                    edge -From RemoteReposDummy -To $Group[0].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $RemoteRepoNum = 1
                                    while ($RemoteRepoNum -ne $Group.Length) {
                                        edge -From $Group[$Start].Name -To $Group[$RemoteRepoNum].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $RemoteRepoNum++
                                    }
                                }
                            }
                            edge -from BackupRepository -to RemoteReposDummy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}

                        }
                        if ($ObjStorage) {
                            SubGraph ObjectStorage -Attributes @{Label='Object Repository'; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                node ObjectStorageDummy @{Label='ObjectStorageDummy'; style=$SubGraphDebug.style; color=$SubGraphDebug.color; shape='plain'}
                                if ($ObjStorage.count -le 3) {
                                    foreach ($STORAGEOBJ in ($ObjStorage | Sort-Object -Property Name)) {
                                        $OBJHASHTABLE = @{}
                                        $STORAGEOBJ.psobject.properties | ForEach-Object { $OBJHASHTABLE[$_.Name] = $_.Value }
                                        node $STORAGEOBJ -NodeScript {$_.Name} @{Label=$OBJHASHTABLE.Label; fontname="Segoe Ui"}
                                    }

                                    edge -from ObjectStorageDummy -to $ObjStorage.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($ObjStorage| Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ObjectStorage$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$REPOHASHTABLE.Label; fontname="Segoe Ui"}
                                            }
                                        }
                                        $Number++
                                    }

                                    edge -From ObjectStorageDummy -To $Group[0].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $ObjectStorageNum = 1
                                    while ($ObjectStorageNum -ne $Group.Length) {
                                        edge -From $Group[$Start].Name -To $Group[$ObjectStorageNum].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $ObjectStorageNum++
                                    }
                                }
                            }
                            edge -from BackupRepository -to ObjectStorageDummy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        if ($ArchiveObjStorage) {
                            SubGraph ArchiveObjectStorage -Attributes @{Label='Archive Object Repository'; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                node ArchiveObjectStorageDummy @{Label='ArchiveObjectStorageDummy'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'}
                                if ($ArchiveObjStorage.count -le 3) {
                                    foreach ($STORAGEArchiveOBJ in ($ArchiveObjStorage | Sort-Object -Property Name)) {
                                        $ARCHOBJHASHTABLE = @{}
                                        $STORAGEArchiveOBJ.psobject.properties | ForEach-Object { $ARCHOBJHASHTABLE[$_.Name] = $_.Value }
                                        node $STORAGEArchiveOBJ -NodeScript {$_.Name} @{Label=$ARCHOBJHASHTABLE.Label; fontname="Segoe Ui"}
                                    }

                                    edge -from ArchiveObjectStorageDummy -to $ArchiveObjStorage.Name @{constraint="true";minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($ArchiveObjStorage| Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ArchiveObjectStorage$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$REPOHASHTABLE.Label; fontname="Segoe Ui"}
                                            }
                                        }
                                        $Number++
                                    }

                                    edge -From ArchiveObjectStorageDummy -To $Group[0].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                    $Start = 0
                                    $ArchiveObjectStorageNum = 1
                                    while ($ArchiveObjectStorageNum -ne $Group.Length) {
                                        edge -From $Group[$Start].Name -To $Group[$ArchiveObjectStorageNum].Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                        $Start++
                                        $ArchiveObjectStorageNum++
                                    }
                                }
                            }
                            edge -from BackupRepository -to ArchiveObjectStorageDummy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}

                        }
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