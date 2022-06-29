function Get-VbrWanAccelInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication wan accelerator information.
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
        Write-Verbose -Message "Collecting Wan Accelerator information from $($VBRServer.Name)."
        try {
            $WANACCELS = Get-VbrWanAccelerator
            $WANACCELInfo = @()
            if ($WANACCELS) {
                foreach ($WANACCEL in $WANACCELS) {
                    try {
                        $WANACCELIP = Switch ((Resolve-DnsName $WANACCEL.Name -ErrorAction SilentlyContinue).IPAddress) {
                            $Null {'Unknown'}
                            default {(Resolve-DnsName $WANACCEL.Name -ErrorAction SilentlyContinue).IPAddress}
                        }
                    }
                    catch {
                        $_
                    }

                    $Rows = @{
                        Role = 'Wan Accelerator'
                        IP = $WANACCELIP
                    }


                    $TempWANACCELInfo = [PSCustomObject]@{
                        Name = "$($WANACCEL.Name.toUpper().split(".")[0]) (WAN)";
                        Label = Get-ImageNode -Name "$($WANACCEL.Name.toUpper().split(".")[0]) (WAN)" -Type "VBR_Wan_Accel" -Align "Center" -Rows $Rows
                    }
                    $WANACCELInfo += $TempWANACCELInfo
                }
            }

            return $WANACCELInfo
        }
        catch {
            $_
        }
    }
    end {}
}