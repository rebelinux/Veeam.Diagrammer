function Get-VbrBackupEntraIDInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication entra id information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.35
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    param
    (

    )
    process {
        Write-Verbose -Message "Collecting Entra ID information from $($VBRServer.Name)."
        try {
            $EntraIDs = Get-VBREntraIDTenant
            $EntraIDInfo = @()
            if ($EntraIDs) {
                foreach ($EntraID in $EntraIDs) {

                    $Rows = @{
                        Region = $EntraID.Region
                        CacheRepository = $EntraID.CacheRepository.Name
                    }

                    $TempEntraIDInfo = [PSCustomObject]@{
                        Name = $EntraID.Name.toUpper()
                        Label = Add-DiaNodeIcon -FontBold -Name "$($EntraID.Name.toUpper())" -IconType "VBR_Microsoft_Entra_ID" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                        AditionalInfo = $Rows
                    }
                    $EntraIDInfo += $TempEntraIDInfo
                }
            }

            return $EntraIDInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}