function Get-DiagBackupToRepo {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.1.0
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

                if ($BackupRepo) {
                    SubGraph MainRepos -Attributes @{Label=''; fontsize=18; penwidth=1; labelloc='b'; style=$SubGraphDebug.style; color=$SubGraphDebug.color} {
                        # Node used for subgraph centering
                        node BackupRepository @{Label='Backup Repositories'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                        $Rank = @()
                        if ($LocalBackupRepo) {
                            SubGraph LocalRepos -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed'} {
                                # Node used for subgraph centering
                                node LocalReposDummy @{Label='Local Repository'; fontsize=18; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                $Rank = @()
                                if ($LocalBackupRepo.count -le 4) {
                                    foreach ($REPOOBJ in ($LocalBackupRepo | Sort-Object -Property Name)) {
                                        $REPOHASHTABLE = @{}
                                        $REPOOBJ.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                        node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label}
                                    }
                                    edge -from LocalReposDummy -to $LocalBackupRepo.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($LocalBackupRepo | Sort-Object -Property Name) -size 4
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        SubGraph "LocalBackupGroup$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$REPOHASHTABLE.Label}
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
                            $Rank += 'LocalRepos'
                            edge -from BackupRepository -to LocalReposDummy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        if ($RemoteBackupRepo) {
                            SubGraph RemoteRepos -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed'} {
                                node RemoteReposDummy @{Label='Deduplicating Storage Appliances'; fontsize=18; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                if ($RemoteBackupRepo.count -le 4) {
                                    foreach ($REPOOBJ in ($RemoteBackupRepo | Sort-Object -Property Name)) {
                                        $REPOHASHTABLE = @{}
                                        $REPOOBJ.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                        node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label;}
                                    }
                                    edge -from RemoteReposDummy -to $RemoteBackupRepo.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($RemoteBackupRepo| Sort-Object -Property Name) -size 4
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        SubGraph "RemoteBackupRepo$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$REPOHASHTABLE.Label}
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
                            $Rank += 'RemoteRepos'
                            edge -from BackupRepository -to RemoteReposDummy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}

                        }
                        if ($ObjStorage) {
                            SubGraph ObjectStorage -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed'} {
                                node ObjectStorageDummy @{Label='Object Repository'; fontsize=18; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                if ($ObjStorage.count -le 4) {
                                    foreach ($STORAGEOBJ in ($ObjStorage | Sort-Object -Property Name)) {
                                        $OBJHASHTABLE = @{}
                                        $STORAGEOBJ.psobject.properties | ForEach-Object { $OBJHASHTABLE[$_.Name] = $_.Value }
                                        node $STORAGEOBJ -NodeScript {$_.Name} @{Label=$OBJHASHTABLE.Label}
                                    }
                                    edge -from ObjectStorageDummy -to $ObjStorage.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($ObjStorage| Sort-Object -Property Name) -size 4
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        SubGraph "ObjectStorage$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$REPOHASHTABLE.Label}
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
                            $Rank += 'ObjectStorage'
                            edge -from BackupRepository -to ObjectStorageDummy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        if ($ArchiveObjStorage) {
                            SubGraph ArchiveObjectStorage -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed'} {
                                node ArchiveObjectStorageDummy @{Label='Archive Object Repository'; fontsize=18; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                                if ($ArchiveObjStorage.count -le 4) {
                                    foreach ($STORAGEArchiveOBJ in ($ArchiveObjStorage | Sort-Object -Property Name)) {
                                        $ARCHOBJHASHTABLE = @{}
                                        $STORAGEArchiveOBJ.psobject.properties | ForEach-Object { $ARCHOBJHASHTABLE[$_.Name] = $_.Value }
                                        node $STORAGEArchiveOBJ -NodeScript {$_.Name} @{Label=$ARCHOBJHASHTABLE.Label}
                                    }
                                    edge -from ArchiveObjectStorageDummy -to $ArchiveObjStorage.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                }
                                else {
                                    $Group = Split-array -inArray ($ArchiveObjStorage| Sort-Object -Property Name) -size 4
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        SubGraph "ArchiveObjectStorage$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                                node $_.Name @{Label=$REPOHASHTABLE.Label}
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
                            $Rank += 'ArchiveObjectStorage'
                            edge -from BackupRepository -to ArchiveObjectStorageDummy @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}

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