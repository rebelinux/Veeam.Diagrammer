function Get-DiagBackupToWanAccel {
    <#
    .SYNOPSIS
        Function to build Backup Server to Wan Accelerator diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.29
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
    }

    process {
        try {
            $WanAccel = Get-VbrBackupWanAccelInfo
            if ($BackupServerInfo) {
                if ($WanAccel) {

                    if ($WanAccel.Name.Count -eq 1) {
                        $WanAccelColumnSize = 1
                    } elseif ($ColumnSize) {
                        $WanAccelColumnSize = $ColumnSize
                    } else {
                        $WanAccelColumnSize = $WanAccel.Name.Count
                    }

                    Node WanAccelServer @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($WanAccel | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Wan_Accel" -columnSize $WanAccelColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo ($WanAccel.AditionalInfo ) -Subgraph -SubgraphIconType "VBR_Wan_Accel" -SubgraphLabel "Wan Accelerators" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -fontSize 18 -SubgraphLabelFontsize 22); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                    Edge BackupServers -To WanAccelServer @{minlen = 3; }
                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}