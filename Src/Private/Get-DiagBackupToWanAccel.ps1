function Get-DiagBackupToWanAccel {
    <#
    .SYNOPSIS
        Function to build Backup Server to Wan Accelerator diagram.
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
        try {

            $WanAccel = Get-VbrWanAccelInfo

            if ($BackupServerInfo) {

                if ($WanAccel) {
                    $WANAccelAttr = @{
                        Label = 'Wan Accelerators'
                        fontsize = 18
                        penwidth = 1.5
                        labelloc = 'b'
                    }
                    SubGraph WANACCEL -Attributes $WANAccelAttr -ScriptBlock {
                        foreach ($WANOBJ in $WanAccel) {
                            $WANHASHTABLE = @{}
                            $WANOBJ.psobject.properties | ForEach-Object { $WANHASHTABLE[$_.Name] = $_.Value }
                            node $WANOBJ -NodeScript {$_.Name} @{Label=$WANHASHTABLE.Label}
                        }
                        # if ($WanAccel.count -le 1) {
                        #     rank $WanAccel -NodeScript {$_.Name}
                        #     $WanAccel | ForEach-Object { edge -From $_.Name -To BackupServer @{minlen=0}}
                        # } else {
                        #     rank $WanAccel -NodeScript {$_.Name}
                        #     edge -from BackupServer -to WANACCEL @{minlen=0}
                        # }
                    }
                    $WanAccel | ForEach-Object {edge $BackupServerInfo.Name -to $_.Name @{minlen=3; label=$_.TrafficPort}}
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}