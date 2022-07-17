function Get-VbrBackupArchObjRepoInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication archive object storage repository information.
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
        Write-Verbose -Message "Collecting Archive Object Storage Repository information from $($VBRServer.Name)."
        try {
            $ArchObjStorages = Get-VBRArchiveObjectStorageRepository
            $ArchObjStorageInfo = @()
            if ($ArchObjStorages) {
                foreach ($ArchObjStorage in $ArchObjStorages) {

                    if ($ArchObjStorage.AmazonS3Folder) {
                        $Folder = $ArchObjStorage.AmazonS3Folder
                    }
                    elseif ($ArchObjStorage.AzureBlobFolder) {
                        $Folder = $ArchObjStorage.AzureBlobFolder.Name
                        $Container = $ArchObjStorage.AzureBlobFolder.Container
                    } else {$Folder = 'Unknown'}

                    $Rows = @{
                        Type = $ArchObjStorage.ArchiveType
                        Folder = $Folder
                        Gateway = Switch ($ArchObjStorage.UseGatewayServer) {
                            $true {$ArchObjStorage.GatewayServer.Name.Split('.')[0]}
                            $false {'Disabled'}
                            default {'Unknown'}
                        }
                    }

                    if ($ArchObjStorage.ArchiveType -eq 'AzureArchive') {
                        $Rows.add('Container', $Container)
                    }

                    $TempObjStorageInfo = [PSCustomObject]@{
                        Name = "$($ArchObjStorage.Name) "
                        Label = Get-NodeIcon -Name $($ArchObjStorage.Name) -Type "VBR_Cloud_Repository" -Align "Center" -Rows $Rows
                    }
                    $ArchObjStorageInfo += $TempObjStorageInfo
                }
            }

            return $ArchObjStorageInfo
        }
        catch {
            $_
        }
    }
    end {}
}