function Get-DiagBackupToRepo {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.1
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
            $BackupRepo = Get-VbrBackupRepoInfo
            $LocalBackupRepo = Get-VbrBackupRepoInfo | Where-Object { $_.Role -like '*Local' }
            $RemoteBackupRepo = Get-VbrBackupRepoInfo | Where-Object { $_.Role -like 'Dedup*' }
            $ObjStorage = Get-VbrBackupObjectRepoInfo
            $ArchiveObjStorage = Get-VbrBackupArchObjRepoInfo

            if ($BackupServerInfo) {
                if ($BackupRepo) {
                    SubGraph MainSubGraph -Attributes @{Label = 'Backup Repository'; fontsize = 22; penwidth = 1; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        if ($LocalBackupRepo) {
                            SubGraph LocalRepos -Attributes @{Label = 'Local Repository'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                # Node used for subgraph centering
                                Node LocalReposDummy @{Label = 'LocalReposDummy'; style = $SubGraphDebug.style; color = $SubGraphDebug.color; shape = 'plain' }
                                if (($LocalBackupRepo | Measure-Object).count -le 3) {
                                    foreach ($REPOOBJ in ($LocalBackupRepo | Sort-Object -Property Name)) {
                                        $REPOHASHTABLE = @{}
                                        $REPOOBJ.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                        Node $REPOOBJ -NodeScript { $_.Name } @{Label = $REPOHASHTABLE.Label; fontname = "Segoe Ui" }
                                    }

                                    Edge -From LocalReposDummy -To $LocalBackupRepo.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                } else {
                                    $Group = Split-array -inArray ($LocalBackupRepo | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "LocalBackupGroup$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                                Node $_.Name @{Label = $REPOHASHTABLE.Label; fontname = "Segoe Ui" }
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From LocalReposDummy -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $LocalRepoNum = 1
                                    while ($LocalRepoNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$LocalRepoNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $LocalRepoNum++
                                    }
                                }
                            }
                            Edge -From MainSubGraph:s -To LocalReposDummy @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        if ($RemoteBackupRepo) {
                            SubGraph RemoteRepos -Attributes @{Label = 'Deduplicating Storage Appliances'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                Node RemoteReposDummy @{Label = 'RemoteReposDummy'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain' }
                                if (($RemoteBackupRepo | Measure-Object).count -le 3) {
                                    foreach ($REPOOBJ in ($RemoteBackupRepo | Sort-Object -Property Name)) {
                                        $REPOHASHTABLE = @{}
                                        $REPOOBJ.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                        Node $REPOOBJ -NodeScript { $_.Name } @{Label = $REPOHASHTABLE.Label; fontname = "Segoe Ui" }
                                    }

                                    Edge -From RemoteReposDummy -To $RemoteBackupRepo.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                } else {
                                    $Group = Split-array -inArray ($RemoteBackupRepo | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "RemoteBackupRepo$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                                Node $_.Name @{Label = $REPOHASHTABLE.Label; fontname = "Segoe Ui" }
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From RemoteReposDummy -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $RemoteRepoNum = 1
                                    while ($RemoteRepoNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$RemoteRepoNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $RemoteRepoNum++
                                    }
                                }
                            }
                            Edge -From MainSubGraph:s -To RemoteReposDummy @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }

                        }
                        if ($ObjStorage) {
                            SubGraph ObjectStorage -Attributes @{Label = 'Object Repository'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                Node ObjectStorageDummy @{Label = 'ObjectStorageDummy'; style = $SubGraphDebug.style; color = $SubGraphDebug.color; shape = 'plain' }
                                if (($ObjStorage | Measure-Object).count -le 3) {
                                    foreach ($STORAGEOBJ in ($ObjStorage | Sort-Object -Property Name)) {
                                        $OBJHASHTABLE = @{}
                                        $STORAGEOBJ.psobject.properties | ForEach-Object { $OBJHASHTABLE[$_.Name] = $_.Value }
                                        Node $STORAGEOBJ -NodeScript { $_.Name } @{Label = $OBJHASHTABLE.Label; fontname = "Segoe Ui" }
                                    }

                                    Edge -From ObjectStorageDummy -To $ObjStorage.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                } else {
                                    $Group = Split-array -inArray ($ObjStorage | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ObjectStorage$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                                Node $_.Name @{Label = $REPOHASHTABLE.Label; fontname = "Segoe Ui" }
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From ObjectStorageDummy -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $ObjectStorageNum = 1
                                    while ($ObjectStorageNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$ObjectStorageNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $ObjectStorageNum++
                                    }
                                }
                            }
                            Edge -From MainSubGraph:s -To ObjectStorageDummy @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        if ($ArchiveObjStorage) {
                            SubGraph ArchiveObjectStorage -Attributes @{Label = 'Archive Object Repository'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                Node ArchiveObjectStorageDummy @{Label = 'ArchiveObjectStorageDummy'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain' }
                                if (($ArchiveObjStorage | Measure-Object).count -le 3) {
                                    foreach ($STORAGEArchiveOBJ in ($ArchiveObjStorage | Sort-Object -Property Name)) {
                                        $ARCHOBJHASHTABLE = @{}
                                        $STORAGEArchiveOBJ.psobject.properties | ForEach-Object { $ARCHOBJHASHTABLE[$_.Name] = $_.Value }
                                        Node $STORAGEArchiveOBJ -NodeScript { $_.Name } @{Label = $ARCHOBJHASHTABLE.Label; fontname = "Segoe Ui" }
                                    }

                                    Edge -From ArchiveObjectStorageDummy -To $ArchiveObjStorage.Name @{constraint = "true"; minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                } else {
                                    $Group = Split-array -inArray ($ArchiveObjStorage | Sort-Object -Property Name) -size 3
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ArchiveObjectStorage$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $REPOHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                                Node $_.Name @{Label = $REPOHASHTABLE.Label; fontname = "Segoe Ui" }
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From ArchiveObjectStorageDummy -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $ArchiveObjectStorageNum = 1
                                    while ($ArchiveObjectStorageNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$ArchiveObjectStorageNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $ArchiveObjectStorageNum++
                                    }
                                }
                            }
                            Edge -From MainSubGraph:s -To ArchiveObjectStorageDummy @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }

                        }
                    }

                    Edge -From $BackupServerInfo.Name -To MainSubGraph @{lhead='clusterMainSubGraph';minlen = 3 }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}