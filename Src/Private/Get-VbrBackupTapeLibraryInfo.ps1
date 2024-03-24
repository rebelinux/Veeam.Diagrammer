function Get-VbrBackupTapeLibraryInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication tape libraries information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.9
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param (
        [string] $TapeServer
    )

    process {
        Write-Verbose -Message "Collecting Tape Library information from $($VBRServer.Name)."
        try {

            if ($TapeServer) {
                $TapeLibraries = Get-VBRTapeLibrary -TapeServer $TapeServer
            } Else { $TapeLibraries = Get-VBRTapeLibrary }

            $BackupTapelibraryInfo = @()
            if ($TapeLibraries) {
                foreach ($TapeLibrary in $TapeLibraries) {

                    $Rows = [ordered ]@{
                        Role = 'Tape Library'
                        State = $TapeLibrary.State
                        Type = $TapeLibrary.Type
                    }


                    $TempBackupTapelibraryInfo = [PSCustomObject]@{
                        Name = "$((Remove-SpecialChar -String $TapeLibrary.Name -SpecialChars '\').toUpper())_$(Get-Random)"
                        Label = Get-DiaNodeIcon -Name "$((Remove-SpecialChar -String $TapeLibrary.Name.split(".")[0] -SpecialChars '\').toUpper())" -IconType 'VBR_Tape_Library' -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                        TapeServerId = $TapeLibrary.TapeServerId
                        Id = $TapeLibrary.Id
                    }

                    $BackupTapelibraryInfo += $TempBackupTapelibraryInfo
                }
            }

            return $BackupTapelibraryInfo
        } catch {
            $_
        }
    }
    end {}
}