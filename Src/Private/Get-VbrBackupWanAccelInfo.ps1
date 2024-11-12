function Get-VbrBackupWanAccelInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication wan accelerator information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.9
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
        Write-Verbose -Message "Collecting Wan Accelerator information from $($VBRServer.Name)."
        try {
            $WANACCELS = Get-VBRWANAccelerator
            $WANACCELInfo = @()
            if ($WANACCELS) {
                foreach ($WANACCEL in $WANACCELS) {

                    $Rows = @{
                        # Role = 'Wan Accelerator'
                        IP = Get-NodeIP -HostName $WANACCEL.Name
                        TrafficPort = "$($WANAccel.GetWaTrafficPort())/TCP"
                    }

                    if ($WANAccel.FindWaHostComp().Options.CachePath) {
                        $Rows.add('Cache Path', $WANAccel.FindWaHostComp().Options.CachePath)
                        $Rows.add('Cache Size', "$($WANAccel.FindWaHostComp().Options.MaxCacheSize) $($WANAccel.FindWaHostComp().Options.SizeUnit)")
                    }


                    $TempWANACCELInfo = [PSCustomObject]@{
                        Name = "$($WANACCEL.Name.toUpper().split(".")[0])  ";
                        Label = Get-DiaNodeIcon -Name "$($WANACCEL.Name.toUpper().split(".")[0])" -IconType "VBR_Wan_Accel" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                        AditionalInfo = $Rows
                    }
                    $WANACCELInfo += $TempWANACCELInfo
                }
            }

            return $WANACCELInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}