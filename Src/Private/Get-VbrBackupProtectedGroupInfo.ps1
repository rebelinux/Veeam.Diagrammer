function Get-VbrBackupProtectedGroupInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication protected group information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.7
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
        Write-Verbose -Message "Collecting Protected Group information from $($VBRServer.Name)."
        try {
            [Array]$ProtectedGroups = Get-VBRProtectionGroup

            $ProtectedGroupInfo = @()
            if ($ProtectedGroups) {
                foreach ($ProtectedGroup in $ProtectedGroups) {

                    $Rows = @{
                        'Type' = $ProtectedGroup.Type
                        'Status' = Switch ($ProtectedGroup.Enabled) {
                            $true { 'Enabled' }
                            $false { 'Disabled' }
                            default { 'Unknown' }
                        }
                        'Schedule' = $ProtectedGroup.ScheduleOptions.PolicyType
                    }

                    $Type = Get-IconType -String $ProtectedGroup.Container.Type

                    $TempProtectedGroupInfo = [PSCustomObject]@{
                        Name = "$((Remove-SpecialChar -String $ProtectedGroup.Name -SpecialChars '\').toUpper()) "
                        Label = Get-NodeIcon -Name "$((Remove-SpecialChar -String $ProtectedGroup.Name -SpecialChars '\').toUpper())" -Type $Type -Align "Center" -Rows $Rows
                        Container = $ProtectedGroup.Container.Type
                        Object = $ProtectedGroup
                    }

                    $ProtectedGroupInfo += $TempProtectedGroupInfo
                }
            }

            return $ProtectedGroupInfo
        } catch {
            $_
        }
    }
    end {}
}