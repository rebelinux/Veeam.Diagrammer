function Get-DiagBackupToWanAccel {
    <#
    .SYNOPSIS
        Function to build Backup Server to Wan Accelerator diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.35
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]

    param
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

                    Node WanAccelServer @{Label = (Add-DiaHtmlNodeTable -ImagesObj $Images -inputObject ($WanAccel | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Wan_Accel" -ColumnSize $WanAccelColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo ($WanAccel.AditionalInfo ) -Subgraph -SubgraphIconType "VBR_Wan_Accel" -SubgraphLabel "Wan Accelerators" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -FontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -FontSize 18 -SubgraphLabelFontSize 22 -SubgraphFontBold -FontBold); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                    Edge BackupServers -To WanAccelServer @{minlen = 3 }

                }

            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}