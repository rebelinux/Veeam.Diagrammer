function Get-VbrBackupArchObjRepoInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication archive object storage repository information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.9
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

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
                    } elseif ($ArchObjStorage.AzureBlobFolder) {
                        $Folder = $ArchObjStorage.AzureBlobFolder.Name
                        $Container = $ArchObjStorage.AzureBlobFolder.Container
                    } else { $Folder = 'Unknown' }

                    $Rows = @{
                        Type = $ArchObjStorage.ArchiveType
                        Folder = $Folder
                        Gateway = & {
                            if (-Not $ArchObjStorage.UseGatewayServer) {
                                Switch ($ArchObjStorage.GatewayMode) {
                                    'Gateway' {
                                        switch (($ArchObjStorage.GatewayServer | Measure-Object).count) {
                                            0 { "Disable" }
                                            1 { $ArchObjStorage.GatewayServer.Name.Split('.')[0] }
                                            Default { 'Automatic' }
                                        }
                                    }
                                    'Direct' { 'Direct' }
                                    default { 'Unknown' }
                                }
                            } else {
                                switch (($ArchObjStorage.GatewayServer | Measure-Object).count) {
                                    0 { "Disable" }
                                    1 { $ArchObjStorage.GatewayServer.Name.Split('.')[0] }
                                    Default { 'Automatic' }
                                }
                            }
                        }
                    }

                    if ($ArchObjStorage.ArchiveType -eq 'AzureArchive') {
                        $Rows.add('Container', $Container)
                    }

                    $TempObjStorageInfo = [PSCustomObject]@{
                        Name = "$($ArchObjStorage.Name) "
                        Label = Get-DiaNodeIcon -Name $($ArchObjStorage.Name) -IconType "VBR_Cloud_Repository" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                    }
                    $ArchObjStorageInfo += $TempObjStorageInfo
                }
            }

            return $ArchObjStorageInfo
        } catch {
            $_
        }
    }
    end {}
}