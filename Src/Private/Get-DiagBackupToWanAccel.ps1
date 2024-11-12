function Get-DiagBackupToWanAccel {
    <#
    .SYNOPSIS
        Function to build Backup Server to Wan Accelerator diagram.
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
                    Node WanAccelServer @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($WanAccel | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Wan_Accel" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($WanAccel.AditionalInfo ) -Subgraph -SubgraphIconType "VBR_Wan_Accel" -SubgraphLabel "Wan Accelerators" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                    Edge $BackupServerInfo.Name -To WanAccelServer @{minlen = 3; }
                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}