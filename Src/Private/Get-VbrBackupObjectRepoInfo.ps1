function Get-VbrBackupObjectRepoInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication object storage repository information.
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
        Write-Verbose -Message "Collecting Object Storage Repository information from $($VBRServer.Name)."
        try {
            $ObjStorages = Get-VBRObjectStorageRepository
            $ObjStorageInfo = @()
            if ($ObjStorages) {
                foreach ($ObjStorage in $ObjStorages) {

                    if ($ObjStorage.AmazonS3Folder) {
                        $Folder = $ObjStorage.AmazonS3Folder
                    } elseif ($ObjStorage.AzureBlobFolder) {
                        $Folder = $ObjStorage.AzureBlobFolder
                    } else { $Folder = 'Unknown' }

                    $Rows = @{
                        Type = $ObjStorage.Type
                        Folder = $Folder
                        Gateway = & {
                            if (-Not $ObjStorage.UseGatewayServer) {
                                Switch ($ObjStorage.ConnectionType) {
                                    'Gateway' {
                                        switch ($ObjStorage.GatewayServer.count) {
                                            0 { "Disable" }
                                            1 { $ObjStorage.GatewayServer.Name.Split('.')[0] }
                                            Default { 'Automatic' }
                                        }
                                    }
                                    'Direct' { 'Direct' }
                                    default { 'Unknown' }
                                }
                            } else {
                                switch ($ObjStorage.GatewayServer.count) {
                                    0 { "Disable" }
                                    1 { $ObjStorage.GatewayServer.Name.Split('.')[0] }
                                    Default { 'Automatic' }
                                }
                            }
                        }
                    }

                    $TempObjStorageInfo = [PSCustomObject]@{
                        Name = "$($ObjStorage.Name) "
                        Label = Get-NodeIcon -Name $($ObjStorage.Name) -IconType "VBR_Cloud_Repository" -Align "Center" -Rows $Rows
                    }
                    $ObjStorageInfo += $TempObjStorageInfo
                }
            }

            return $ObjStorageInfo
        } catch {
            $_
        }
    }
    end {}
}