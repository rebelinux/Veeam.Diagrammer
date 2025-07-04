function Get-DiagBackupToRepo {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.30
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
            $CloudBackupRepo = Get-VbrBackupRepoInfo | Where-Object { $_.Role -like 'Cloud' }

            if ($BackupServerInfo) {
                if ($BackupRepo) {
                    $RepoSubgraphArray = @()

                    if ($LocalBackupRepo) {
                        if ($LocalBackupRepo.Name.Count -eq 1) {
                            $LocalBackupRepoColumnSize = 1
                        } elseif ($ColumnSize) {
                            $LocalBackupRepoColumnSize = $ColumnSize
                        } else {
                            $LocalBackupRepoColumnSize = $LocalBackupRepo.Name.Count
                        }
                        try {

                            $LocalBackupRepoArray = (Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($LocalBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Repository" -columnSize $LocalBackupRepoColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo ($LocalBackupRepo.AditionalInfo ) -fontSize 18)
                        } catch {
                            Write-Verbose "Error: Unable to create Local Backup Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {

                            $LocalBackupRepoSubgraph = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $LocalBackupRepoArray -Align 'Center' -IconDebug $IconDebug -Label 'Local Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $LocalBackupRepoColumnSize -fontSize 24)
                        } catch {
                            Write-Verbose "Error: Unable to create Local Backup Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($LocalBackupRepoSubgraph) {
                            $RepoSubgraphArray += $LocalBackupRepoSubgraph
                        }
                    }
                    if ($NASBackupRepo) {
                        if ($NASBackupRepo.Name.Count -eq 1) {
                            $NASBackupRepoColumnSize = 1
                        } elseif ($ColumnSize) {
                            $NASBackupRepoColumnSize = $ColumnSize
                        } else {
                            $NASBackupRepoColumnSize = $NASBackupRepo.Name.Count
                        }
                        try {

                            $NASBackupRepoArray = (Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($NASBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_NAS" -columnSize $NASBackupRepoColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo ($NASBackupRepo.AditionalInfo ) -fontSize 18)
                        } catch {
                            Write-Verbose "Error: Unable to create NAS Backup Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        try {
                            $NASBackupRepoSubgraph = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $NASBackupRepoArray -Align 'Center' -IconDebug $IconDebug -Label 'NAS Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $NASBackupRepoColumnSize -fontSize 24)
                        } catch {
                            Write-Verbose "Error: Unable to create NAS Backup Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($NASBackupRepoSubgraph) {
                            $RepoSubgraphArray += $NASBackupRepoSubgraph
                        }
                    }
                    if ($DedupBackupRepo) {
                        if ($DedupBackupRepo.Name.Count -eq 1) {
                            $DedupBackupRepoColumnSize = 1
                        } elseif ($ColumnSize) {
                            $DedupBackupRepoColumnSize = $ColumnSize
                        } else {
                            $DedupBackupRepoColumnSize = $DedupBackupRepo.Name.Count
                        }
                        try {

                            $DedupBackupRepoArray = (Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($DedupBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Deduplicating_Storage" -columnSize $DedupBackupRepoColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo ($DedupBackupRepo.AditionalInfo ) -fontSize 18)
                        } catch {
                            Write-Verbose "Error: Unable to create Dedup Backup Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        try {
                            $DedupBackupRepoSubgraph = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $DedupBackupRepoArray -Align 'Center' -IconDebug $IconDebug -Label 'Deduplicating Storage Appliances' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $DedupBackupRepoColumnSize -fontSize 24)
                        } catch {
                            Write-Verbose "Error: Unable to create Dedup Backup Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($DedupBackupRepoSubgraph) {
                            $RepoSubgraphArray += $DedupBackupRepoSubgraph
                        }
                    }
                    if ($ObjStorage) {
                        if ($DedupBackupRepo.Name.Count -eq 1) {
                            $ObjStorageColumnSize = 1
                        } elseif ($ColumnSize) {
                            $ObjStorageColumnSize = $ColumnSize
                        } else {
                            $ObjStorageColumnSize = $ObjStorage.Name.Count
                        }
                        try {
                            $ObjStorageArray = (Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($ObjStorage | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Cloud_Repository" -columnSize $ObjStorageColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo ($ObjStorage.AditionalInfo ) -fontSize 18)
                        } catch {
                            Write-Verbose "Error: Unable to create Object Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        try {
                            $ObjStorageSubgraph = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ObjStorageArray -Align 'Center' -IconDebug $IconDebug -Label 'Object Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $ObjStorageColumnSize -fontSize 24)
                        } catch {
                            Write-Verbose "Error: Unable to create Object Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($ObjStorageSubgraph) {
                            $RepoSubgraphArray += $ObjStorageSubgraph
                        }
                    }
                    if ($ArchiveObjStorage) {
                        if ($ArchiveObjStorage.Name.Count -eq 1) {
                            $ArchiveObjStorageColumnSize = 1
                        } elseif ($ColumnSize) {
                            $ArchiveObjStorageColumnSize = $ColumnSize
                        } else {
                            $ArchiveObjStorageColumnSize = $ArchiveObjStorage.Name.Count
                        }
                        try {
                            $ArchiveObjStorageArray = (Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($ArchiveObjStorage | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Cloud_Repository" -columnSize $ArchiveObjStorageColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo ($ArchiveObjStorage.AditionalInfo ) -fontSize 18)
                        } catch {
                            Write-Verbose "Error: Unable to create Archive Object Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {

                            $ArchiveObjStorageSubgraph = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ArchiveObjStorageArray -Align 'Center' -IconDebug $IconDebug -Label 'Archive Object Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $ArchiveObjStorageColumnSize -fontSize 24)
                        } catch {
                            Write-Verbose "Error: Unable to create Archive Object Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($ArchiveObjStorageSubgraph) {
                            $RepoSubgraphArray += $ArchiveObjStorageSubgraph
                        }
                    }

                    if ($CloudBackupRepo) {
                        if ($CloudBackupRepo.Name.Count -eq 1) {
                            $CloudBackupRepoColumnSize = 1
                        } elseif ($ColumnSize) {
                            $CloudBackupRepoColumnSize = $ColumnSize
                        } else {
                            $CloudBackupRepoColumnSize = $CloudBackupRepo.Name.Count
                        }
                        try {

                            $CloudBackupRepoArray = (Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($CloudBackupRepo | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Cloud_Repository" -columnSize $CloudBackupRepoColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo ($CloudBackupRepo.AditionalInfo ) -fontSize 18)
                        } catch {
                            Write-Verbose "Error: Unable to create Cloud Backup Repositories table Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }
                        try {

                            $CloudBackupRepoSubgraph = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CloudBackupRepoArray -Align 'Center' -IconDebug $IconDebug -Label 'Cloud Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $CloudBackupRepoColumnSize -fontSize 24)
                        } catch {
                            Write-Verbose "Error: Unable to create Cloud Backup Repositories Subgraph. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($CloudBackupRepoSubgraph) {
                            $RepoSubgraphArray += $CloudBackupRepoSubgraph
                        }
                    }

                    if ($RepoSubgraphArray) {
                        if ($SOBRArray.Count -eq 1) {
                            $RepoSubgraphArrayColumnSize = 1
                        } elseif ($ColumnSize) {
                            $RepoSubgraphArrayColumnSize = $ColumnSize
                        } else {
                            $RepoSubgraphArrayColumnSize = $RepoSubgraphArray.Count
                        }
                        Node -Name MainSubGraph -Attributes @{Label = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $RepoSubgraphArray -Align 'Center' -IconDebug $IconDebug -Label 'Backup Repositories' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $RepoSubgraphArrayColumnSize -fontSize 26); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                    }

                    Edge -From BackupServers -To MainSubGraph @{minlen = 3 }
                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}