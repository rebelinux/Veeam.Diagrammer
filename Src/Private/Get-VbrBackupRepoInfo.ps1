function Get-VbrBackupRepoInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication backup repository information.
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

    Param (
    )

    process {
        Write-Verbose -Message "Collecting Backup Repository information from $($VBRServer.Name)."
        try {
            [Array]$BackupRepos = Get-VBRBackupRepository
            [Array]$ScaleOuts = Get-VBRBackupRepository -ScaleOut
            if ($ScaleOuts) {
                $Extents = Get-VBRRepositoryExtent -Repository $ScaleOuts
                $BackupRepos += $Extents.Repository
            }
            $BackupRepoInfo = @()
            if ($BackupRepos) {
                foreach ($BackupRepo in $BackupRepos) {

                    $Role = Switch ($BackupRepo.Type) {
                        'LinuxLocal' {'Linux Local'}
                        'WinLocal' {'Windows Local'}
                        'DDBoost' {'Dedup Appliances'}
                        'HPStoreOnceIntegration' {'Dedup Appliances'}
                        'Cloud' {'Cloud'}
                        default {'Backup Repository'}
                    }
                    $Rows = @{
                        Role = $Role
                    }

                    if ($Role -like '*Local') {
                        $Rows.add('Path', $BackupRepo.FriendlyPath)
                        $Rows.add('Total Space', "$(($BackupRepo).GetContainer().CachedTotalSpace.InGigabytes) GB")
                        $Rows.add('Used Space', "$(($BackupRepo).GetContainer().CachedFreeSpace.InGigabytes) GB")
                    } elseif ($Role -like 'Dedup*') {
                        $Rows.add('Type', $BackupRepo.Type)
                    }

                    $Name = Remove-SpecialChars -String $BackupRepo.Name -SpecialChars '\'

                    $Type = Switch ($BackupRepo.Type) {
                        'LinuxLocal' {'VBR_Linux_Repository'}
                        'Cloud' {'VBR_Cloud_Repository'}
                        default {'VBR_Repository'}
                    }

                    $TempBackupRepoInfo = [PSCustomObject]@{
                        Name = "$((Remove-SpecialChars -String $BackupRepo.Name -SpecialChars '\').toUpper()) "
                        Label = Get-NodeIcon -Name "$((Remove-SpecialChars -String $BackupRepo.Name -SpecialChars '\').toUpper())" -Type $Type -Align "Center" -Rows $Rows
                        Role = $Role
                    }

                    $BackupRepoInfo += $TempBackupRepoInfo
                }
            }

            return $BackupRepoInfo
        }
        catch {
            $_
        }
    }
    end {}
}