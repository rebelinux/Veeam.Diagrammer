function Get-DiagBackupToWanAccel {
    <#
    .SYNOPSIS
        Function to build Backup Server to Wan Accelerator diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.1
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

    begin {
        # Get Veeam Backup Server Object
        Get-DiagBackupServer
    }

    process {
        try {

            $WanAccel = Get-VbrBackupWanAccelInfo

            if ($BackupServerInfo) {
                if ($WanAccel) {
                    $WANAccelAttr = @{
                        Label = 'Wan Accelerators'
                        fontsize = 18
                        penwidth = 1.5
                        labelloc = 't'
                        color = $SubGraphDebug.color
                        style = 'dashed,rounded'
                    }
                    SubGraph MainSubGraph -Attributes $WANAccelAttr -ScriptBlock {
                        foreach ($WANOBJ in $WanAccel) {
                            $WANHASHTABLE = @{}
                            $WANOBJ.psobject.properties | ForEach-Object { $WANHASHTABLE[$_.Name] = $_.Value }
                            Node $WANOBJ -NodeScript { $_.Name } @{Label = $WANHASHTABLE.Label; fontname = "Segoe Ui" }
                            Edge -From MainSubGraph:s -To $WANOBJ.Name @{constraint = "true"; minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        Rank $WanAccel.Name
                    }
                    if ($Dir -eq 'LR') {
                        Edge $BackupServerInfo.Name -To MainSubGraph @{minlen = 3; xlabel = ($WanAccel.TrafficPort[0]) }
                    } else {
                        Edge $BackupServerInfo.Name -To MainSubGraph @{minlen = 3; xlabel = ($WanAccel.TrafficPort[0]) }
                    }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}