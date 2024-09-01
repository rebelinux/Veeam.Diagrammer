function Get-DiagBackupServer {
    <#
    .SYNOPSIS
        Function to build Backup Server object.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.2
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
            SubGraph BackupServers -Attributes @{Label = 'Management'; labelloc = 'b'; labeljust = "r"; style = "rounded"; bgcolor = "#ceedc4"; fontcolor = '#696969'; fontsize = 14; penwidth = 2 } {
                SubGraph BackupServer -Attributes @{Label = 'Backup Server'; style = "rounded"; bgcolor = "#ceedc4"; fontsize = 18; fontcolor = '#005f4b'; penwidth = 0; labelloc = 't'; labeljust = "c"; } {
                    if (($DatabaseServerInfo.Name -ne $BackupServerInfo.Name) -and $EMServerInfo) {
                        Write-Verbose -Message "Collecting Backup Server, Database Server and Enterprise Manager Information."
                        $BSHASHTABLE = @{}
                        $DBHASHTABLE = @{}
                        $EMHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        $DatabaseServerInfo.psobject.properties | ForEach-Object { $DBHASHTABLE[$_.Name] = $_.Value }
                        $EMServerInfo.psobject.properties | ForEach-Object { $EMHASHTABLE[$_.Name] = $_.Value }

                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; fillColor = '#ceedc4'; shape = 'plain' }
                        Node $DatabaseServerInfo.Name -Attributes @{Label = $DBHASHTABLE.Label; fillColor = '#ceedc4'; shape = 'plain' }
                        Node $EMServerInfo.Name -Attributes @{Label = $EMHASHTABLE.Label; fillColor = '#ceedc4'; shape = 'plain' }

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

                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; fillColor = '#ceedc4'; shape = 'plain' }
                        Node $DatabaseServerInfo.Name -Attributes @{Label = $DBHASHTABLE.Label; fillColor = '#ceedc4'; shape = 'plain' }

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

                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; fillColor = '#ceedc4'; shape = 'plain' }
                        Node $EMServerInfo.Name -Attributes @{Label = $EMHASHTABLE.Label; fillColor = '#ceedc4'; shape = 'plain' }

                        if ($Dir -eq 'LR') {
                            Rank $EMServerInfo.Name, $BackupServerInfo.Name
                            Edge -From $EMServerInfo.Name -To $BackupServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; }
                        } else {
                            Rank $EMServerInfo.Name, $BackupServerInfo.Name
                            Edge -From $BackupServerInfo.Name -To $EMServerInfo.Name @{arrowtail = "normal"; arrowhead = "normal"; minlen = 3; }
                        }
                    } else {
                        Write-Verbose -Message "Database server colocated with Backup Server and no Enterprise Manager found: Collecting Backup Server Information."
                        $BSHASHTABLE = @{}
                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        Node Left @{Label = 'Left'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                        Node Leftt @{Label = 'Leftt'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                        Node Right @{Label = 'Right'; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                        Node $BackupServerInfo.Name -Attributes @{Label = $BSHASHTABLE.Label; fillColor = '#ceedc4'; shape = 'plain' }
                        Edge Left, Leftt, $BackupServerInfo.Name, Right @{style = $EdgeDebug.style; color = $EdgeDebug.color }
                        Rank Left, Leftt, $BackupServerInfo.Name, Right
                    }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}