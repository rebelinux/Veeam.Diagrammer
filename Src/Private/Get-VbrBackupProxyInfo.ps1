function Get-VbrBackupProxyInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication backup proxy information.
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
        # Backup Proxy Type
        [ValidateSet('vmware', 'hyperv')]
        [string] $Type

    )
    process {
        Write-Verbose -Message "Collecting Backup Proxy information from $($VBRServer.Name)."
        try {
            $BPType = switch ($Type) {
                'vmware' {Get-VBRViProxy}
                'hyperv' {Get-VBRHvProxy}
            }
            $BackupProxies = $BPType
            $BackupProxyInfo = @()
            if ($BackupProxies) {
                foreach ($BackupProxy in $BackupProxies) {
                    try {
                        $BackupProxyIP = Switch ((Resolve-DnsName $BackupProxy.Host.Name -ErrorAction SilentlyContinue).IPAddress) {
                            $Null {'Unknown'}
                            default {(Resolve-DnsName $BackupProxy.Host.Name -ErrorAction SilentlyContinue).IPAddress}
                        }
                    }
                    catch {
                        $_
                    }

                    $TempBackupProxyInfo = [PSCustomObject]@{
                        Name = "$($BackupProxy.Host.Name.toUpper().split(".")[0]) (BP)";
                        Role = "Backup Proxy";
                        IP = $BackupProxyIP;
                        Align = "Center";
                        Type = "VBR_Proxy_Server"
                    }
                    $BackupProxyInfo += $TempBackupProxyInfo
                }
            }

            return $BackupProxyInfo
        }
        catch {
            $_
        }
    }
    end {}
}