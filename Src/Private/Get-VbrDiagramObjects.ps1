# Proxy Graphviz Cluster
function Get-VbrProxyInfo {
    param ()
    try {
        Write-Verbose "Collecting Proxy information from $($VBRServer.Name)."
        $Proxies = @(Get-VBRViProxy) + @(Get-VBRHvProxy)

        if ($Proxies) {
            $ProxiesInfo = $Proxies | ForEach-Object {
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

                [PSCustomObject] @{
                    Name = $_.Host.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }
            }
        }

        return $ProxiesInfo

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Nas Proxy Graphviz Cluster
function Get-VbrNASProxyInfo {
    param ()
    try {
        Write-Verbose "Collecting NAS Proxy information from $($VBRServer.Name)."
        $Proxies = Get-VBRNASProxyServer

        if ($Proxies) {
            $ProxiesInfo = $Proxies | ForEach-Object {
                $inobj = [ordered] @{
                    'Enabled' = if ($_.IsEnabled) { 'Yes' } else { 'No' }
                    'Max Tasks' = $_.ConcurrentTaskNumber
                }

                $IconType = Get-IconType -String 'ProxyServer'

                [PSCustomObject] @{
                    Name = $_.Server.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }
            }
        }

        return $ProxiesInfo

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Wan Accel Graphviz Cluster
function Get-VbrWanAccelInfo {
    param ()
    try {
        Write-Verbose "Collecting Wan Accel information from $($VBRServer.Name)."
        $WanAccels = Get-VBRWANAccelerator

        if ($WanAccels) {
            $WanAccelsInfo = $WanAccels | ForEach-Object {
                $inobj = [ordered] @{
                    'CacheSize' = "$($_.FindWaHostComp().Options.MaxCacheSize) $($_.FindWaHostComp().Options.SizeUnit)"
                    'TrafficPort' = "$($_.GetWaTrafficPort())/TCP"
                }

                [PSCustomObject] @{
                    Name = $_.Name
                    AditionalInfo = $inobj
                }
            }
        }

        return $WanAccelsInfo

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Repositories Graphviz Cluster
function Get-VbrRepositoryInfo {
    param ()
    try {
        Write-Verbose "Collecting Repository information from $($VBRServer.Name)."
        $Repositories = Get-VBRBackupRepository | Where-Object { $_.Type -notin @("SanSnapshotOnly", "AmazonS3Compatible", "WasabiS3", "SmartObjectS3") } | Sort-Object -Property Name
        $ScaleOuts = Get-VBRBackupRepository -ScaleOut | Sort-Object -Property Name

        if ($ScaleOuts) {
            $Extents = Get-VBRRepositoryExtent -Repository $ScaleOuts | Sort-Object -Property Name
            $Repositories += $Extents.Repository
        }

        if ($Repositories) {
            $RepositoriesInfo = $Repositories | ForEach-Object {
                $Role = Get-RoleType -String $_.Type

                $Rows = [ordered] @{
                    'Server' = if ($_.Host.Name) { $_.Host.Name.Split('.')[0] } else { 'N/A' }
                    'Repo Type' = $Role
                    'Total Space' = (ConvertTo-FileSizeString -Size $_.GetContainer().CachedTotalSpace.InBytesAsUInt64)
                    'Used Space' = (ConvertTo-FileSizeString -Size $_.GetContainer().CachedFreeSpace.InBytesAsUInt64)
                }

                $BackupType = if (($Role -ne 'Dedup Appliances') -and ($Role -ne 'SAN') -and ($_.Host.Name -in $ViBackupProxy.Host.Name -or $_.Host.Name -in $HvBackupProxy.Host.Name)) {
                    'Proxy'
                } else { $_.Type }

                $IconType = Get-IconType -String $BackupType

                [PSCustomObject] @{
                    Name = "$((Remove-SpecialChar -String $_.Name -SpecialChars '\').toUpper()) "
                    AditionalInfo = $Rows
                    IconType = $IconType
                }
            }

            return $RepositoriesInfo
        }

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Object Repositories Graphviz Cluster
function Get-VbrObjectRepoInfo {
    param ()
    try {
        Write-Verbose "Collecting Object Repository information from $($VBRServer.Name)."
        $ObjectRepositories = Get-VBRObjectStorageRepository
        if ($ObjectRepositories) {
            $ObjectRepositoriesInfo = $ObjectRepositories | ForEach-Object {
                $inobj = [ordered] @{
                    'Type' = $_.Type
                    'Folder' = if ($_.AmazonS3Folder) {
                        $_.AmazonS3Folder
                    } elseif ($_.AzureBlobFolder) {
                        $_.AzureBlobFolder
                    } else { 'Unknown' }
                    'Gateway' = if (-Not $_.UseGatewayServer) {
                        switch ($_.ConnectionType) {
                            'Gateway' {
                                switch (($_.GatewayServer | Measure-Object).Count) {
                                    0 { "Disable" }
                                    1 { $_.GatewayServer.Name.Split('.')[0] }
                                    default { 'Automatic' }
                                }
                            }
                            'Direct' { 'Direct' }
                            default { 'Unknown' }
                        }
                    } else {
                        switch (($_.GatewayServer | Measure-Object).Count) {
                            0 { "Disable" }
                            1 { $_.GatewayServer.Name.Split('.')[0] }
                            default { 'Automatic' }
                        }
                    }
                }

                $IconType = Get-IconType -String $_.Type

                [PSCustomObject] @{
                    Name = $_.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }
            }
            return $ObjectRepositoriesInfo
        }
    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Archive Object Repositories Graphviz Cluster
function Get-VbrArchObjectRepoInfo {
    param ()
    try {
        Write-Verbose "Collecting Archive Object Repository information from $($VBRServer.Name)."
        $ArchObjStorages = Get-VBRArchiveObjectStorageRepository | Sort-Object -Property Name
        if ($ArchObjStorages) {
            $ArchObjRepositoriesInfo = $ArchObjStorages | ForEach-Object {
                $inobj = [ordered] @{
                    'Type' = $_.ArchiveType
                    'Gateway' = if (-Not $_.UseGatewayServer) {
                        switch ($_.GatewayMode) {
                            'Gateway' {
                                switch (($_.GatewayServer | Measure-Object).Count) {
                                    0 { "Disable" }
                                    1 { $_.GatewayServer.Name.Split('.')[0] }
                                    default { 'Automatic' }
                                }
                            }
                            'Direct' { 'Direct' }
                            default { 'Unknown' }
                        }
                    } else {
                        switch (($_.GatewayServer | Measure-Object).Count) {
                            0 { "Disable" }
                            1 { $_.GatewayServer.Name.Split('.')[0] }
                            default { 'Automatic' }
                        }
                    }
                }

                $IconType = Get-IconType -String $_.ArchiveType

                [PSCustomObject] @{
                    Name = $_.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }
            }
            return $ArchObjRepositoriesInfo
        }
    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Scale-Out Backup Repository Graphviz Cluster
function Get-VbrSOBRInfo {
    param ()
    try {
        Write-Verbose "Collecting Scale-Out Backup Repository information from $($VBRServer.Name)."
        $SOBR = Get-VBRBackupRepository -ScaleOut | Sort-Object -Property Name

        if ($SOBR) {
            $SOBRInfo = $SOBR | ForEach-Object {
                $inobj = [ordered] @{
                    'Placement Policy' = $_.PolicyType
                    'Encryption Enabled' = if ($_.EncryptionEnabled) { 'Yes' } else { 'No' }
                }

                [PSCustomObject] @{
                    Name = $_.Name
                    AditionalInfo = $inobj
                }
            }
            return $SOBRInfo
        }
    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Storage Infrastructure Graphviz Cluster
function Get-VbrSANInfo {
    param ()
    try {
        Write-Verbose "Collecting Storage Infrastructure information from $($VBRServer.Name)."
        $SANHost = @(
            Get-NetAppHost | Select-Object -Property Name, @{ Name = 'Type'; Expression = { 'Netapp' } }
            Get-VBRIsilonHost | Select-Object -Property Name, @{ Name = 'Type'; Expression = { 'Dell' } }
        )

        if ($SANHost) {
            $SANHostInfo = $SANHost | ForEach-Object {
                try {
                    $IconType = Get-IconType -String $_.Type
                    $inobj = [ordered] @{
                        'Type' = switch ($_.Type) {
                            "Netapp" { "NetApp Ontap" }
                            "Dell" { "Dell Isilon" }
                            default { 'Unknown' }
                        }
                    }

                    [PSCustomObject] @{
                        Name = $_.Name
                        AditionalInfo = $inobj
                        IconType = $IconType
                    }
                } catch {
                    Write-Verbose "Error: Unable to process $($_.Name) from Storage Infrastructure table: $($_.Exception.Message)"
                }
            }
        }

        return $SANHostInfo

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Tape Servers Graphviz Cluster
function Get-VbrTapeServersInfo {
    param ()
    try {
        Write-Verbose "Collecting Tape Servers information from $($VBRServer.Name)."
        $TapeServers = Get-VBRTapeServer | Sort-Object -Property Name

        if ($TapeServers) {
            $TapeServersInfo = $TapeServers | ForEach-Object {
                $inobj = [ordered] @{
                    'Is Available' = if ($_.IsAvailable) { "Yes" } elseif (-Not $_.IsAvailable) { "No" } else { "--" }
                }

                [PSCustomObject] @{
                    Name = $_.Name.split('.')[0]
                    AditionalInfo = $inobj
                }
            }
            return $TapeServersInfo
        }

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Tape Library Graphviz Cluster
function Get-VbrTapeLibraryInfo {
    param ()
    try {
        Write-Verbose "Collecting Tape Library information from $($VBRServer.Name)."
        $TapeLibraries = Get-VBRTapeLibrary | Sort-Object -Property Name

        if ($TapeLibraries) {
            $TapeLibrariesInfo = $TapeLibraries | ForEach-Object {
                [PSCustomObject] @{
                    Name = $_.Name
                    AditionalInfo = [ordered] @{
                        'State' = $_.State
                        'Type' = $_.Type
                        'Model' = $_.Model
                    }
                }
            }
            return $TapeLibrariesInfo
        }

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Tape Library Graphviz Cluster
function Get-VbrTapeVaultInfo {
    param ()
    try {
        Write-Verbose "Collecting Tape Vault information from $($VBRServer.Name)."
        $TapeVaults = Get-VBRTapeVault | Sort-Object -Property Name

        if ($TapeVaults) {
            $TapeVaultsInfo = $TapeVaults | ForEach-Object {
                [PSCustomObject] @{
                    Name = $_.Name
                    AditionalInfo = [ordered] @{
                        'Protect' = if ($_.Protect) { 'Yes' } else { 'No' }
                    }
                }
            }
            return $TapeVaultsInfo
        }

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# Service Provider Graphviz Cluster
function Get-VbrServiceProviderInfo {
    param ()
    try {
        Write-Verbose "Collecting Service Provider information from $($VBRServer.Name)."
        $ServiceProviders = Get-VBRCloudProvider | Sort-Object -Property 'DNSName'

        if ($ServiceProviders) {
            $ServiceProvidersInfo = $ServiceProviders | ForEach-Object {
                $cloudConnectType = if ($_.ResourcesEnabled -and $_.ReplicationResourcesEnabled) {
                    'BaaS and DRaaS'
                } elseif ($_.ResourcesEnabled) {
                    'BaaS'
                } elseif ($_.ReplicationResourcesEnabled) {
                    'DRaas'
                } elseif ($_.vCDReplicationResources) {
                    'vCD'
                } else { 'Unknown' }

                $inobj = [ordered] @{
                    'Cloud Connect Type' = $cloudConnectType
                    'Managed By Provider' = ConvertTo-TextYN $_.IsManagedByProvider
                }

                [PSCustomObject] @{
                    Name = $_.DNSName
                    AditionalInfo = $inobj
                }
            }
            return $ServiceProvidersInfo
        }

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# SureBackup Virtual Lab Graphviz Cluster
function Get-VbrVirtualLabInfo {
    param ()
    try {
        Write-Verbose "Collecting VirtualLab information from $($VBRServer.Name)."
        $VirtualLab = Get-VBRVirtualLab

        if ($VirtualLab) {
            $VirtualLabInfo = $VirtualLab | ForEach-Object {
                $inobj = [ordered] @{
                    'Platform' = Switch ($_.Platform) {
                        'HyperV' { 'Microsoft Hyper-V' }
                        'VMWare' { 'VMWare vSphere' }
                        default { $_.Platform }
                    }
                    'Server' = $_.Server.Name
                }

                $IconType = Get-IconType -String 'VirtualLab'

                [PSCustomObject] @{
                    Name = $_.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }
            }
            return $VirtualLabInfo
        }

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}

# SureBackup Application Groups Graphviz Cluster
function Get-VbrApplicationGroupsInfo {
    param ()
    try {
        Write-Verbose "Collecting Application Groups information from $($VBRServer.Name)."
        $ApplicationGroups = Get-VBRApplicationGroup

        if ($ApplicationGroups) {
            $ApplicationGroupsInfo = $ApplicationGroups | ForEach-Object {
                $inobj = [ordered] @{
                    'Machine Count' = ($_.VM | Measure-Object).Count
                }

                $IconType = Get-IconType -String 'ApplicationGroups'

                [PSCustomObject] @{
                    Name = $_.Name
                    AditionalInfo = $inobj
                    IconType = $IconType
                }
            }
            return $ApplicationGroupsInfo
        }

    } catch {
        Write-Verbose -Message $_.Exception.Message
    }
}
