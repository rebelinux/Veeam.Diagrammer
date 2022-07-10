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
            $ObjStorage = Get-VbrBackupObjectRepoInfo

            if ($BackupServerInfo) {

                if ($BackupRepo) {
                    $Rank = @()
                    if ($RemoteBackupRepo) {
                        SubGraph RemoteRepos -Attributes @{Label='Deduplicating Storage Appliances'; fontsize=18; penwidth=1.5; labelloc='b';nojustify=$true} {
                            foreach ($REPOOBJ in $RemoteBackupRepo) {
                                $REPOHASHTABLE = @{}
                                $REPOOBJ.psobject.properties | ForEach-Object { $REPOHASHTABLE[$_.Name] = $_.Value }
                                node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label;}
                            }
                            edge -from $RemoteBackupRepo.Name -to $BackupServerInfo.Name
                        }
                        $Rank += 'RemoteRepos'
                    }
                    if ($ObjStorage) {
                        SubGraph ObjectStorage -Attributes @{Label='Object Repository'; fontsize=18; penwidth=1.5; labelloc='b'} {
                            foreach ($STORAGEOBJ in $ObjStorage) {
                                $OBJHASHTABLE = @{}
                                $STORAGEOBJ.psobject.properties | ForEach-Object { $OBJHASHTABLE[$_.Name] = $_.Value }
                                node $STORAGEOBJ -NodeScript {$_.Name} @{Label=$OBJHASHTABLE.Label}
                                edge -from $BackupServerInfo.Name -to $STORAGEOBJ.Name
                            }
                        }
                        $Rank += 'ObjectStorage'
                    }
                    if ($LocalBackupRepo) {
                        SubGraph LocalRepos -Attributes @{Label='Local Repository'; fontsize=18; penwidth=1.5; labelloc='b'} {
                            foreach ($REPOOBJ in $LocalBackupRepo) {
                                $REPOHASHTABLE = @{}
                                $REPOOBJ.psobject.properties | ForEach-Object {$REPOHASHTABLE[$_.Name] = $_.Value }
                                node $REPOOBJ -NodeScript {$_.Name} @{Label=$REPOHASHTABLE.Label}
                                edge -from $BackupServerInfo.Name -to $REPOOBJ.Name
                            }
                        }
                        $Rank += 'LocalRepos'
                    }
                    rank $Rank
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}