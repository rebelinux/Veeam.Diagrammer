function Get-VbrBackupTapeServerInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication tape servers information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.19
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param (
    )

    process {
        Write-Verbose -Message "Collecting Tape Servers information from $($VBRServer.Name)."
        try {

            $TapeServers = Get-VBRTapeServer

            $BackupTapeServersInfo = @()
            if ($TapeServers) {
                foreach ($TapeServer in $TapeServers) {

                    $Rows = @{
                        IP = Get-NodeIP -HostName $TapeServer.Name
                        Role = 'Tape Server'
                        State = Switch ($TapeServer.IsAvailable) {
                            'True' { 'Available' }
                            'False' { 'Unavailable' }
                        }
                    }


                    $TempBackupTapeServersInfo = [PSCustomObject]@{
                        Name = $TapeServer.Name
                        Label = Get-DiaNodeIcon -Name "$((Remove-SpecialChar -String $TapeServer.Name.split(".")[0] -SpecialChars '\').toUpper())" -IconType 'VBR_Tape_Server' -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug -fontSize 18
                        Id = $TapeServer.Id
                    }

                    $BackupTapeServersInfo += $TempBackupTapeServersInfo
                }
            }

            return $BackupTapeServersInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}