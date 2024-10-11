# Proxy Graphviz Cluster
function Get-VbrProxyInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Proxy information from $($VBRServer.Name)."
        $Proxies = @()
        $Proxies += Get-VBRViProxy
        $Proxies += Get-VBRHvProxy

        if ($Proxies) {

            $ProxiesInfo = @()

            $Proxies | ForEach-Object {
                $inobj = [ordered] @{
                    'Type' = Switch ($_.Type) {
                        'Vi' { 'vSphere' }
                        'HvOffhost' { 'Off host' }
                        'HvOnhost' { 'On host' }
                        default { $_.Type }
                    }
                    'Max Tasks' = $_.Options.MaxTasksCount
                }

                $IconType = Get-IconType -String 'ProxyServer'

                $TempProxyInfo = [PSCustomObject]@{
                    Name = $_.Host.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }

                $ProxiesInfo += $TempProxyInfo
            }
        }

        return $ProxiesInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }

}

# Nas Proxy Graphviz Cluster
function Get-VbrNASProxyInfo {
    param (
    )
    try {
        Write-Verbose "Collecting NAS Proxy information from $($VBRServer.Name)."
        $Proxies = @()
        $Proxies += Get-VBRNASProxyServer


        if ($Proxies) {

            $ProxiesInfo = @()

            $Proxies | ForEach-Object {
                $inobj = [ordered] @{
                    'Enabled' = Switch ($_.IsEnabled) {
                        'True' { 'Yes' }
                        'False' { 'No' }
                        default { 'Unknown' }
                    }
                    'Max Tasks' = $_.ConcurrentTaskNumber
                }

                $IconType = Get-IconType -String 'ProxyServer'

                $TempProxyInfo = [PSCustomObject]@{
                    Name = $_.Server.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }

                $ProxiesInfo += $TempProxyInfo
            }
        }

        return $ProxiesInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }

}

# Wan Accel Graphviz Cluster
function Get-VbrWanAccelInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Wan Accel information from $($VBRServer.Name)."
        $WanAccels = Get-VBRWANAccelerator

        if ($WanAccels) {

            $WanAccelsInfo = @()

            $WanAccels | ForEach-Object {
                $inobj = [ordered] @{
                    'CacheSize' = "$($_.FindWaHostComp().Options.MaxCacheSize) $($_.FindWaHostComp().Options.SizeUnit)"
                    'TrafficPort' = "$($_.GetWaTrafficPort())/TCP"
                }

                $TempWanAccelInfo = [PSCustomObject]@{
                    Name = $_.Name
                    AditionalInfo = $inobj
                }

                $WanAccelsInfo += $TempWanAccelInfo
            }
        }

        return $WanAccelsInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }

}

# Repositories Graphviz Cluster
function Get-VbrRepositoryInfo {
    param (
    )

    [Array]$Repositories = Get-VBRBackupRepository | Where-Object { $_.Type -notin @("SanSnapshotOnly", "AmazonS3Compatible", "WasabiS3", "SmartObjectS3") } | Sort-Object -Property Name
    [Array]$ScaleOuts = Get-VBRBackupRepository -ScaleOut | Sort-Object -Property Name
    if ($ScaleOuts) {
        $Extents = Get-VBRRepositoryExtent -Repository $ScaleOuts | Sort-Object -Property Name
        $Repositories += $Extents.Repository
    }
    if ($Repositories) {
        $RepositoriesInfo = @()

        foreach ($Repository in $Repositories) {
            $Role = Get-RoleType -String $Repository.Type

            $Rows = [ordered]@{}

            if ($Repository.Host.Name) {
                $Rows.add('Server', $Repository.Host.Name.Split('.')[0])
            } else {
                $Rows.add('Server', 'N/A')
            }
            $Rows.add('Repo Type', $Role)
            $Rows.add('Total Space', "$(($Repository).GetContainer().CachedTotalSpace.InGigabytes) GB")
            $Rows.add('Used Space', "$(($Repository).GetContainer().CachedFreeSpace.InGigabytes) GB")

            if (($Role -ne 'Dedup Appliances') -and ($Role -ne 'SAN') -and ($Repository.Host.Name -in $ViBackupProxy.Host.Name -or $Repository.Host.Name -in $HvBackupProxy.Host.Name)) {
                $BackupType = 'Proxy'
            } else { $BackupType = $Repository.Type }

            $IconType = Get-IconType -String $BackupType

            $TempBackupRepoInfo = [PSCustomObject]@{
                Name = "$((Remove-SpecialChar -String $Repository.Name -SpecialChars '\').toUpper()) "
                AditionalInfo = $Rows
                IconType = $IconType
            }

            $RepositoriesInfo += $TempBackupRepoInfo
        }
        return $RepositoriesInfo
    }

}

