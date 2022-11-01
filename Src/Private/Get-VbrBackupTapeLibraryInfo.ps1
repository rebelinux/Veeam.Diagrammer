function Get-VbrBackupTapeLibraryInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication tape libraries information.
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
    [OutputType([System.Object[]])]

    Param (
        [string] $TapeServer
    )

    process {
        Write-Verbose -Message "Collecting Tape Library information from $($VBRServer.Name)."
        try {

            if ($TapeServer) {
                $TapeLibraries = Get-VBRTapeLibrary -TapeServer $TapeServer
            } Else {$TapeLibraries = Get-VBRTapeLibrary}
            # $TapeMediaPool = Get-VBRTapeMediaPool
            # $TapeVault = Get-VBRTapeVault
            # $TapeDrive = Get-VBRTapeDrive
            # $TapeMedium = Get-VBRTapeMedium

            $BackupTapelibraryInfo = @()
            if ($TapeLibraries) {
                foreach ($TapeLibrary in $TapeLibraries) {

                    $Rows = [ordered ]@{
                        Role = 'Tape Library'
                        State = $TapeLibrary.State
                        Type = $TapeLibrary.Type
                    }


                    $TempBackupTapelibraryInfo = [PSCustomObject]@{
                        Name = "$((Remove-SpecialChars -String $TapeLibrary.Name -SpecialChars '\').toUpper()) "
                        Label = Get-NodeIcon -Name "$((Remove-SpecialChars -String $TapeLibrary.Name.split(".")[0] -SpecialChars '\').toUpper())" -Type 'VBR_Tape_Library' -Align "Center" -Rows $Rows
                        TapeServerId = $TapeLibrary.TapeServerId
                        Id = $TapeLibrary.Id
                    }

                    $BackupTapelibraryInfo += $TempBackupTapelibraryInfo
                }
            }

            return $BackupTapelibraryInfo
        }
        catch {
            $_
        }
    }
    end {}
}