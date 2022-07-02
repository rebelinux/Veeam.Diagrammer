function Get-VbrSobrInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication scale-out backup repository information.
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
        Write-Verbose -Message "Collecting Scale-Out Backup Repository information from $($VBRServer.Name)."
        try {
            $Sobrs = Get-VBRBackupRepository -ScaleOut
            $SobrInfo = @()
            if ($Sobrs) {
                foreach ($Sobr in $Sobrs) {
                    $SobrRows = @{
                        Performance = Remove-SpecialChars -String $Sobr.Extent.Name -SpecialChars '\'
                        Capacity = Remove-SpecialChars -String $Sobr.CapacityExtent.Repository.Name -SpecialChars '\'
                    }

                    if ($Sobr.CapacityExtent.Repository.AmazonS3Folder) {
                        $Folder = $Sobr.CapacityExtent.Repository.AmazonS3Folder
                    }
                    elseif ($Sobr.CapacityExtent.Repository.AzureBlobFolder) {
                        $Folder = $Sobr.CapacityExtent.Repository.AzureBlobFolder
                    } else {$Folder = 'Unknown'}


                    foreach ($Extent in $Sobr.Extent) {

                        $PerformanceRows = [pscustomobject]@{
                            'Path' = $Extent.Repository.FriendlyPath
                            # 'IP' = Get-NodeIP -HostName $Extent.Repository.Host.Name
                            'Total Space' = "$((($Extent).Repository).GetContainer().CachedTotalSpace.InGigabytes) GB"
                            'Used Space' = "$((($Extent).Repository).GetContainer().CachedFreeSpace.InGigabytes) GB"
                            # 'Role' = (Get-RoleType -String $Extent.Repository.Type)
                        }
                    }

                    $SOBRPERFHASHTABLE = @{}
                    $PerformanceRows.psobject.properties | Foreach { $SOBRPERFHASHTABLE[$_.Name] = $_.Value }

                    $CapacityRows = @{
                        Type = $Sobr.CapacityExtent.Repository.Type
                        Folder = "/$($Folder)"
                        Gateway = Switch ($Sobr.CapacityExtent.Repository.UseGatewayServer) {
                            $true {$Sobr.CapacityExtent.Repository.GatewayServer.Name.Split('.')[0]}
                            $false {'Disabled'}
                            default {'Unknown'}
                        }
                    }

                    $ArchiveRows = @{
                        Type = $Sobr.ArchiveExtent.Repository.ArchiveType
                        Gateway = Switch ($Sobr.ArchiveExtent.Repository.UseGatewayServer) {
                            $true {$Sobr.ArchiveExtent.Repository.GatewayServer.Name.Split('.')[0].toUpper()}
                            $false {'Disabled'}
                            default {'Unknown'}
                        }
                    }

                    $TempSobrInfo = [PSCustomObject]@{
                        Name = "$($Sobr.Name.toUpper())"
                        Label = Get-ImageNode -Name "$($Sobr.Name)" -Type "VBR_SOBR" -Align "Center" -Rows $SobrRows

                        Capacity = $Sobr.CapacityExtent.Repository | Select-Object -Property @{Name= 'Name'; Expression={Remove-SpecialChars -String $_.Name -SpecialChars '\'}},@{Name = 'Rows'; Expression={$CapacityRows}}, @{Name = 'Icon'; Expression={Get-IconType -String $_.Type}}

                        Archive = $Sobr.ArchiveExtent.Repository | Select-Object -Property @{Name= 'Name'; Expression={Remove-SpecialChars -String $_.Name -SpecialChars '\'}},@{Name = 'Rows'; Expression={$ArchiveRows}}, @{Name = 'Icon'; Expression={Get-IconType -String $_.ArchiveType}}

                        Performance = $Sobr.Extent | Select-Object -Property @{Name= 'Name'; Expression={Remove-SpecialChars -String $_.Name -SpecialChars '\'}},@{Name = 'Rows'; Expression={$SOBRPERFHASHTABLE}}, @{Name = 'Icon'; Expression={Get-IconType -String $_.Repository.Type}}
                    }
                    $SobrInfo += $TempSobrInfo
                }
            }

            return $SobrInfo
        }
        catch {
            $_
        }
    }
    end {}
}