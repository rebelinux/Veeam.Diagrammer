function Get-DiagBackupToWanAccel {
    <#
    .SYNOPSIS
        Function to build Backup Server to Wan Accelerator diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.3
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
                        color=$SubGraphDebug.color
                        style='dashed,rounded'
                    }
                    SubGraph MAINWANACCEL -Attributes $WANAccelAttr -ScriptBlock {
                        # Dummy Node used for subgraph centering
                        node WANACCELSERVER @{Label='Wan Accelerators'; fontsize=18; fontname="Segoe Ui Black"; fontcolor='#005f4b'; shape='plain'}
                        foreach ($WANOBJ in $WanAccel) {
                            $WANHASHTABLE = @{}
                            $WANOBJ.psobject.properties | ForEach-Object { $WANHASHTABLE[$_.Name] = $_.Value }
                            node $WANOBJ -NodeScript {$_.Name} @{Label=$WANHASHTABLE.Label; fontname="Segoe Ui"}
                            edge -From WANACCELSERVER -To $WANOBJ.Name @{minlen=1; style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                        Rank $WanAccel.Name
                        Record WANACCEL @(
                            'Name'
                            'Environment'
                            'Test <I>[string]</I>'
                        )
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