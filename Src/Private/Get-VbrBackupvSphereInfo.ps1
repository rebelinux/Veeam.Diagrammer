function Get-VbrBackupvSphereInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication vsphere hypervisor information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.12
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
                    $ESXis = Find-VBRViEntity -Server $HyObj | Where-Object { ($_.type -eq "esx") }
                    $Rows = @{
                        IP = Get-NodeIP -Hostname $HyObj.Info.DnsName
                        Version = $HyObj.Info.ViVersion
                    }

                    $TempHyObjsInfo = [PSCustomObject]@{
                        Name = $HyObj.Name
                        Label = Get-DiaNodeIcon -Name $HyObj.Name -IconType "VBR_vCenter_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                        AditionalInfo = $Rows
                        Childs = & {
                            foreach ($Cluster in (Find-VBRViEntity -Server $HyObj | Where-Object { ($_.type -eq "cluster") }) ) {
                                [PSCustomObject]@{
                                    Name = $Cluster.Name
                                    Label = Get-DiaNodeIcon -Name $Esxi.Name -IconType "VBR_vSphere_Cluster" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                                    EsxiHost = foreach ($Esxi in $ESXis | Where-Object { $_.path -match $Cluster.Name }) {
                                        $Rows = @{
                                            IP = Get-NodeIP -Hostname $Esxi.Info.DnsName
                                            Version = $Esxi.Info.ViVersion
                                        }
                                        [PSCustomObject]@{
                                            Name = $Esxi.Name
                                            Label = Get-DiaNodeIcon -Name $Esxi.Name -IconType "VBR_ESXi_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                                            AditionalInfo = $Rows
                                        }
                                    }
                                }
                            }
                        }
                    }
                    $HyObjsInfo += $TempHyObjsInfo
                }
            }

            return $HyObjsInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}