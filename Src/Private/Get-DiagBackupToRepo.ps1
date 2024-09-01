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
            $DedupBackupRepo = Get-VbrBackupRepoInfo | Where-Object { $_.Role -like 'Dedup*' }
            $ObjStorage = Get-VbrBackupObjectRepoInfo
            $ArchiveObjStorage = Get-VbrBackupArchObjRepoInfo
            $NASBackupRepo = Get-VbrBackupRepoInfo | Where-Object { $_.Role -like '*Share' }

            if ($BackupServerInfo) {
                if ($BackupRepo) {
                    SubGraph MainSubGraph -Attributes @{Label = 'Backup Repositories'; fontsize = 22; penwidth = 1; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        if ($LocalBackupRepo) {
                            SubGraph LocalRepos -Attributes @{Label = 'Local Repositories'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                                Node LocalRepo @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($LocalBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Repository" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($LocalBackupRepo.AditionalInfo )); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }

                            }
                            Edge -From MainSubGraph:s -To LocalRepo @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        if ($NASBackupRepo) {
                            SubGraph NasRepos -Attributes @{Label = 'NAS Repositories'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                                Node NasRepo @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($NASBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_NAS" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($NASBackupRepo.AditionalInfo )); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                            }
                            Edge -From MainSubGraph:s -To NasRepo @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        if ($DedupBackupRepo) {
                            SubGraph RemoteRepos -Attributes @{Label = 'Deduplicating Storage Appliances'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                                Node RemoteRepo @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($DedupBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Deduplicating_Storage" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($DedupBackupRepo.AditionalInfo )); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }

                            }
                            Edge -From MainSubGraph:s -To RemoteRepo @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }

                        }
                        if ($ObjStorage) {
                            SubGraph ObjectStorages -Attributes @{Label = 'Object Repositories'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                                Node ObjectStorage @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($ObjStorage | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Cloud_Repository" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($ObjStorage.AditionalInfo )); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }

                            }
                            Edge -From MainSubGraph:s -To ObjectStorage @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        if ($ArchiveObjStorage) {
                            SubGraph ArchiveObjectStorages -Attributes @{Label = 'Archive Object Repositories'; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {

                                Node ArchiveObjectStorage @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($ArchiveObjStorage | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Cloud_Repository" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($ArchiveObjStorage.AditionalInfo )); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }

                            }
                            Edge -From MainSubGraph:s -To ArchiveObjectStorage @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }

                        }
                    }

                    Edge -From $BackupServerInfo.Name -To MainSubGraph @{minlen = 3 }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}