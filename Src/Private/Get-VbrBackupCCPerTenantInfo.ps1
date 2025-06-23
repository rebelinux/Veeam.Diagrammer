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
        [Parameter(Mandatory = $true)]
        [string]$TenantName
    )

    process {
        Write-Verbose -Message "Collecting Cloud Connect per Tenant information from $($VBRServer.Name)."
        try {

            $BackupCCTenantInfo = @()
            if ($CloudObject = Get-VBRCloudTenant -Name $TenantName) {

                $AditionalInfo = [PSCustomObject] [ordered] @{
                    'Type' = Switch ($CloudObject.Type) {
                        'Ad' { 'Active Directory' }
                        'General' { 'Standalone' }
                        'vCD' { 'vCloud Director' }
                        default { 'Unknown' }
                    }
                    'Status' = Switch ($CloudObject.Enabled) {
                        'True' { 'Enabled' }
                        'False' { 'Disabled' }
                        default { 'Unknown' }
                    }
                    'Expiration Date' = Switch ([string]::IsNullOrEmpty($CloudObject.LeaseExpirationDate)) {
                        $true { 'Never' }
                        $false {
                            & {
                                if ($CloudObject.LeaseExpirationDate -lt (Get-Date)) {
                                    "$($CloudObject.LeaseExpirationDate.ToShortDateString()) (Expired)"
                                } else { $CloudObject.LeaseExpirationDate.ToShortDateString() }
                            }
                        }
                        default { '--' }
                    }
                }

                # Todo: Add more information to the AditionalInfo object as needed.
                # CloudObject.Resources.FriendlyName
                #         AdditionalInfo (Quota, etc...)
                #            Subgraph
                #      Backup Repositories (Get info from Get-VbrBackupCCBackupStorageInfo)
                #         AdditionalInfo

                $TempBackupCCTenantInfo = [PSCustomObject]@{
                    Name = $CloudObject.Name
                    Label = Add-DiaNodeIcon -Name "$((Remove-SpecialChar -String $CloudObject.Name.split(".")[0] -SpecialChars '\').toUpper())" -IconType 'VBR_Cloud_Connect_Gateway' -Align "Center" -AditionalInfo $AditionalInfo -ImagesObj $Images -IconDebug $IconDebug -FontSize 18
                    Id = $CloudObject.Id
                    CloudGatewaySelectionType = $CloudObject.GatewaySelectionType
                    CloudGatewayPools = & {
                        Get-VbrBackupCGPoolInfo | Where-Object { $_.Name -eq $CloudObject.GatewayPool }

                    }
                    BackupResources = & {
                        if ($CloudObject.Resources) {
                            $CloudObject.Resources | ForEach-Object {
                                $AditionalInfo = [PSCustomObject]@{
                                    "Used Space" = ConvertTo-FileSizeString -Size (Convert-Size -From MB -To Bytes -Value $_.UsedSpace) -RoundUnits 2
                                    "Quota" = ConvertTo-FileSizeString -Size (Convert-Size -From MB -To Bytes -Value $_.RepositoryQuota) -RoundUnits 2
                                    "Quota Path" = $_.RepositoryQuotaPath
                                }
                                [PSCustomObject]@{
                                    Name = $_.RepositoryFriendlyName
                                    Label = Add-DiaNodeIcon -Name "$($_.RepositoryFriendlyName)" -IconType "VBR_Cloud_Repository" -Align "Center" -AditionalInfo $AditionalInfo -ImagesObj $Images -IconDebug $IconDebug
                                    Id = $_.Id
                                    WanAccelerationEnabled = Switch ($_.WanAccelerationEnabled) {
                                        'True' { 'Enabled' }
                                        'False' { 'Disabled' }
                                        default { 'Unknown' }
                                    }
                                    WanAccelerator = & {
                                        if ($_.WanAccelerator.Name) {
                                            $WANName = $_.WanAccelerator.Name.split(".")[0]
                                            Get-VbrBackupWanAccelInfo | Where-Object { $_.Name -eq $WANName }
                                        }
                                    }
                                    Repositories = & {
                                        foreach ($Repository in $_.Repository.Name) {
                                            $RepoName = $Repository
                                            Get-VbrBackupCCBackupStorageInfo | Where-Object { $_.Name -eq $RepoName }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    ReplicationResources = & {
                        if ($CloudObject.Resources) {
                            $CloudObject.ReplicationResources | ForEach-Object {
                                $NetExEnabled = $_.NetworkFailoverResourcesEnabled
                                [PSCustomObject]@{
                                    'NetworkFailoverResourcesEnabled' = Switch ($_.NetworkFailoverResourcesEnabled) {
                                        'True' { 'Enabled' }
                                        'False' { 'Disabled' }
                                        default { 'Unknown' }
                                    }
                                    "Public Ip Enabled" = $_.PublicIpEnabled
                                    "Public IpV6 Enabled" = $_.PublicIpV6Enabled
                                    "Number Of Public Ip" = $_.NumberOfPublicIp
                                    'Number Of Public IpV6' = $_.NumberOfPublicIpV6
                                    HardwarePlanOptions = & {
                                        if ($_.HardwarePlanOptions) {
                                            $_.HardwarePlanOptions | ForEach-Object {
                                                $HardwarePlanId = $_.HardwarePlanId
                                                $HardwarePlanObject = Get-VbrBackupCCReplicaResourcesInfo | Where-Object { $_.id -eq $HardwarePlanId }
                                                [PSCustomObject]@{
                                                    Name = $HardwarePlanObject.Name
                                                    Label = $HardwarePlanObject.Label
                                                    NetworkExtensions = & {
                                                        if ($NetExEnabled) {
                                                            Get-VBRCloudTenantNetworkAppliance -Tenant $CloudObject | Where-Object { $_.HardwarePlanId -eq $HardwarePlanId } | ForEach-Object {
                                                                $AditionalInfo = [PSCustomObject]@{
                                                                    'Platform' = $_.Platform
                                                                    'Network Name' = $_.ProductionNetwork.NetworkName
                                                                    'Switch Name' = $_.ProductionNetwork.SwitchName
                                                                    'Ip Address' = $_.IpAddress
                                                                    'Network Mask' = $_.SubnetMask
                                                                    'Gateway' = $_.DefaultGateway
                                                                }
                                                                [PSCustomObject]@{
                                                                    'Name' = $_.Name
                                                                    'Label' = Add-DiaNodeIcon -Name "$($_.Name)" -IconType "VBR_Cloud_Network_Extension" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug -AditionalInfo $AditionalInfo
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    CloudGatewayServers = & {
                        if ($CloudObject.GatewaySelectionType -eq 'StandaloneGateways') {
                            Get-VbrBackupCGServerInfo
                        }
                    }
                }

                $BackupCCTenantInfo += $TempBackupCCTenantInfo
            }

            return $BackupCCTenantInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}