function Get-DiagBackupToTape {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Repository diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.4.0
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

                if ($BackupTapeServers) {
                    SubGraph TapeInfra -Attributes @{Label=''; fontsize=18; penwidth=1; labelloc='b'; style=$SubGraphDebug.style; color=$SubGraphDebug.color} {
                        if ($BackupTapeServers) {
                            # Node used for subgraph centering
                            node TapeServersLabel @{Label='Tape Servers'; fontsize=22; fontname="Comic Sans MS bold"; fontcolor='#005f4b'; shape='plain'}
                            SubGraph TapeServers -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed'} {
                                # Node used for subgraph centering
                                node TapeServerDummy @{Label='TapeServerDummy'; shape='plain'; style=$EdgeDebug.style; color=$EdgeDebug.color}
                                $Rank = @()
                                foreach ($TSOBJ in ($BackupTapeServers | Sort-Object -Property Name)) {
                                    $TSSubGraph = Remove-SpecialChars -String $TSOBJ.id -SpecialChars '\-'
                                    SubGraph  $TSSubGraph -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed'} {
                                        $TSHASHTABLE = @{}
                                        $TSOBJ.psobject.properties | ForEach-Object {$TSHASHTABLE[$_.Name] = $_.Value }
                                        node $TSOBJ -NodeScript {$_.Name} @{Label=$TSHASHTABLE.Label}
                                        if ($BackupTapeLibrary) {
                                            $BKPTLOBJ = ($BackupTapeLibrary | Where-Object {$_.TapeServerId -eq $TSOBJ.Id} | Sort-Object -Property Name)
                                            foreach ($TSLibraryOBJ in $BKPTLOBJ) {
                                                $TLSubGraph = Remove-SpecialChars -String $TSLibraryOBJ.id -SpecialChars '\-'
                                                SubGraph $TLSubGraph -Attributes @{Label=' '; fontsize=18; penwidth=1.5; labelloc='t'; style='dashed'} {
                                                    $TSLHASHTABLE = @{}
                                                    $TSLibraryOBJ.psobject.properties | ForEach-Object {$TSLHASHTABLE[$_.Name] = $_.Value }
                                                    node $TSLibraryOBJ -NodeScript {$_.Id} @{Label=$TSLHASHTABLE.Label}
                                                    if ($BackupTapeDrives) {
                                                        $TapeLibraryDrives = ($BackupTapeDrives | Where-Object {$_.LibraryId -eq $TSLibraryOBJ.Id} | Sort-Object -Property Name)
                                                        if ($TapeLibraryDrives.count -le 4) {
                                                            foreach ($TSDriveOBJ in $TapeLibraryDrives) {
                                                                $TSDHASHTABLE = @{}
                                                                $TSDriveOBJ.psobject.properties | ForEach-Object {$TSDHASHTABLE[$_.Name] = $_.Value }
                                                                node $TSDriveOBJ -NodeScript {$_.Id} @{Label=$TSDHASHTABLE.Label}
                                                                edge -from $TSLibraryOBJ.id -to $TSDriveOBJ.id
                                                            }
                                                        }
                                                        else {
                                                            $Group = Split-array -inArray $TapeLibraryDrives -size 4
                                                            $Number = 0
                                                            while ($Number -ne $Group.Length) {
                                                                SubGraph "TDGroup$($Number)" -Attributes @{Label=' '; style=$SubGraphDebug.style; color=$SubGraphDebug.color; fontsize=18; penwidth=1} {
                                                                    $Group[$Number] | ForEach-Object {
                                                                        $TSDHASHTABLE = @{}
                                                                        $_.psobject.properties | ForEach-Object {$TSDHASHTABLE[$_.Name] = $_.Value }
                                                                        node $_.Id @{Label=$TSDHASHTABLE.Label}
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
                                            edge -from $TSOBJ.Name -to $BKPTLOBJ.id
                                        }
                                    }
                                }
                                edge -from TapeServerDummy -to $BackupTapeServers.Name @{style=$EdgeDebug.style; color=$EdgeDebug.color}
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