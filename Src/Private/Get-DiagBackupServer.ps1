function Get-DiagBackupServer {
    <#
    .SYNOPSIS
        Function to build Backup Server object.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.8
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
            SubGraph BackupServers -Attributes @{Label = 'Management'; labelloc = 'b'; labeljust = "r"; style = "rounded"; bgcolor = $BackupServerBGColor; fontcolor = '#696969'; fontsize = 14; penwidth = 2; color = 'DarkGray' } {
                SubGraph BackupServer -Attributes @{Label = 'Backup Server'; style = "rounded"; bgcolor = $BackupServerBGColor; fontsize = 18; fontcolor = $BackupServerFontColor ; penwidth = 0; labelloc = 't'; labeljust = "c"; } {
                    if (( -Not $DatabaseServerInfo.Name ) -and ( -Not $EMServerInfo.Name )) {
                        Write-Verbose -Message "Collecting Backup Server Information."
                        $BSHASHTABLE = @{}
                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        Node Left @{Label = 'Left'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; }
                        Node Right @{Label = 'Right'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; }
                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; shape = 'plain' }
                        Edge Left, $BackupServerInfo.Name, Right @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                        Rank Left, $BackupServerInfo.Name, Right
                    } elseif (($DatabaseServerInfo.Name -ne $BackupServerInfo.Name) -and ($EMServerInfo.Name -ne $BackupServerInfo.Name )) {
                        Write-Verbose -Message "Collecting Backup Server, Database Server and Enterprise Manager Information."
                        $BSHASHTABLE = @{}
                        $DBHASHTABLE = @{}
                        $EMHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        $DatabaseServerInfo.psobject.properties | ForEach-Object { $DBHASHTABLE[$_.Name] = $_.Value }
                        $EMServerInfo.psobject.properties | ForEach-Object { $EMHASHTABLE[$_.Name] = $_.Value }

                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; shape = 'plain' }
                        Node $DatabaseServerInfo.Name -Attributes @{Label = $DBHASHTABLE.Label; shape = 'plain' }
                        Node $EMServerInfo.Name -Attributes @{Label = $EMHASHTABLE.Label; shape = 'plain' }

                        if ($Dir -eq 'LR') {
                            Rank $EMServerInfo.Name, $DatabaseServerInfo.Name
                            Edge -From $EMServerInfo.Name -To $BackupServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; }
                            Edge -From $DatabaseServerInfo.Name -To $BackupServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; xlabel = $DatabaseServerInfo.DBPort }
                        } else {
                            Rank $EMServerInfo.Name, $BackupServerInfo.Name, $DatabaseServerInfo.Name
                            Edge -From $EMServerInfo.Name -To $BackupServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; }
                            Edge -From $BackupServerInfo.Name -To $DatabaseServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; xlabel = $DatabaseServerInfo.DBPort }
                        }
                    } elseif (($DatabaseServerInfo.Name -ne $BackupServerInfo.Name) -and (-Not $EMServerInfo)) {
                        Write-Verbose -Message "Not Enterprise Manager Found: Collecting Backup Server and Database server Information."
                        $BSHASHTABLE = @{}
                        $DBHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        $DatabaseServerInfo.psobject.properties | ForEach-Object { $DBHASHTABLE[$_.Name] = $_.Value }

                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; shape = 'plain' }
                        Node $DatabaseServerInfo.Name -Attributes @{Label = $DBHASHTABLE.Label; shape = 'plain' }

                        if ($Dir -eq 'LR') {
                            Rank $BackupServerInfo.Name, $DatabaseServerInfo.Name
                            Edge -From $DatabaseServerInfo.Name -To $BackupServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; xlabel = $DatabaseServerInfo.DBPort }
                        } else {
                            Rank $BackupServerInfo.Name, $DatabaseServerInfo.Name
                            Edge -From $BackupServerInfo.Name -To $DatabaseServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; xlabel = $DatabaseServerInfo.DBPort }
                        }
                    } elseif (($EMServerInfo.Name -eq $BackupServerInfo.Name) -and ($DatabaseServerInfo.Name -eq $BackupServerInfo.Name)) {
                        Write-Verbose -Message "Database and Enterprise Maneger server colocated with Backup Server: Collecting Backup Server and Enterprise Manager Information."
                        $BSHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }

                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; shape = 'plain' }

                        Node Left @{Label = 'Left'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; }
                        Node Right @{Label = 'Right'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; }
                        Edge Left, $BackupServerInfo.Name, Right @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                        Rank Left, $BackupServerInfo.Name, Right

                    } elseif (($EMServerInfo.Name -eq $BackupServerInfo.Name) -and ($DatabaseServerInfo.Name -ne $BackupServerInfo.Name)) {
                        Write-Verbose -Message "Enterprise Maneger server colocated with Backup Server: Collecting Backup Server and Enterprise Manager Information."
                        $BSHASHTABLE = @{}
                        $DBHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        $DatabaseServerInfo.psobject.properties | ForEach-Object { $DBHASHTABLE[$_.Name] = $_.Value }

                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; shape = 'plain' }
                        Node $DatabaseServerInfo.Name -Attributes @{Label = $DBHASHTABLE.Label; shape = 'plain' }

                        if ($Dir -eq 'LR') {
                            Rank $BackupServerInfo.Name, $DatabaseServerInfo.Name
                            Edge -From $DatabaseServerInfo.Name -To $BackupServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; xlabel = $DatabaseServerInfo.DBPort }
                        } else {
                            Rank $BackupServerInfo.Name, $DatabaseServerInfo.Name
                            Edge -From $BackupServerInfo.Name -To $DatabaseServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; xlabel = $DatabaseServerInfo.DBPort }
                        }

                    } elseif ($EMServerInfo -and ($DatabaseServerInfo.Name -eq $BackupServerInfo.Name)) {
                        Write-Verbose -Message "Database server colocated with Backup Server: Collecting Backup Server and Enterprise Manager Information."
                        $BSHASHTABLE = @{}
                        $EMHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        $EMServerInfo.psobject.properties | ForEach-Object { $EMHASHTABLE[$_.Name] = $_.Value }

                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; shape = 'plain' }
                        Node $EMServerInfo.Name -Attributes @{Label = $EMHASHTABLE.Label; shape = 'plain' }

                        if ($Dir -eq 'LR') {
                            Rank $EMServerInfo.Name, $BackupServerInfo.Name
                            Edge -From $EMServerInfo.Name -To $BackupServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; }
                        } else {
                            Rank $EMServerInfo.Name, $BackupServerInfo.Name
                            Edge -From $BackupServerInfo.Name -To $EMServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; }
                        }
                    } else {
                        Write-Verbose -Message "Collecting Backup Server Information."
                        $BSHASHTABLE = @{}
                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        Node Left @{Label = 'Left'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; }
                        Node Right @{Label = 'Right'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; }
                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; shape = 'plain' }
                        Edge Left, $BackupServerInfo.Name, Right @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                        Rank Left, $BackupServerInfo.Name, Right
                    }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}