# Object Repositories Graphviz Cluster
function Get-VbrObjectRepoInfo {
    param (
    )

    $ObjectRepositories = Get-VBRObjectStorageRepository
    if ($ObjectRepositories) {

        $ObjectRepositoriesInfo = @()

        $ObjectRepositories | ForEach-Object {
            $inobj = @{
                'Type' = $_.Type
                'Folder' = & {
                    if ($_.AmazonS3Folder) {
                        $_.AmazonS3Folder
                    } elseif ($_.AzureBlobFolder) {
                        $_.AzureBlobFolder
                    } else { 'Unknown' }
                }
                'Gateway' = & {
                    if (-Not $_.UseGatewayServer) {
                        Switch ($_.ConnectionType) {
                            'Gateway' {
                                switch (($_.GatewayServer | Measure-Object).count) {
                                    0 { "Disable" }
                                    1 { $_.GatewayServer.Name.Split('.')[0] }
                                    Default { 'Automatic' }
                                }
                            }
                            'Direct' { 'Direct' }
                            default { 'Unknown' }
                        }
                    } else {
                        switch (($_.GatewayServer | Measure-Object).count) {
                            0 { "Disable" }
                            1 { $_.GatewayServer.Name.Split('.')[0] }
                            Default { 'Automatic' }
                        }
                    }
                }
            }

            $IconType = Get-IconType -String $_.Type

            $TempObjectRepositoriesInfo = [PSCustomObject]@{
                Name = $_.Name
                AditionalInfo = $inobj
                IconType = $IconType
            }
            $ObjectRepositoriesInfo += $TempObjectRepositoriesInfo
        }
        return $ObjectRepositoriesInfo
    }
}


# Archive Object Repositories Graphviz Cluster
function Get-VbrArchObjectRepoInfo {
    param (
    )

    $ArchObjStorages = Get-VBRArchiveObjectStorageRepository | Sort-Object -Property Name
    if ($ArchObjStorages) {

        $ArchObjRepositoriesInfo = @()

        $ArchObjStorages | ForEach-Object {
            $inobj = @{
                Type = $_.ArchiveType
                Gateway = & {
                    if (-Not $_.UseGatewayServer) {
                        Switch ($_.GatewayMode) {
                            'Gateway' {
                                switch (($_.GatewayServer | Measure-Object).count) {
                                    0 { "Disable" }
                                    1 { $_.GatewayServer.Name.Split('.')[0] }
                                    Default { 'Automatic' }
                                }
                            }
                            'Direct' { 'Direct' }
                            default { 'Unknown' }
                        }
                    } else {
                        switch (($_.GatewayServer | Measure-Object).count) {
                            0 { "Disable" }
                            1 { $_.GatewayServer.Name.Split('.')[0] }
                            Default { 'Automatic' }
                        }
                    }
                }
            }

            $IconType = Get-IconType -String $_.ArchiveType

            $TempArchObjectRepositoriesInfo = [PSCustomObject]@{
                Name = $_.Name
                AditionalInfo = $inobj
                IconType = $IconType
            }
            $ArchObjRepositoriesInfo += $TempArchObjectRepositoriesInfo
        }
        return $ArchObjRepositoriesInfo
    }
}

