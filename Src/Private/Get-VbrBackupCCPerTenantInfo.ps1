function Get-VbrBackupCCPerTenantInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication Cloud Connect per Tenant information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.30
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
        Write-Verbose -Message "Collecting Cloud Connect per Tenant information from $($VBRServer.Name)."
        try {

            $BackupCGPoolsInfo = @()
            if ($CloudObjects = Get-VBRCloudGatewayPool | Sort-Object -Property Name) {
                foreach ($CloudObject in $CloudObjects) {

                    $TempBackupCGPoolsInfo = [PSCustomObject]@{
                        Name = $CloudObject.Name
                        Label = Add-DiaNodeIcon -Name "$((Remove-SpecialChar -String $CloudObject.Name.split(".")[0] -SpecialChars '\').toUpper())" -IconType 'VBR_Tape_Server' -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug -FontSize 18
                        Id = $CloudObject.Id
                        CloudGateways = $CloudObject.CloudGateways
                    }

                    $BackupCGPoolsInfo += $TempBackupCGPoolsInfo
                }
            }

            return $BackupCGPoolsInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}