function Get-VbrBackupServerInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication server information.
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
        try {
            $CimSession = New-CimSession $VBRServer.Name -Credential $Credential -Authentication Negotiate
            $PssSession = New-PSSession $VBRServer.Name -Credential $Credential -Authentication Negotiate
            Write-Verbose -Message "Collecting Backup Server information from $($VBRServer.Name)."
            try {
                $VeeamVersion = Invoke-Command -Session $PssSession -ErrorAction SilentlyContinue -ScriptBlock { get-childitem -recurse HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | get-itemproperty | Where-Object { $_.DisplayName  -match 'Veeam Backup & Replication Server' } | Select-Object -Property DisplayVersion }
            } catch {$_}
            try {
                $VeeamInfo = Invoke-Command -Session $PssSession -ErrorAction SilentlyContinue -ScriptBlock { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication' }
            } catch {$_}

            try {
                if ($VBRServer) {

                    $Rows = @{
                        Role = 'Backup Server'
                        IP = Get-NodeIP -HostName $VBRServer.Name
                    }

                    if ($VeeamVersion) {
                        $Rows.add('Version', $VeeamVersion.DisplayVersion)
                    }

                    $script:BackupServerInfo = [PSCustomObject]@{
                        Name = $VBRServer.Name.split(".")[0]
                        Label = Get-NodeIcon -Name "$($VBRServer.Name.split(".")[0])" -Type "VBR_Server" -Align "Center" -Rows $Rows
                    }
                }
            }
            catch {
                $_
            }

            try {
                $DatabaseServer = $VeeamInfo.SqlServerName
                if ($DatabaseServer) {
                    $DatabaseServerIP = Switch ((Resolve-DnsName $DatabaseServer).IPAddress) {
                        $Null {'Unknown'}
                        default {(Resolve-DnsName $DatabaseServer).IPAddress}
                    }

                    $Rows = @{
                        Role = 'Database Server'
                        IP = $DatabaseServerIP
                    }

                    if ($VeeamInfo.SqlInstanceName) {
                        $Rows.add('Instance', $VeeamInfo.SqlInstanceName)
                    }
                    if ($VeeamInfo.SqlDatabaseName) {
                        $Rows.add('Database', $VeeamInfo.SqlDatabaseName)
                    }

                    $script:DatabaseServerInfo = [PSCustomObject]@{
                        Name = $DatabaseServer.split(".")[0]
                        Label = Get-NodeIcon -Name "$($DatabaseServer.split(".")[0])" -Type "VBR_Server_DB" -Align "Center" -Rows $Rows
                        DBPort = "1433/TCP"
                    }
                }
            }
            catch {
                $_
            }
        }
        catch {
            $_
        }
    }
    end {
        Remove-CimSession $CimSession
        Remove-PSSession $PssSession
    }
}