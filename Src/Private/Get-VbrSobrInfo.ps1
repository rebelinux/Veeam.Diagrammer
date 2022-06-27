function Get-VbrSobrInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication scale-out backup repository information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.0.2
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
        Write-Verbose -Message "Collecting Scale-Out Backup Repository information from $($VBRServer.Name)."
        try {
            $Sobrs = Get-VBRBackupRepository -ScaleOut
            $SobrInfo = @()
            if ($Sobrs) {
                foreach ($Sobr in $Sobrs) {

                    $Rows = @{
                        Performance = Remove-SpecialChars -String $Sobr.Extent.Name -SpecialChars '\'
                        Capacity = Remove-SpecialChars -String $Sobr.CapacityExtent.Repository.Name -SpecialChars '\'
                    }

                    $TempSobrInfo = [PSCustomObject]@{
                        Name = "$($Sobr.Name.toUpper())"
                        Label = Get-ImageNode -Name "$($Sobr.Name)" -Type "VBR_SOBR" -Align "Center" -Rows $Rows
                        Capacity = Remove-SpecialChars -String $Sobr.CapacityExtent.Repository.Name -SpecialChars '\'
                        Performance = Remove-SpecialChars -String $Sobr.Extent.Name -SpecialChars '\'
                    }
                    $SobrInfo += $TempSobrInfo
                }
            }

            return $SobrInfo
        }
        catch {
            $_
        }
    }
    end {}
}