function Get-VbrBackupHyperVClusterInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication hyperv hypervisor information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.19
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
                    try {
                        $HvHosts = Get-VBRServer | Where-Object { $_.Type -eq 'HvServer' -and $_.ParentId -match $HyObj.Id }
                        $Rows = @{
                            IP = Get-NodeIP -Hostname $HyObj.Info.DnsName
                        }

                        $TempHyObjsInfo = [PSCustomObject]@{
                            Name = $HyObj.Info.HostInstanceIdV2
                            Label = Get-DiaNodeIcon -Name $HyObj.Name -IconType "VBR_HyperV_Cluster" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug -fontSize 18
                            AditionalInfo = $Rows
                            Childs = & {
                                foreach ($HvHost in $HvHosts) {
                                    $Rows = @{
                                        IP = Get-NodeIP -Hostname $HvHost.Info.DnsName
                                        Version = $HvHost.Info.HvVersion
                                    }
                                    [PSCustomObject]@{
                                        Name = $HvHost.Name
                                        Label = Get-DiaNodeIcon -Name $HvHost.Name -IconType "VBR_HyperV_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug -fontSize 18
                                        AditionalInfo = $Rows
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