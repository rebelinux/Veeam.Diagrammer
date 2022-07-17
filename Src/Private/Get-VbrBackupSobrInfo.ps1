function Get-VbrBackupSobrInfo {
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
    [OutputType([System.Object[]])]

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
                        'Placement Policy' = $Sobr.PolicyType
                        'Encryption Enabled' = ConvertTo-TextYN $Sobr.EncryptionEnabled
                    }

                    if ($Sobr.EncryptionEnabled) {
                        $SobrRows.add('Encryption Key', $Sobr.EncryptionKey.Description)
                    }

                    if ($Sobr.CapacityExtent.Repository.AmazonS3Folder) {
                        $Folder = $Sobr.CapacityExtent.Repository.AmazonS3Folder
                    }
                    elseif ($Sobr.CapacityExtent.Repository.AzureBlobFolder) {
                        $Folder = $Sobr.CapacityExtent.Repository.AzureBlobFolder
                    }
                    elseif ($Sobr.ArchiveExtent.Repository.AzureBlobFolder) {
                        $Folder = $Sobr.ArchiveExtent.Repository.AzureBlobFolder
                    } else {$Folder = 'Unknown'}


                    foreach ($Extent in $Sobr.Extent) {

                        $PerformanceRows = [pscustomobject]@{
                            'Path' = $Extent.Repository.FriendlyPath
                            'Total Space' = "$((($Extent).Repository).GetContainer().CachedTotalSpace.InGigabytes) GB"
                            'Used Space' = "$((($Extent).Repository).GetContainer().CachedFreeSpace.InGigabytes) GB"
                        }
                    }

                    $SOBRPERFHASHTABLE = @{}
                    $PerformanceRows.psobject.properties | ForEach-Object { $SOBRPERFHASHTABLE[$_.Name] = $_.Value }

                    $CapacityRows = @{
                        Type = $Sobr.CapacityExtent.Repository.Type
                        Folder = "/$($Folder)"
                        Gateway = Switch ($Sobr.CapacityExtent.Repository.UseGatewayServer) {
                            $true {$Sobr.CapacityExtent.Repository.GatewayServer.Name.Split('.')[0]}
                            $false {'Disabled'}
                            default {'Unknown'}
                        }
                    }

                    $ArchiveRows = [ordered]@{
                        Type = $Sobr.ArchiveExtent.Repository.ArchiveType
                        Gateway = Switch ($Sobr.ArchiveExtent.Repository.UseGatewayServer) {
                            $true {$Sobr.ArchiveExtent.Repository.GatewayServer.Name.Split('.')[0].toUpper()}
                            $false {'Disabled'}
                            default {'Unknown'}
                        }
                    }

                    if ($Sobr.ArchiveExtent.Repository.AzureBlobFolder) {
                        $ArchiveRows.add('Folder', "/$($Folder.Name)")
                        $ArchiveRows.add('Container', $($Folder.Container))
                    }

                    $TempSobrInfo = [PSCustomObject]@{
                        Name = "$($Sobr.Name.toUpper())"
                        Label = Get-NodeIcon -Name "$($Sobr.Name)" -Type "VBR_SOBR" -Align "Center" -Rows $SobrRows

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