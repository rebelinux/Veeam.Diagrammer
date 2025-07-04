function Get-VbrBackupvSphereInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication vsphere hypervisor information.
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

    Param
    (

    )
    process {
        Write-Verbose -Message "Collecting vSphere HyperVisor information from $($VBRServer.Name)."
        try {
            $HyObjs = Get-VBRServer | Where-Object { $_.Type -eq 'VC' }
            $HyObjsInfo = @()
            if ($HyObjs) {
                foreach ($HyObj in $HyObjs) {
                    try {
                        $ESXis = try { Find-VBRViEntity -Server $HyObj | Where-Object { ($_.type -eq "esx") } } catch {
                            Write-Verbose -Message $_.Exception.Message
                        }
                        $Rows = @{
                            IP = Get-NodeIP -Hostname $HyObj.Info.DnsName
                            Version = $HyObj.Info.ViVersion
                        }

                        $TempHyObjsInfo = [PSCustomObject]@{
                            Name = $HyObj.Name
                            Label = Add-DiaNodeIcon -Name $HyObj.Name -IconType "VBR_vCenter_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug -fontSize 18
                            AditionalInfo = $Rows
                            Childs = & {
                                $VIClusters = try {
                                (Find-VBRViEntity -Server $HyObj | Where-Object { ($_.type -eq "cluster") })
                                } catch {
                                    Write-Verbose -Message $_.Exception.Message
                                }
                                foreach ($Cluster in $VIClusters) {
                                    [PSCustomObject]@{
                                        Name = $Cluster.Name
                                        Label = Add-DiaNodeIcon -Name $Cluster.Name -IconType "VBR_vSphere_Cluster" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug -fontSize 18
                                        EsxiHost = foreach ($Esxi in $ESXis | Where-Object { $_.path -match $Cluster.Name }) {
                                            $Rows = @{
                                                IP = Get-NodeIP -Hostname $Esxi.Info.DnsName
                                                Version = $Esxi.Info.ViVersion
                                            }
                                            [PSCustomObject]@{
                                                Name = $Esxi.Name
                                                Label = Add-DiaNodeIcon -Name $Esxi.Name -IconType "VBR_ESXi_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug -fontSize 18
                                                AditionalInfo = $Rows
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        $HyObjsInfo += $TempHyObjsInfo
                    } catch {
                        Write-Verbose -Message $_.Exception.Message
                    }
                }
            }

            return $HyObjsInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}