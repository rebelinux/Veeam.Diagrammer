function Get-DiagBackupToSobr {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
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
            $SobrRepo = Get-VbrBackupSobrInfo

            if ($SobrRepo) {
                if ($SobrRepo) {
                    SubGraph MainSubGraph -Attributes @{Label = 'SOBR Repositories' ; fontsize = 22; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        foreach ($SOBROBJ in $SobrRepo) {
                            $SubGraphName = Remove-SpecialChar -String $SOBROBJ.Name -SpecialChars '\- '
                            SubGraph $SubGraphName  -Attributes @{Label = $SOBROBJ.Name; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                $SOBROBJ | ForEach-Object { Node $_.Name @{Label = $_.Label; fontname = "Segoe Ui"; shape = "plain"; fillColor = 'transparent' } }
                                if ($SOBROBJ.Performance) {
                                    SubGraph "$($SubGraphName)Performance" -Attributes @{Label = "Performance Extent"; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = "dashed,rounded"; } {

                                        $SOBROBJ.Performance | ForEach-Object { Node $_.Name @{Label = Get-DiaNodeIcon -Name $_.Name -IconType $_.IconType -Align "Center" -Rows $_.AditionalInfo -ImagesObj $Images -IconDebug $IconDebug; fontname = "Segoe Ui"; shape = "plain"; fillColor = 'transparent' } }
                                    }
                                }
                                if ($SOBROBJ.Capacity) {
                                    SubGraph "$($SubGraphName)Capacity" -Attributes @{Label = "Capacity Extent"; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = "dashed,rounded" } {

                                        $SOBROBJ.Capacity | ForEach-Object { Node $_.Name @{Label = Get-DiaNodeIcon -Name $_.Name -IconType $_.IconType -Align "Center" -Rows $_.AditionalInfo -ImagesObj $Images -IconDebug $IconDebug; fontname = "Segoe Ui"; shape = "plain"; fillColor = 'transparent' } }
                                    }
                                }
                                if ($SOBROBJ.Archive) {
                                    SubGraph "$($SubGraphName)Archive" -Attributes @{Label = "Archive Extent"; fontsize = 18; penwidth = 1.5; labelloc = 'b'; style = "dashed,rounded" } {

                                        $SOBROBJ.Archive | ForEach-Object { Node $_.Name @{Label = Get-DiaNodeIcon -Name $_.Name -IconType $_.Icon -Align "Center" -Rows $_.Rows -ImagesObj $Images -IconDebug $IconDebug; fontname = "Segoe Ui"; shape = "plain"; fillColor = 'transparent' } }
                                    }
                                }

                                if ($SOBROBJ.Archive) {
                                    $SOBROBJ.Performance | ForEach-Object { Edge -From $SOBROBJ.Name -To $SOBROBJ.Archive.Name, $SOBROBJ.Capacity.Name, $_.Name @{minlen = 2 } } | Select-Object -Unique

                                } else {
                                    $SOBROBJ.Performance | ForEach-Object { Edge -From $SOBROBJ.Name -To $_.Name @{minlen = 2 } } | Select-Object -Unique
                                    $SOBROBJ.Capacity | ForEach-Object { Edge -From $SOBROBJ.Name -To $_.Name @{minlen = 2 } } | Select-Object -Unique

                                }
                            }
                            Edge -From MainSubGraph:s -To $SOBROBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                    }
                    Edge -From $BackupServerInfo.Name -To MainSubGraph @{minlen = 3 }

                }
            }
        } catch {
            Write-Verbose $_.Exception.Message
        }
    }
    end {}
}