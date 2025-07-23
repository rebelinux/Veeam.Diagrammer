function Get-VbrBackupvSphereStandAloneInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication vsphere Hypervisor information.
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
            $ViObjs = Get-VBRServer | Where-Object { $_.Type -eq 'ESXi' -and $_.Parentid -eq '00000000-0000-0000-0000-000000000000' }
            $ViObjsInfo = @()
            if ($ViObjs) {
                foreach ($ViObj in $ViObjs) {
                    try {
                        $Rows = @{
                            IP = Get-NodeIP -Hostname $ViObj.Info.DnsName
                            Version = switch ([string]::IsNullOrEmpty($ViObj.Info.ViVersion)) {
                                $true { 'Unknown' }
                                $false { $ViObj.Info.ViVersion }
                                Default { 'Unknown' }
                            }
                        }

                        $TempViObjsInfo = [PSCustomObject]@{
                            Name = $ViObj.Name
                            Label = Add-DiaNodeIcon -Name $ViObj.Name -IconType "VBR_ESXi_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                            AditionalInfo = $Rows
                        }
                        $ViObjsInfo += $TempViObjsInfo
                    } catch {
                        Write-Verbose -Message $_.Exception.Message
                    }
                }
            }

            return $ViObjsInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}