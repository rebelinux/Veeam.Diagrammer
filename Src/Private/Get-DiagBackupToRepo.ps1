function Get-DiagBackupToRepo {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.19
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
    }

    process {
        try {
            $BackupRepo = Get-VbrBackupRepoInfo
            $LocalBackupRepo = Get-VbrBackupRepoInfo | Where-Object { $_.Role -like '*Local' -or $_.Role -like '*Hardened' }
            $DedupBackupRepo = Get-VbrBackupRepoInfo | Where-Object { $_.Role -like 'Dedup*' }
            $ObjStorage = Get-VbrBackupObjectRepoInfo
            $ArchiveObjStorage = Get-VbrBackupArchObjRepoInfo
            $NASBackupRepo = Get-VbrBackupRepoInfo | Where-Object { $_.Role -like '*Share' }

            if ($BackupServerInfo) {
                if ($BackupRepo) {
                    $RepoSubgraphArray = @()

                    if ($LocalBackupRepo) {
                        try {

                            $LocalBackupRepoArray = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($LocalBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Repository" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($LocalBackupRepo.AditionalInfo ))
                        } catch {
                            Write-Verbose "Error: Unable to create Local Backup Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {

                            $LocalBackupRepoSubgraph = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $LocalBackupRepoArray -Align 'Center' -IconDebug $IconDebug -Label 'Local Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4)
                        } catch {
                            Write-Verbose "Error: Unable to create Local Backup Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($LocalBackupRepoSubgraph) {
                            $RepoSubgraphArray += $LocalBackupRepoSubgraph
                        }
                    }
                    if ($NASBackupRepo) {
                        try {

                            $NASBackupRepoArray = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($NASBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_NAS" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($NASBackupRepo.AditionalInfo ))
                        } catch {
                            Write-Verbose "Error: Unable to create NAS Backup Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        try {
                            $NASBackupRepoSubgraph = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $NASBackupRepoArray -Align 'Center' -IconDebug $IconDebug -Label 'NAS Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4)
                        } catch {
                            Write-Verbose "Error: Unable to create NAS Backup Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($NASBackupRepoSubgraph) {
                            $RepoSubgraphArray += $NASBackupRepoSubgraph
                        }
                    }
                    if ($DedupBackupRepo) {
                        try {

                            $DedupBackupRepoArray = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($DedupBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Deduplicating_Storage" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($DedupBackupRepo.AditionalInfo ))
                        } catch {
                            Write-Verbose "Error: Unable to create Dedup Backup Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        try {
                            $DedupBackupRepoSubgraph = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $DedupBackupRepoArray -Align 'Center' -IconDebug $IconDebug -Label 'Deduplicating Storage Appliances' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4)
                        } catch {
                            Write-Verbose "Error: Unable to create Dedup Backup Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($DedupBackupRepoSubgraph) {
                            $RepoSubgraphArray += $DedupBackupRepoSubgraph
                        }
                    }
                    if ($ObjStorage) {
                        try {
                            $ObjStorageArray = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($ObjStorage | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Cloud_Repository" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($ObjStorage.AditionalInfo ))
                        } catch {
                            Write-Verbose "Error: Unable to create Object Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        try {
                            $ObjStorageSubgraph = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ObjStorageArray -Align 'Center' -IconDebug $IconDebug -Label 'Object Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4)
                        } catch {
                            Write-Verbose "Error: Unable to create Object Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($ObjStorageSubgraph) {
                            $RepoSubgraphArray += $ObjStorageSubgraph
                        }
                    }
                    if ($ArchiveObjStorage) {
                        try {
                            $ArchiveObjStorageArray = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($ArchiveObjStorage | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Cloud_Repository" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($ArchiveObjStorage.AditionalInfo ))
                        } catch {
                            Write-Verbose "Error: Unable to create Archive Object Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {

                            $ArchiveObjStorageSubgraph = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ArchiveObjStorageArray -Align 'Center' -IconDebug $IconDebug -Label 'Archive Object Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4)
                        } catch {
                            Write-Verbose "Error: Unable to create Archive Object Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($ArchiveObjStorageSubgraph) {
                            $RepoSubgraphArray += $ArchiveObjStorageSubgraph
                        }
                    }

                    if ($RepoSubgraphArray) {
                        Node -Name MainSubGraph -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $RepoSubgraphArray -Align 'Center' -IconDebug $IconDebug -Label 'Backup Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 3); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                    }

                    Edge -From $BackupServerInfo.Name -To MainSubGraph @{minlen = 3 }
                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}