# Scale-Out Backup Repository Graphviz Cluster
function Get-VbrSOBRInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Scale-Out Backup Repository information from $($VBRServer.Name)."
        $SOBR = Get-VBRBackupRepository -ScaleOut | Sort-Object -Property Name

        if ($SOBR) {

            $SOBRInfo = @()

            $SOBR | ForEach-Object {
                try {
                    $inobj = [ordered] @{
                        'Placement Policy' = $_.PolicyType
                        'Encryption Enabled' = switch ($_.EncryptionEnabled) {
                            "" { "--" }
                            $Null { "--" }
                            "True" { "Yes"; break }
                            "False" { "No"; break }
                            default { $_.EncryptionEnabled }
                        }
                    }

                    $TempSOBRInfo = [PSCustomObject]@{
                        Name = $_.Name
                        AditionalInfo = $inobj
                    }

                    $SOBRInfo += $TempSOBRInfo
                } catch {
                    Write-Verbose "Error: Unable to process $($_.Name) from SOBR table: $($_.Exception.Message)"
                }
            }
        }

        return $SOBRInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }

}

# Storage Infrastructure Graphviz Cluster
function Get-VbrSANInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Storage Infrastructure information from $($VBRServer.Name)."
        $SANHost = @()
        $SANHost += Get-NetAppHost | Select-Object -Property Name, @{ Name = 'Type'; Expression = { 'Netapp' } }
        $SANHost += Get-VBRIsilonHost | Select-Object -Property Name, @{ Name = 'Type'; Expression = { 'Dell' } }

        if ($SANHost) {

            $SANHostInfo = @()

            $SANHost | ForEach-Object {
                try {
                    $IconType = Get-IconType -String $_.Type
                    $inobj = [ordered] @{
                        'Type' = switch ($_.Type) {
                            "Netapp" { "NetApp Ontap" }
                            "Dell" { "Dell Isilon" }
                            default { 'Unknown' }
                        }
                    }

                    $TempSanInfo = [PSCustomObject]@{
                        Name = $_.Name
                        AditionalInfo = $inobj
                        IconType = $IconType
                    }

                    $SANHostInfo += $TempSanInfo
                } catch {
                    Write-Verbose "Error: Unable to process $($_.Name) from Storage Infrastructure table: $($_.Exception.Message)"
                }
            }
        }

        return $SANHostInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }
}

# Tape Servers Graphviz Cluster
function Get-VbrTapeServersInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Tape Servers information from $($VBRServer.Name)."
        $TapeServers = Get-VBRTapeServer | Sort-Object -Property Name

        if ($TapeServers) {

            $TapeServernfo = @()

            $TapeServers | ForEach-Object {
                $inobj = [ordered] @{
                    'Is Available' = switch ($_.IsAvailable) {
                        "" { "--" }
                        $Null { "--" }
                        "True" { "Yes"; break }
                        "False" { "No"; break }
                        default { $_.IsAvailable }
                    }
                }

                $TempTapeServernfo = [PSCustomObject]@{
                    Name = $_.Name.split('.')[0]
                    AditionalInfo = $inobj
                }

                $TapeServernfo += $TempTapeServernfo
            }
        }

        return $TapeServernfo

    } catch {
        Write-Verbose $_.Exception.Message
    }

}

# Tape Library Graphviz Cluster
function Get-VbrTapeLibraryInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Tape Library information from $($VBRServer.Name)."
        $TapeLibraries = Get-VBRTapeLibrary | Sort-Object -Property Name

        if ($TapeLibraries) {

            $TapeLibrariesInfo = @()

            $TapeLibraries | ForEach-Object {
                $inobj = [ordered] @{
                    'State' = $_.State
                    'Type' = $_.Type
                    'Model' = $_.Model
                }

                $TempTapeLibrariesInfo = [PSCustomObject]@{
                    Name = $_.Name
                    AditionalInfo = $inobj
                }

                $TapeLibrariesInfo += $TempTapeLibrariesInfo
            }
        }

        return $TapeLibrariesInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }

}

