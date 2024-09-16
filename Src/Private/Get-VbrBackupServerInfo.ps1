function Get-VbrBackupServerInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication server information.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.0
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
            $CimSession = try { New-CimSession $VBRServer.Name -Credential $Credential -Authentication Negotiate -Name 'CIMBackupServerDiagram' -ErrorAction Stop } catch { Write-Verbose "Backup Server Section: New-CimSession: Unable to connect to $($VBRServer.Name): $($_.Exception.MessageId)" }

            $PssSession = try { New-PSSession $VBRServer.Name -Credential $Credential -Authentication Negotiate -ErrorAction Stop -Name 'PSSBackupServerDiagram' } catch {
                if (-Not $_.Exception.MessageId) {
                    $ErrorMessage = $_.FullyQualifiedErrorId
                } else { $ErrorMessage = $_.Exception.MessageId }
                Write-Verbose "Backup Server Section: New-PSSession: Unable to connect to $($VBRServer.Name): $ErrorMessage"
            }
            Write-Verbose -Message "Collecting Backup Server information from $($VBRServer.Name)."
            try {
                $VeeamVersion = Invoke-Command -Session $PssSession -ErrorAction SilentlyContinue -ScriptBlock { Get-ChildItem -Recurse HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -match 'Veeam Backup & Replication Server' } | Select-Object -Property DisplayVersion }
            } catch { $_ }
            try {
                $VeeamDBFlavor = Invoke-Command -Session $PssSession -ErrorAction SilentlyContinue -ScriptBlock { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication\DatabaseConfigurations' }
            } catch { $_ }
            try {
                $VeeamDBInfo12 = Invoke-Command -Session $PssSession -ErrorAction SilentlyContinue -ScriptBlock { Get-ItemProperty -Path "HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication\DatabaseConfigurations\$(($Using:VeeamDBFlavor).SqlActiveConfiguration)" }
            } catch { $_ }
            try {
                $VeeamDBInfo11 = Invoke-Command -Session $PssSession -ErrorAction SilentlyContinue -ScriptBlock { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication' }
            } catch { $_ }

            if ($VeeamDBInfo11.SqlServerName) {
                $VeeamDBInfo = $VeeamDBInfo11.SqlServerName
            } elseif ($VeeamDBInfo12.SqlServerName) {
                $VeeamDBInfo = $VeeamDBInfo12.SqlServerName
            } elseif ($VeeamDBInfo12.SqlHostName) {
                $VeeamDBInfo = Switch ($VeeamDBInfo12.SqlHostName) {
                    'localhost' { $VBRServer.Name }
                    default { $VeeamDBInfo12.SqlHostName }
                }
            } else {
                $VeeamDBInfo = $VBRServer.Name
            }

            try {
                if ($VBRServer) {

                    if ($VeeamDBInfo -eq $VBRServer.Name) {
                        $Roles = 'Backup and Database'
                        $DBType = $VeeamDBFlavor.SqlActiveConfiguration
                    } else {
                        $Roles = 'Backup Server'
                    }

                    $Rows = @{
                        Role = $Roles
                        IP = Get-NodeIP -Hostname $VBRServer.Name
                    }

                    if ($VeeamVersion) {
                        $Rows.add('Version', $VeeamVersion.DisplayVersion)
                    }

                    if ($VeeamDBInfo -eq $VBRServer.Name) {
                        $Rows.add('DB Type', $DBType)
                    }

                    $script:BackupServerInfo = [PSCustomObject]@{
                        Name = $VBRServer.Name.split(".")[0]
                        Label = Get-DiaNodeIcon -Name "$($VBRServer.Name.split(".")[0])" -IconType "VBR_Server" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                    }
                }
            } catch {
                $_
            }
            try {
                $DatabaseServer = $VeeamDBInfo
                if ($VeeamDBFlavor.SqlActiveConfiguration -eq "PostgreSql") {
                    $DBPort = "$($VeeamDBInfo12.SqlHostPort)/TCP"
                } else {
                    $DBPort = "1433/TCP"
                }

                if ($DatabaseServer) {
                    $DatabaseServerIP = Get-NodeIP -Hostname $DatabaseServer

                    $Rows = @{
                        Role = 'Database Server'
                        IP = $DatabaseServerIP
                    }

                    if ($VeeamDBInfo.SqlInstanceName) {
                        $Rows.add('Instance', $VeeamDBInfo.SqlInstanceName)
                    }
                    if ($VeeamDBInfo.SqlDatabaseName) {
                        $Rows.add('Database', $VeeamDBInfo.SqlDatabaseName)
                    }

                    if ($VeeamDBFlavor.SqlActiveConfiguration -eq "PostgreSql") {
                        $DBIconType = "VBR_Server_DB_PG"
                    } else {
                        $DBIconType = "VBR_Server_DB"
                    }

                    $script:DatabaseServerInfo = [PSCustomObject]@{
                        Name = $DatabaseServer.split(".")[0]
                        Label = Get-DiaNodeIcon -Name "$($DatabaseServer.split(".")[0])" -IconType $DBIconType -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                        DBPort = $DBPort
                    }
                }
            } catch {
                $_
            }

            try {
                $EMServer = [Veeam.Backup.Core.SBackupOptions]::GetEnterpriseServerInfo()
                if ($EMServer.ServerName) {
                    $EMServerIP = Get-NodeIP -Hostname $EMServer.ServerName

                    $Rows = @{
                        Role = 'Enterprise Manager Server'
                        IP = $EMServerIP
                    }

                    $script:EMServerInfo = [PSCustomObject]@{
                        Name = $EMServer.ServerName.split(".")[0]
                        Label = Get-DiaNodeIcon -Name "$($EMServer.ServerName.split(".")[0])" -IconType "VBR_Server_EM" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug
                    }
                }
            } catch {
                $_
            }
        } catch {
            $_
        }
    }
    end {
        Remove-CimSession $CimSession
        Remove-PSSession $PssSession
    }
}