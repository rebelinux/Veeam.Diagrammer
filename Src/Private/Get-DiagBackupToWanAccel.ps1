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
                        labelloc = 'b'
                        color = $SubGraphDebug.color
                        style = 'dashed,rounded'
                    }
                    SubGraph MainSubGraph -Attributes $WANAccelAttr -ScriptBlock {

                        Node WanAccelServer @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($WanAccel | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Wan_Accel" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($WanAccel.AditionalInfo )); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }

                    }

                    Edge $BackupServerInfo.Name -To WanAccelServer @{minlen = 3; xlabel = ($WanAccel.AditionalInfo.TrafficPort[0]) }

                }
            }
        } catch {
            $_
        }
    }
    end {}
}