function Get-DiagBackupToTape {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.6
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

            $BackupTapeServers = Get-VbrBackupTapeServerInfo
            $BackupTapeLibrary = Get-VbrBackupTapeLibraryInfo
            $BackupTapeDrives = Get-VbrBackupTapeDrivesInfo

            if ($BackupServerInfo) {
                if ($Dir -eq 'LR') {
                    $DiagramLabel = 'Tape Servers'
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = 'Tape Servers'
                }
                if ($BackupTapeServers) {
                    SubGraph MainSubGraph -Attributes @{Label=$DiagramLabel; fontsize=22; penwidth=1; labelloc='t'; style='dashed,rounded'; color=$SubGraphDebug.color} {
                        if ($BackupTapeServers) {
                            # Node used for subgraph centering
                            node TapeServersLabel @{Label=$DiagramDummyLabel; fontsize=22; fontname="Segoe Ui Black"; fontcolor='#005f4b'; shape='plain'}
                            if ($Dir -eq "TB") {
                                node TapeLeft @{Label='TapeLeft'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                                node TapeLeftt @{Label='TapeLeftt'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                                node TapeRight @{Label='TapeRight'; style=$EdgeDebug.style; color=$EdgeDebug.color; shape='plain'; fillColor='transparent'}
                                edge TapeLeft,TapeLeftt,TapeServersLabel,TapeRight @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                rank TapeLeft,TapeLeftt,TapeServersLabel,TapeRight
                            }
                            SubGraph TapeServers -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style=$SubGraphDebug.style; color=$SubGraphDebug.color} {
                                # Node used for subgraph centering
                                node TapeServerDummy @{Label=$DiagramDummyLabel; shape='plain'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                $Rank = @()
                                foreach ($TSOBJ in ($BackupTapeServers | Sort-Object -Property Name)) {
                                    $TSSubGraph = Remove-SpecialChars -String $TSOBJ.id -SpecialChars '\-'
                                    SubGraph  $TSSubGraph -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                        $TSHASHTABLE = @{}
                                        $TSOBJ.psobject.properties | ForEach-Object {$TSHASHTABLE[$_.Name] = $_.Value }
                                        node $TSOBJ -NodeScript {$_.Name} @{Label=$TSHASHTABLE.Label; fontname="Segoe Ui"}
                                        if ($BackupTapeLibrary) {
                                            $BKPTLOBJ = ($BackupTapeLibrary | Where-Object {$_.TapeServerId -eq $TSOBJ.Id} | Sort-Object -Property Name)
                                            foreach ($TSLibraryOBJ in $BKPTLOBJ) {
                                                $TLSubGraph = Remove-SpecialChars -String $TSLibraryOBJ.id -SpecialChars '\-'
                                                SubGraph $TLSubGraph -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed,rounded'} {
                                                    $TSLHASHTABLE = @{}
                                                    $TSLibraryOBJ.psobject.properties | ForEach-Object {$TSLHASHTABLE[$_.Name] = $_.Value }
                                                    node $TSLibraryOBJ -NodeScript {$_.Id} @{Label=$TSLHASHTABLE.Label; fontname="Segoe Ui"}
                                                    if ($BackupTapeDrives) {
                                                        $TapeLibraryDrives = ($BackupTapeDrives | Where-Object {$_.LibraryId -eq $TSLibraryOBJ.Id} | Sort-Object -Property Name)
                                                        if ($TapeLibraryDrives.count -le 3) {
                                                            foreach ($TSDriveOBJ in $TapeLibraryDrives) {
                                                                $TSDHASHTABLE = @{}
                                                                $TSDriveOBJ.psobject.properties | ForEach-Object {$TSDHASHTABLE[$_.Name] = $_.Value }
                                                                node $TSDriveOBJ -NodeScript {$_.Id} @{Label=$TSDHASHTABLE.Label; fontname="Segoe Ui"}
                                                                $TSDriveOBJ | foreach-object { edge -from $TSLibraryOBJ.id -to $_.id }
                                                            }
                                                        }
                                                        else {
                                                            $Group = Split-array -inArray $TapeLibraryDrives -size 3
                                                            $Number = 0
                                                            while ($Number -ne $Group.Length) {
                                                                $Random = Get-Random
                                                                SubGraph "TDGroup$($Number)_$Random" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                                    $Group[$Number] | ForEach-Object {
                                                                        $TSDHASHTABLE = @{}
                                                                        $_.psobject.properties | ForEach-Object {$TSDHASHTABLE[$_.Name] = $_.Value }
                                                                        node $_.Id @{Label=$TSDHASHTABLE.Label; fontname="Segoe Ui"}
                                                                    }
                                                                }
                                                                $Number++
                                                            }
                                                            edge -From $TSLibraryOBJ.id -To $Group[0].Id @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                                            $Start = 0
                                                            $TSNum = 1
                                                            while ($TSNum -ne $Group.Length) {
                                                                edge -From $Group[$Start].Id -To $Group[$TSNum].Id @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                                                                $Start++
                                                                $TSNum++
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            $BKPTLOBJ | ForEach-Object {edge -from $TSOBJ.Name -to $_.id}
                                        }
                                    }
                                }
                                ($BackupTapeServers | Sort-Object -Property Name) | ForEach-Object { edge -from TapeServerDummy -to $_.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}}
                            }
                            edge -from TapeServersLabel -to TapeServerDummy @{style=$EdgeDebug.style; color=$EdgeDebug.color}
                        }
                    }
                    edge -from $BackupServerInfo.Name -to TapeServersLabel @{minlen=2}
                }
            }
        }
        catch {
            $_
        }
    }
    end {}
}