function Get-DiagBackupToTape {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
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
            $BackupTapeServers = Get-VbrBackupTapeServerInfo
            $BackupTapeLibrary = Get-VbrBackupTapeLibraryInfo
            $BackupTapeDrives = Get-VbrBackupTapeDrivesInfo

            if ($BackupServerInfo) {
                if ($BackupTapeServers) {
                    SubGraph MainSubGraph -Attributes @{Label = 'Tape Servers'; fontsize = 22; penwidth = 1; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        if ($BackupTapeServers) {
                            SubGraph TapeServers -Attributes @{Label = ' '; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                                foreach ($TSOBJ in ($BackupTapeServers | Sort-Object -Property Name)) {
                                    $TSSubGraph = Remove-SpecialChar -String $TSOBJ.id -SpecialChars '\-'
                                    SubGraph  $TSSubGraph -Attributes @{Label = ' '; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                        $TSHASHTABLE = @{}
                                        $TSOBJ.psobject.properties | ForEach-Object { $TSHASHTABLE[$_.Name] = $_.Value }
                                        Node $TSOBJ -NodeScript { $_.Name } @{Label = $TSHASHTABLE.Label; fontname = "Segoe Ui" }
                                        if ($BackupTapeLibrary) {
                                            $BKPTLOBJ = ($BackupTapeLibrary | Where-Object { $_.TapeServerId -eq $TSOBJ.Id } | Sort-Object -Property Name)
                                            foreach ($TSLibraryOBJ in $BKPTLOBJ) {
                                                $TLSubGraph = Remove-SpecialChar -String $TSLibraryOBJ.id -SpecialChars '\-'
                                                SubGraph $TLSubGraph -Attributes @{Label = ' '; fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                                    $TSLHASHTABLE = @{}
                                                    $TSLibraryOBJ.psobject.properties | ForEach-Object { $TSLHASHTABLE[$_.Name] = $_.Value }
                                                    Node $TSLibraryOBJ -NodeScript { $_.Id } @{Label = $TSLHASHTABLE.Label; fontname = "Segoe Ui" }
                                                    if ($BackupTapeDrives) {
                                                        $TSLibraryOBJName = "$((Remove-SpecialChar -String $TSLibraryOBJ.Name -SpecialChars ' \_').toUpper())"
                                                        $TapeLibraryDrives = ($BackupTapeDrives | Where-Object { $_.LibraryId -eq $TSLibraryOBJ.Id } | Sort-Object -Property Name)

                                                        Node "$($TSLibraryOBJName)Drives" @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($TapeLibraryDrives | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Tape_Drive" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo ($TapeLibraryDrives.AditionalInfo )); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }

                                                        Edge -From $TSLibraryOBJ.id -To "$($TSLibraryOBJName)Drives"

                                                    }
                                                }
                                            }
                                            $BKPTLOBJ | ForEach-Object { Edge -From $TSOBJ.Name -To $_.id }
                                        }
                                    }
                                }
                                ($BackupTapeServers | Sort-Object -Property Name) | ForEach-Object { Edge -From MainSubGraph:s -To $_.Name @{style = $EdgeDebug.style; color = $EdgeDebug.color } }
                            }
                        }
                    }
                    Edge -From $BackupServerInfo.Name -To MainSubGraph @{minlen = 3 }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}