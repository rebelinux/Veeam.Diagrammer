function Get-VbrBackupHyperVInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication hyperv hypervisor information.
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
        Write-Verbose -Message "Collecting HyperV HyperVisor information from $($VBRServer.Name)."
        try {
            $HyObjs = Get-VBRServer | Where-Object { $_.Type -eq 'HvCluster' }
            $HyObjsInfo = @()
            if ($HyObjs) {
                foreach ($HyObj in $HyObjs) {
                    $HvHosts = Find-VBRHvEntity -Server $HyObj | Where-Object { ($_.type -eq "HvServer") }
                    $Rows = @{
                        IP = Get-NodeIP -Hostname $HyObj.Info.DnsName
                        Version = $HyObj.Info.HvVersion
                    }

                    $TempHyObjsInfo = [PSCustomObject]@{
                        Name = $HyObj.Name
                        Label = Get-DiaNodeIcon -Name $HyObj.Name -IconType "VBR_HyperV_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                        AditionalInfo = $Rows
                        Childs = & {
                            foreach ($Cluster in (Find-VBRHvEntity -Server $HyObj | Where-Object { ($_.type -eq "cluster") }) ) {
                                [PSCustomObject]@{
                                    Name = $Cluster.Name
                                    Label = Get-DiaNodeIcon -Name $HvHosts.Name -IconType "VBR_HyperV_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                                    EsxiHost = foreach ($HvHost in $HvHosts | Where-Object {$_.path -match $Cluster.Name}) {
                                        $Rows = @{
                                            IP = Get-NodeIP -Hostname $HvHosts.Info.DnsName
                                            Version = $HvHosts.Info.HvVersion
                                        }
                                        [PSCustomObject]@{
                                            Name = $HvHosts.Name
                                            Label = Get-DiaNodeIcon -Name $HvHosts.Name -IconType "VBR_HyperV_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
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