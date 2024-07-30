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
                                                        $TapeLibraryDrives = ($BackupTapeDrives | Where-Object { $_.LibraryId -eq $TSLibraryOBJ.Id } | Sort-Object -Property Name)
                                                        if (($TapeLibraryDrives | Measure-Object).count -le 3) {
                                                            foreach ($TSDriveOBJ in $TapeLibraryDrives) {
                                                                $TSDHASHTABLE = @{}
                                                                $TSDriveOBJ.psobject.properties | ForEach-Object { $TSDHASHTABLE[$_.Name] = $_.Value }
                                                                Node $TSDriveOBJ -NodeScript { $_.Id } @{Label = $TSDHASHTABLE.Label; fontname = "Segoe Ui" }
                                                                $TSDriveOBJ | ForEach-Object { Edge -From $TSLibraryOBJ.id -To $_.id }
                                                            }
                                                        } else {
                                                            $Group = Split-array -inArray $TapeLibraryDrives -size 3
                                                            $Number = 0
                                                            while ($Number -ne $Group.Length) {
                                                                $Random = Get-Random
                                                                SubGraph "TDGroup$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                                                    $Group[$Number] | ForEach-Object {
                                                                        $TSDHASHTABLE = @{}
                                                                        $_.psobject.properties | ForEach-Object { $TSDHASHTABLE[$_.Name] = $_.Value }
                                                                        Node $_.Id @{Label = $TSDHASHTABLE.Label; fontname = "Segoe Ui" }
                                                                    }
                                                                }
                                                                $Number++
                                                            }
                                                            Edge -From $TSLibraryOBJ.id -To $Group[0].Id @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                                                            $Start = 0
                                                            $TSNum = 1
                                                            while ($TSNum -ne $Group.Length) {
                                                                Edge -From $Group[$Start].Id -To $Group[$TSNum].Id @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                                                                $Start++
                                                                $TSNum++
                                                            }
                                                        }
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
                    Edge -From $BackupServerInfo.Name -To MainSubGraph @{lhead = 'clusterMainSubGraph'; minlen = 3 }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}