# Tape Library Graphviz Cluster
function Get-VbrTapeVaultInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Tape Vault information from $($VBRServer.Name)."
        $TapeVaults = Get-VBRTapeVault | Sort-Object -Property Name

        if ($TapeVaults) {

            $TapeVaultsInfo = @()

            $TapeVaults | ForEach-Object {
                $inobj = [ordered] @{
                    'Protect' = Switch ($_.Protect) {
                        'True' { 'Yes' }
                        'False' { 'No' }
                        default { 'Unknown' }
                    }
                }

                $TempTapeVaultsInfo = [PSCustomObject]@{
                    Name = $_.Name
                    AditionalInfo = $inobj
                }

                $TapeVaultsInfo += $TempTapeVaultsInfo
            }
        }

        return $TapeVaultsInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }
}

# Tape Library Graphviz Cluster
function Get-VbrServiceProviderInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Service Provider information from $($VBRServer.Name)."
        $ServiceProviders = Get-VBRCloudProvider | Sort-Object -Property 'DNSName'

        if ($ServiceProviders) {

            $ServiceProvidersInfo = @()

            $ServiceProviders | ForEach-Object {
                $inobj = [ordered] @{
                    'Cloud Connect Type' = & {
                        if ($_.ResourcesEnabled -and $_.ReplicationResourcesEnabled) {
                            'BaaS & DRaaS'
                        } elseif ($_.ResourcesEnabled) {
                            'BaaS'
                        } elseif ($_.ReplicationResourcesEnabled) {
                            'DRaas'
                        } elseif ($_.vCDReplicationResources) {
                            'vCD'
                        } else { 'Unknown' }
                    }
                    'Managed By Provider' = ConvertTo-TextYN $_.IsManagedByProvider
                }

                $TempServiceProvidersInfo = [PSCustomObject]@{
                    Name = $_.DNSName
                    AditionalInfo = $inobj
                }

                $ServiceProvidersInfo += $TempServiceProvidersInfo
            }
        }

        return $ServiceProvidersInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }
}

# SureBackup Virtual Lab Graphviz Cluster
function Get-VbrVirtualLabInfo {
    param (
    )
    try {
        Write-Verbose "Collecting VirtualLab information from $($VBRServer.Name)."
        $VirtualLab = Get-VBRVirtualLab

        if ($VirtualLab) {

            $VirtualLabInfo = @()

            $VirtualLab | ForEach-Object {
                $inobj = [ordered] @{
                    'Platform' = Switch ($_.Platform) {
                        'HyperV' { 'Microsoft Hyper-V' }
                        'VMWare' { 'VMWare vSphere' }
                        default { $_.Platform }
                    }
                    'Server' = $_.Server.Name
                }

                $IconType = Get-IconType -String 'VirtualLab'

                $TempVirtualLabInfo = [PSCustomObject]@{
                    Name = $_.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }

                $VirtualLabInfo += $TempVirtualLabInfo
            }
        }

        return $VirtualLabInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }
}

# SureBackup Application Groups Graphviz Cluster
function Get-VbrApplicationGroupsInfo {
    param (
    )
    try {
        Write-Verbose "Collecting Application Groups information from $($VBRServer.Name)."
        $ApplicationGroups = Get-VBRApplicationGroup

        if ($ApplicationGroups) {

            $ApplicationGroupsInfo = @()

            $ApplicationGroups | ForEach-Object {
                $inobj = [ordered] @{
                    'Machine Count' = ($_.VM | Measure-Object).Count
                }

                $IconType = Get-IconType -String 'ApplicationGroups'

                $TempApplicationGroupsInfo = [PSCustomObject]@{
                    Name = $_.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }

                $ApplicationGroupsInfo += $TempApplicationGroupsInfo
            }
        }

        return $ApplicationGroupsInfo

    } catch {
        Write-Verbose $_.Exception.Message
    }
}