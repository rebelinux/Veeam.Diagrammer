function Get-VbrBackupObjectRepoInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication object storage repository information.
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
        Write-Verbose -Message "Collecting Object Storage Repository information from $($VBRServer.Name)."
        try {
            $ObjStorages = Get-VBRObjectStorageRepository
            $ObjStorageInfo = @()
            if ($ObjStorages) {
                foreach ($ObjStorage in $ObjStorages) {

                    if ($ObjStorage.AmazonS3Folder) {
                        $Folder = $ObjStorage.AmazonS3Folder
                    }
                    elseif ($ObjStorage.AzureBlobFolder) {
                        $Folder = $ObjStorage.AzureBlobFolder
                    } else {$Folder = 'Unknown'}

                    $Rows = @{
                        Type = $ObjStorage.Type
                        Folder = $Folder
                        Gateway = Switch ($ObjStorage.UseGatewayServer) {
                            $true {$ObjStorage.GatewayServer.Name.Split('.')[0]}
                            $false {'Disabled'}
                            default {'Unknown'}
                        }
                    }

                    $TempObjStorageInfo = [PSCustomObject]@{
                        Name = "$($ObjStorage.Name) "
                        Label = Get-NodeIcon -Name $($ObjStorage.Name) -Type "VBR_Cloud_Repository" -Align "Center" -Rows $Rows
                    }
                    $ObjStorageInfo += $TempObjStorageInfo
                }
            }

            return $ObjStorageInfo
        }
        catch {
            $_
        }
    }
    end {}
}