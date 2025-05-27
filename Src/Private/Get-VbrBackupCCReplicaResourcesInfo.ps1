function Get-VbrBackupCCReplicaResourcesInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication cloud connect replica resources information.
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
    [OutputType([System.Object[]])]

    Param (
    )

    process {
        Write-Verbose -Message "Collecting Cloud Connect Replica Resources information from $($VBRServer.Name)."
        try {

            $BackupCCReplicaResourcesInfo = @()

            if ($CloudObjects = Get-VBRCloudHardwarePlan | Sort-Object -Property Name) {
                foreach ($CloudObject in $CloudObjects) {

                    $AditionalInfo = [PSCustomObject] [ordered] @{
                        CPU = Switch ([string]::IsNullOrEmpty($CloudObject.CPU)) {
                            $true { 'Unlimited' }
                            $false { "$([math]::Round($CloudObject.CPU / 1000, 1)) Ghz" }
                            default { '--' }
                        }
                        Memory = Switch ([string]::IsNullOrEmpty($CloudObject.Memory)) {
                            $true { 'Unlimited' }
                            $false { ConvertTo-FileSizeString -Size (Convert-Size -From MB -To Bytes -Value $CloudObject.Memory) -RoundUnits $Options.RoundUnits }
                            default { '--' }
                        }
                        Storage = ConvertTo-FileSizeString -Size (Convert-Size -From GB -To Bytes -Value ($CloudObject.Datastore.Quota | Measure-Object -Sum).Sum) -RoundUnits 2
                        Network = $CloudObject.NumberOfNetWithInternet + $CloudObject.NumberOfNetWithoutInternet
                        # Subscribers = ($CloudObject.SubscribedTenantId).count
                        # Host = $CloudObject.Host.Name.split(".")[0]
                        Platform = $CloudObject.Platform
                    }

                    $TempBackupCCReplicaResourcesInfo = [PSCustomObject]@{
                        Name = $CloudObject.Name
                        Label = Add-DiaNodeIcon -Name "$((Remove-SpecialChar -String $CloudObject.Name.split(".")[0] -SpecialChars '\').toUpper())" -IconType "VBR_Hardware_Resources" -Align "Center" -Rows $AditionalInfo -ImagesObj $Images -IconDebug $IconDebug -FontSize 18
                        Id = $CloudObject.Id
                        AditionalInfo = $AditionalInfo
                    }

                    $BackupCCReplicaResourcesInfo += $TempBackupCCReplicaResourcesInfo
                }
            }

            return $BackupCCReplicaResourcesInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}