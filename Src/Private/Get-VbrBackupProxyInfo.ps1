function Get-VbrBackupProxyInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication backup proxy information.
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


    Param
    (
        # Backup Proxy Type
        [ValidateSet('vmware', 'hyperv', 'nas')]
        [string] $Type

    )
    process {
        Write-Verbose -Message "Collecting Backup Proxy information from $($VBRServer.Name)."
        try {
            $BPType = switch ($Type) {
                'vmware' { Get-VBRViProxy }
                'hyperv' { Get-VBRHvProxy }
                'nas' { Get-VBRNASProxyServer }

            }
            $BackupProxies = $BPType
            $BackupProxyInfo = @()
            if ($BackupProxies) {
                foreach ($BackupProxy in $BackupProxies) {

                    # $Role = Get-RoleType -String $Type

                    $Hostname = Switch ($Type) {
                        'vmware' { $BackupProxy.Host.Name }
                        'hyperv' { $BackupProxy.Host.Name }
                        'nas' { $BackupProxy.Server.Name }
                    }

                    $Status = Switch ($Type) {
                        'vmware' {
                            Switch ($BackupProxy.isDisabled) {
                                $false { 'Enabled' }
                                $true { 'Disabled' }
                            }
                        }
                        'hyperv' {
                            Switch ($BackupProxy.isDisabled) {
                                $false { 'Enabled' }
                                $true { 'Disabled' }
                            }
                        }
                        'nas' {
                            Switch ($BackupProxy.IsEnabled) {
                                $false { 'Disabled' }
                                $true { 'Enabled' }
                            }
                        }
                    }

                    $BPRows = [ordered]@{
                        IP = Get-NodeIP -HostName $Hostname
                        Status = $Status
                        Type = Switch ($Type) {
                            'vmware' { $BackupProxy.Host.Type }
                            'hyperv' {
                                Switch ($BackupProxy.Info.Type) {
                                    'HvOffhost' { "Off-Host Backup" }
                                    'HvOnhost' { "On-Host Backup" }
                                }
                            }
                            'nas' { "File Backup" }
                        }
                        Concurrent_Tasks = Switch ($Type) {
                            'vmware' { $BackupProxy.MaxTasksCount }
                            'hyperv' { $BackupProxy.MaxTasksCount }
                            'nas' { $BackupProxy.ConcurrentTaskNumber }
                        }
                    }

                    $IconType = Switch ($Type) {
                        'vmware' { "VBR_Proxy_Server" }
                        'hyperv' { "VBR_Proxy_Server" }
                        'nas' { "VBR_AGENT_Server" }
                    }

                    $TempBackupProxyInfo = [PSCustomObject]@{
                        Name = "$($Hostname.toUpper().split(".")[0])"
                        Label = Add-DiaNodeIcon -Name "$($Hostname.toUpper().split(".")[0])" -IconType $IconType -Align "Center" -Rows $BPRows -ImagesObj $Images -IconDebug $IconDebug -fontSize 18
                        AditionalInfo = $BPRows
                    }

                    $BackupProxyInfo += $TempBackupProxyInfo
                }
            }

            return $BackupProxyInfo
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}