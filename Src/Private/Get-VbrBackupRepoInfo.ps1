function Get-VbrBackupRepoInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication backup repository information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.9
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param (
    )

    process {
        Write-Verbose -Message "Collecting Backup Repository information from $($VBRServer.Name)."
        try {
            [Array]$BackupRepos = Get-VBRBackupRepository
            [Array]$ScaleOuts = Get-VBRBackupRepository -ScaleOut
            $ViBackupProxy = Get-VBRViProxy
            $HvBackupProxy = Get-VBRHvProxy

            if ($ScaleOuts) {
                $Extents = Get-VBRRepositoryExtent -Repository $ScaleOuts
                $BackupRepos += $Extents.Repository
            }
            $BackupRepoInfo = @()
            if ($BackupRepos) {
                foreach ($BackupRepo in $BackupRepos) {

                    $Role = Get-RoleType -String $BackupRepo.Type

                    $Rows = @{}

                    if ($Role -like '*Local' -or $Role -like '*Hardened') {
                        $Rows.add('Server', $BackupRepo.Host.Name.Split('.')[0])
                        $Rows.add('Path', $BackupRepo.FriendlyPath)
                        $Rows.add('Total-Space', "$(($BackupRepo).GetContainer().CachedTotalSpace.InGigabytes) GB")
                        $Rows.add('Used-Space', "$(($BackupRepo).GetContainer().CachedFreeSpace.InGigabytes) GB")
                    } elseif ($Role -like 'Dedup*') {
                        $Rows.add('DedupType', $BackupRepo.TypeDisplay)
                        $Rows.add('Total-Space', "$(($BackupRepo).GetContainer().CachedTotalSpace.InGigabytes) GB")
                        $Rows.add('Used-Space', "$(($BackupRepo).GetContainer().CachedFreeSpace.InGigabytes) GB")
                    } elseif ($Role -like '*Share') {
                        $Rows.add('Path', $BackupRepo.FriendlyPath)
                        $Rows.add('Total-Space', "$(($BackupRepo).GetContainer().CachedTotalSpace.InGigabytes) GB")
                        $Rows.add('Used-Space', "$(($BackupRepo).GetContainer().CachedFreeSpace.InGigabytes) GB")
                    } else {
                        $Rows.add('Server', 'Uknown')
                        $Rows.add('Path', 'Uknown')
                        $Rows.add('Total-Space', "0 GB")
                        $Rows.add('Used-Space', "0 GB")
                    }

                    if (($Role -ne 'Dedup Appliances') -and ($Role -ne 'SAN') -and ($Role -notlike '*Share') -and ($BackupRepo.Host.Name -in $ViBackupProxy.Host.Name -or $BackupRepo.Host.Name -in $HvBackupProxy.Host.Name)) {
                        $BackupType = 'Proxy'
                    } else { $BackupType = $BackupRepo.Type }

                    $Type = Get-IconType -String $BackupType

                    $TempBackupRepoInfo = [PSCustomObject]@{
                        Name = "$((Remove-SpecialChar -String $BackupRepo.Name -SpecialChars '\').toUpper()) "
                        Label = Get-DiaNodeIcon -Name "$((Remove-SpecialChar -String $BackupRepo.Name -SpecialChars '\').toUpper())" -IconType $Type -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                        Role = $Role
                        AditionalInfo = $Rows
                    }

                    $BackupRepoInfo += $TempBackupRepoInfo
                }
            }

            return $BackupRepoInfo
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}