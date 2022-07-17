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

            $WanAccel = Get-VbrBackupWanAccelInfo

            if ($BackupServerInfo) {

                if ($WanAccel) {
                    $WANAccelAttr = @{
                        Label = ' '
                        fontsize = 18
                        penwidth = 1.5
                        labelloc = 'b'
                    }
                    SubGraph WANACCEL -Attributes $WANAccelAttr -ScriptBlock {
                        # Node used for subgraph centering
                        node WANACCELSERVER @{Label='Wan Accelerators'; fontsize=18; fontname="Comic Sans MS bold"; fontcolor='#005f4b'}
                        foreach ($WANOBJ in $WanAccel) {
                            $WANHASHTABLE = @{}
                            $WANOBJ.psobject.properties | ForEach-Object { $WANHASHTABLE[$_.Name] = $_.Value }
                            node $WANOBJ -NodeScript {$_.Name} @{Label=$WANHASHTABLE.Label}
                            edge -From WANACCELSERVER -To $WANOBJ.Name @{minlen=1; style='invis'}
                        }
                        Rank $WanAccel.Name
                    }
                    edge $BackupServerInfo.Name -to WANACCELSERVER @{minlen=3; xlabel=($WanAccel.TrafficPort[0])}
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}