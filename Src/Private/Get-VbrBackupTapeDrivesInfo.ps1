function Get-VbrBackupTapeDrivesInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication tape drives information.
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
        [string] $TapeLibrary
    )

    process {
        Write-Verbose -Message "Collecting Tape Drives information from $($VBRServer.Name)."
        try {

            if ($TapeLibrary) {
                $TapeDrives = Get-VBRTapeDrive -Library $TapeLibrary
            } Else {$TapeDrives = Get-VBRTapeDrive}
            # $TapeMediaPool = Get-VBRTapeMediaPool
            # $TapeVault = Get-VBRTapeVault
            # $TapeDrive = Get-VBRTapeDrive
            # $TapeMedium = Get-VBRTapeMedium

            $BackupTapeDriveInfo = @()
            if ($TapeDrives) {
                foreach ($TapeDrive in $TapeDrives) {

                    $Rows = [ordered ]@{
                        # Role = 'Tape Drive'
                        'Serial#' = $TapeDrive.SerialNumber
                        Model = $TapeDrive.Model
                        'Drive ID' = $TapeDrive.Name
                    }


                    $TempBackupTapeDriveInfo = [PSCustomObject]@{
                        Name = "$((Remove-SpecialChars -String ($TapeDrive.Name) -SpecialChars '\').toUpper()) "
                        Label = Get-NodeIcon -Name "$((Remove-SpecialChars -String ("Drive $($TapeDrive.Address + 1)").split(".")[0] -SpecialChars '\').toUpper())" -Type 'VBR_Tape_Drive' -Align "Center" -Rows $Rows
                        LibraryId = $TapeDrive.LibraryId
                        Id = $TapeDrive.Id
                    }

                    $BackupTapeDriveInfo += $TempBackupTapeDriveInfo
                }
            }

            return $BackupTapeDriveInfo
        }
        catch {
            $_
        }
    }
    end {}
}