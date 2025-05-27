function Get-VbrBackupServerInfo {
    <#
    .SYNOPSIS
        Function to extract veeam backup & replication server information.
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

    Param
    (

    )
    process {
        try {
            $PssSession = try { New-PSSession $VBRServer.Name -Credential $Credential -Authentication Negotiate -ErrorAction Stop -Name 'PSSBackupServerDiagram'} catch {
            Write-Error "Veeam.Diagrammer: New-PSSession: Unable to connect to $($VBRServer.Name), WinRM disabled or not configured."
            }
            Write-Verbose -Message "Collecting Backup Server information from $($VBRServer.Name)."

            if ($PssSession) {
                $VeeamInfo = Invoke-Command -Session $PssSession -ErrorAction SilentlyContinue -ScriptBlock {
                    $VeeamVersion = Get-ChildItem -Recurse HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -match 'Veeam Backup & Replication Server' } | Select-Object -Property DisplayVersion
                    $VeeamDBFlavor = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication\DatabaseConfigurations'
                    $VeeamDBInfo12 = Get-ItemProperty -Path "HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication\DatabaseConfigurations\$($VeeamDBFlavor.SqlActiveConfiguration)"
                    $VeeamDBInfo11 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication'
                    return [PSCustomObject]@{
                        Version = $VeeamVersion.DisplayVersion
                        DBFlavor = $VeeamDBFlavor
                        DBInfo12 = $VeeamDBInfo12
                        DBInfo11 = $VeeamDBInfo11
                    }
                }
            }

            $VeeamDBInfo = if ($VeeamInfo.DBInfo11.SqlServerName) {
                $VeeamInfo.DBInfo11.SqlServerName
            } elseif ($VeeamInfo.DBInfo12.SqlServerName) {
                $VeeamInfo.DBInfo12.SqlServerName
            } elseif ($VeeamInfo.DBInfo12.SqlHostName) {
                Switch ($VeeamInfo.DBInfo12.SqlHostName) {
                    'localhost' { $VBRServer.Name }
                    default { $VeeamInfo.DBInfo12.SqlHostName }
                }
            } else {
                $VBRServer.Name
            }

            if ($VBRServer) {
                $Roles = if ($VeeamDBInfo -eq $VBRServer.Name) { 'Backup and Database' } else { 'Backup Server' }
                $DBType = $VeeamInfo.DBFlavor.SqlActiveConfiguration

                $Rows = [ordered]@{
                    Role = $Roles
                    IP = Get-NodeIP -Hostname $VBRServer.Name
                }

                if ($VeeamInfo.Version) {
                    $Rows.add('Version', $VeeamInfo.Version)
                }

                if ($DBType) {
                    $Rows.add('Database Type', $DBType)
                }

                $Rows = [PSCustomObject]$Rows

                $script:BackupServerInfo = [PSCustomObject]@{
                    Name = $VBRServer.Name.split(".")[0]
                    Label = Add-DiaNodeIcon -Name "$($VBRServer.Name.split(".")[0])" -IconType "VBR_Server" -Align "Center" -RowsOrdered $Rows -ImagesObj $Images -IconDebug $IconDebug -FontSize 18
                    Spacer = Add-DiaNodeIcon -Name " " -IconType "VBR_Bid_Arrow" -Align "Center" -ImagesObj $Images -IconDebug $IconDebug
                }
            }

            $DatabaseServer = $VeeamDBInfo
            if ($DatabaseServer) {
                $DBPort = if ($VeeamInfo.DBFlavor.SqlActiveConfiguration -eq "PostgreSql") { "$($VeeamInfo.DBInfo12.SqlHostPort)/TCP" } else { "1433/TCP" }
                $DatabaseServerIP = Get-NodeIP -Hostname $DatabaseServer

                $Rows = [ordered] @{
                    IP = $DatabaseServerIP
                    Role = 'Database Server'
                }

                if ($VeeamInfo.DBInfo12.SqlInstanceName) {
                    $Rows.add('Instance', $VeeamInfo.DBInfo12.SqlInstanceName)
                }

                if ($VeeamInfo.DBInfo12.SqlDatabaseName) {
                    $Rows.add('Database', $VeeamInfo.DBInfo12.SqlDatabaseName)
                }

                $Rows.add('DB Port', $DBPort)


                $Rows = [PSCustomObject]$Rows

                $DBIconType = if ($VeeamInfo.DBFlavor.SqlActiveConfiguration -eq "PostgreSql") { "VBR_Server_DB_PG" } else { "VBR_Server_DB" }

                $script:DatabaseServerInfo = [PSCustomObject]@{
                    Name = $DatabaseServer.split(".")[0]
                    Label = Add-DiaNodeIcon -Name "$($DatabaseServer.split(".")[0])" -IconType $DBIconType -Align "Center" -RowsOrdered $Rows -ImagesObj $Images -IconDebug $IconDebug -FontSize 18
                    DBPort = $DBPort
                }
            }

            $EMServer = [Veeam.Backup.Core.SBackupOptions]::GetEnterpriseServerInfo()
            if ($EMServer.ServerName) {
                $EMServerIP = Get-NodeIP -Hostname $EMServer.ServerName

                $Rows = @{
                    Role = 'Enterprise Manager Server'
                    IP = $EMServerIP
                }

                $script:EMServerInfo = [PSCustomObject]@{
                    Name = $EMServer.ServerName.split(".")[0]
                    Label = Add-DiaNodeIcon -Name "$($EMServer.ServerName.split(".")[0])" -IconType "VBR_Server_EM" -Align "Center" -Rows $Rows -ImagesObj $Images -IconDebug $IconDebug -FontSize 18
                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {
        if ($PssSession) {
            Remove-PSSession $PssSession
        }
    }
}
