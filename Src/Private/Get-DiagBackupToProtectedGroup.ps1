function Get-DiagBackupToProtectedGroup {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Protected Group diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.1
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

    begin {
        # Get Veeam Backup Server Object
        Get-DiagBackupServer
    }

    process {
        try {
            $ProtectedGroups = Get-VbrBackupProtectedGroupInfo
            $ADContainer = $ProtectedGroups | Where-Object { $_.Container -eq 'ActiveDirectory' }
            $ManualContainer = $ProtectedGroups | Where-Object { $_.Container -eq 'ManuallyDeployed' }
            $IndividualContainer = $ProtectedGroups | Where-Object { $_.Container -eq 'IndividualComputers' }
            $CSVContainer = $ProtectedGroups | Where-Object { $_.Container -eq 'CSV' }

            try {
                $FileBackupProxy = Get-VbrBackupProxyInfo -Type 'nas'
                if ($BackupServerInfo) {
                    if ($FileBackupProxy) {
                        $ProxiesAttr = @{
                            Label = 'File Backup Proxies'
                            fontsize = 18
                            penwidth = 1.5
                            labelloc = 't'
                            color = $SubGraphDebug.color
                            style = 'dashed,rounded'
                        }
                        SubGraph MainSubGraphFileProxy -Attributes $ProxiesAttr -ScriptBlock {
                            # Dummy Node used for subgraph centering
                            # Node DummyFileProxy @{Label = $DiagramDummyLabel; fontsize = 18; fontname = "Segoe Ui Black"; fontcolor = '#005f4b'; shape = 'plain' }
                            Node DummyFileProxyToPG @{Label = "DummyFileProxyToPG"; style = $EdgeDebug.style; color = $EdgeDebug.color; shape = 'plain'; fillColor = 'transparent' }
                            foreach ($ProxyObj in $FileBackupProxy) {
                                $PROXYHASHTABLE = @{}
                                $ProxyObj.psobject.properties | ForEach-Object { $PROXYHASHTABLE[$_.Name] = $_.Value }
                                Node $ProxyObj -NodeScript { $_.Name } @{Label = $PROXYHASHTABLE.Label; fontname = "Segoe Ui" }
                                Edge -From MainSubGraphFileProxy:s -To $ProxyObj.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                Edge -From $ProxyObj.Name -To DummyFileProxyToPG @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }

                            }
                            Rank $FileBackupProxy.Name
                        }

                        if ($Dir -eq 'LR') {
                            Edge $BackupServerInfo.Name -To MainSubGraphFileProxy @{lhead = 'clusterMainSubGraph'; minlen = 3 }
                        } else {
                            Edge $BackupServerInfo.Name -To MainSubGraphFileProxy @{lhead = 'clusterMainSubGraph'; minlen = 3 }
                        }
                    }
                }
            } catch {
                $_
            }

            if ($ProtectedGroups.Container) {
                if ($Dir -eq 'LR') {
                    $DiagramLabel = 'Protected Groups'
                    $DiagramDummyLabel = ' '
                } else {
                    $DiagramLabel = ' '
                    $DiagramDummyLabel = 'Protected Groups'
                }

                if ($ProtectedGroups) {
                    SubGraph MainSubGraph -Attributes @{Label = $DiagramLabel; fontsize = 22; penwidth = 1; labelloc = 't'; style = 'dashed,rounded'; color = $SubGraphDebug.color } {
                        if ($ADContainer) {
                            SubGraph ADContainer -Attributes @{Label = (Get-DiaHTMLLabel -Label 'Active Directory Computers' -IconType "VBR_AGENT_AD_Logo" -ImagesObj $Images -IconDebug $IconDebug -SubgraphLabel); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                # Node used for subgraph centering
                                Node DummyADContainer @{Label = 'DummyADC'; style = $SubGraphDebug.style; color = $SubGraphDebug.color; shape = 'plain' }
                                if (($ADContainer | Measure-Object).count -le 2) {
                                    foreach ($PGOBJ in ($ADContainer | Sort-Object -Property Name)) {
                                        $PGHASHTABLE = @{}
                                        $PGOBJ.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }

                                        $Ous = @()

                                        $Status = Switch ($PGOBJ.Object.Enabled) {
                                            $true { 'Enabled' }
                                            $false { 'Disabled' }
                                            default { 'Unknown' }
                                        }

                                        $Ous += $PGOBJ.Object.Container.Entity | ForEach-Object {
                                            "<B>OUs</B> : $($_.DistinguishedName)"
                                        }
                                        $Rows = @(
                                            "<B>Type</B>: $($PGOBJ.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($PGOBJ.Object.ScheduleOptions.PolicyType)"
                                            "<B>Domain</B> : $($PGOBJ.Object.Container.Domain) <B>Distribution Server</B> : $($PGOBJ.Object.DeploymentOptions.DistributionServer.Name)"
                                            $Ous
                                        )

                                        Convert-DiaTableToHTML -Label $PGOBJ.Name -Name $PGOBJ.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug

                                        Edge -From DummyADContainer -To $PGOBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    }
                                } else {
                                    $Group = Split-array -inArray ($ADContainer | Sort-Object -Property Name) -size 2
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ADGroup$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $PGHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }

                                                $Status = Switch ($_.Object.Enabled) {
                                                    $true { 'Enabled' }
                                                    $false { 'Disabled' }
                                                    default { 'Unknown' }
                                                }

                                                $Ous = @()
                                                $Ous += $_.Object.Container.Entity | ForEach-Object {
                                                    "<B>OUs</B> : $($_.DistinguishedName)"
                                                }
                                                $Rows = @(
                                                    "<B>Type</B>: $($_.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($_.Object.ScheduleOptions.PolicyType)"
                                                    "<B>Domain</B> : $($_.Object.Container.Domain) <B>Distribution Server</B> : $($_.Object.DeploymentOptions.DistributionServer.Name)"
                                                    $Ous
                                                )

                                                Convert-DiaTableToHTML -Label $_.Name -Name $_.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From DummyADContainer -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $LocalPGNum = 1
                                    while ($LocalPGNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$LocalPGNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $LocalPGNum++
                                    }
                                }
                            }
                            Edge -From MainSubGraph:s -To DummyADContainer @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        if ($ManualContainer) {
                            SubGraph MCContainer -Attributes @{Label = (Get-DiaHTMLLabel -Label 'Manual Computers' -IconType "VBR_AGENT_MC" -ImagesObj $Images -IconDebug $IconDebug -SubgraphLabel); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                # Node used for subgraph centering
                                Node DummyMCContainer @{Label = 'DummyMC'; style = $SubGraphDebug.style; color = $SubGraphDebug.color; shape = 'plain' }
                                if (($ManualContainer | Measure-Object).count -le 2) {'Backup-to-All'
                                    foreach ($PGOBJ in ($ManualContainer | Sort-Object -Property Name)) {
                                        $PGHASHTABLE = @{}
                                        $PGOBJ.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }

                                        $Status = Switch ($PGOBJ.Enabled) {
                                            $true { 'Enabled' }
                                            $false { 'Disabled' }
                                            default { 'Unknown' }
                                        }

                                        $Rows = @(
                                            "<B>Type</B>: $($PGOBJ.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($PGOBJ.Object.ScheduleOptions.PolicyType)"
                                        )

                                        Convert-DiaTableToHTML -Label $PGOBJ.Name -Name $PGOBJ.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug

                                        Edge -From DummyMCContainer -To $PGOBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    }

                                } else {
                                    $Group = Split-array -inArray ($ManualContainer | Sort-Object -Property Name) -size 2
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "MCGroup$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $PGHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }

                                                $Status = Switch ($_.Object.Enabled) {
                                                    $true { 'Enabled' }
                                                    $false { 'Disabled' }
                                                    default { 'Unknown' }
                                                }

                                                $Rows = @(
                                                    "<B>Type</B>: $($_.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($_.Object.ScheduleOptions.PolicyType)"
                                                )

                                                Convert-DiaTableToHTML -Label $_.Name -Name $_.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From DummyMCContainer -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $LocalPGNum = 1
                                    while ($LocalPGNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$LocalPGNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $LocalPGNum++
                                    }
                                }
                            }
                            Edge -From MainSubGraph:s -To DummyMCContainer @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        if ($IndividualContainer) {
                            SubGraph ICContainer -Attributes @{Label = (Get-DiaHTMLLabel -Label 'Individual Computers' -IconType "VBR_AGENT_IC" -ImagesObj $Images -IconDebug $IconDebug -SubgraphLabel); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                # Node used for subgraph centering
                                Node DummyICContainer @{Label = 'DummyIC'; style = $SubGraphDebug.style; color = $SubGraphDebug.color; shape = 'plain' }
                                if (($IndividualContainer | Measure-Object).count -le 2) {
                                    foreach ($PGOBJ in ($IndividualContainer | Sort-Object -Property Name)) {
                                        $PGHASHTABLE = @{}
                                        $PGOBJ.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }

                                        $Status = Switch ($PGOBJ.Enabled) {
                                            $true { 'Enabled' }
                                            $false { 'Disabled' }
                                            default { 'Unknown' }
                                        }


                                        $Entities = @()
                                        $Entities += $PGOBJ.Object.Container.CustomCredentials | ForEach-Object {
                                            "<B>Host Name</B> : $($_.HostName)"
                                        }

                                        $Rows = @(
                                            "<B>Type</B>: $($PGOBJ.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($PGOBJ.Object.ScheduleOptions.PolicyType)"
                                            "<B>Distribution Server</B> : $($PGOBJ.Object.DeploymentOptions.DistributionServer.Name)"
                                            $Entities
                                        )

                                        Convert-DiaTableToHTML -Label $PGOBJ.Name -Name $PGOBJ.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug

                                        Edge -From DummyICContainer -To $PGOBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    }
                                } else {
                                    $Group = Split-array -inArray ($IndividualContainer | Sort-Object -Property Name) -size 2
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "ICGroup$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $PGHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }

                                                $Status = Switch ($_.Object.Enabled) {
                                                    $true { 'Enabled' }
                                                    $false { 'Disabled' }
                                                    default { 'Unknown' }
                                                }

                                                $Entities = @()
                                                $Entities += $_.Object.Container.CustomCredentials | ForEach-Object {
                                                    "$($_.HostName)<br />"
                                                }

                                                $Rows = @(
                                                    "<B>Type</B>: $($_.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($_.Object.ScheduleOptions.PolicyType)"
                                                    "<B>Distribution Server</B> : $($_.Object.DeploymentOptions.DistributionServer.Name)"
                                                    "<B>Host Name</B>:
                                                    <br /> $Entities"
                                                )

                                                Convert-DiaTableToHTML -Label $_.Name -Name $_.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From DummyICContainer -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $LocalPGNum = 1
                                    while ($LocalPGNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$LocalPGNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $LocalPGNum++
                                    }
                                }
                            }
                            Edge -From MainSubGraph:s -To DummyICContainer @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                        if ($CSVContainer) {
                            SubGraph CSVContainer -Attributes @{Label = (Get-DiaHTMLLabel -Label 'CSV Computers' -IconType "VBR_AGENT_CSV_Logo" -ImagesObj $Images -IconDebug $IconDebug -SubgraphLabel); fontsize = 18; penwidth = 1.5; labelloc = 't'; style = 'dashed,rounded' } {
                                # Node used for subgraph centering
                                Node DummyCSVContainer @{Label = 'DummyCSVC'; style = $SubGraphDebug.style; color = $SubGraphDebug.color; shape = 'plain' }
                                if (($CSVContainer | Measure-Object).count -le 2) {
                                    foreach ($PGOBJ in ($CSVContainer | Sort-Object -Property Name)) {
                                        $PGHASHTABLE = @{}
                                        $PGOBJ.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }
                                        $Rows = @(
                                            "<B>Type</B>: $($PGOBJ.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($PGOBJ.Object.ScheduleOptions.PolicyType)"
                                            "<B>Distribution Server</B> : $($PGOBJ.Object.DeploymentOptions.DistributionServer.Name)"
                                            "<B>CSV File</B> : $($PGOBJ.Object.Container.Path)"
                                            "<B>Credential</B> : $($PGOBJ.Object.Container.MasterCredentials.Name)"
                                        )

                                        Convert-DiaTableToHTML -Label $PGOBJ.Name -Name $PGOBJ.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug

                                        Edge -From DummyCSVContainer -To $PGOBJ.Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    }

                                } else {
                                    $Group = Split-array -inArray ($CSVContainer | Sort-Object -Property Name) -size 2
                                    $Number = 0
                                    while ($Number -ne $Group.Length) {
                                        $Random = Get-Random
                                        SubGraph "CSVGroup$($Number)_$Random" -Attributes @{Label = ' '; style = $SubGraphDebug.style; color = $SubGraphDebug.color; fontsize = 18; penwidth = 1 } {
                                            $Group[$Number] | ForEach-Object {
                                                $PGHASHTABLE = @{}
                                                $_.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }
                                                $Rows = @(
                                                    "<B>Type</B>: $($_.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($_.Object.ScheduleOptions.PolicyType)"
                                                    "<B>Distribution Server</B> : $($_.Object.DeploymentOptions.DistributionServer.Name)"
                                                    "<B>CSV File</B> : $($_.Object.Container.Path)"
                                                    "<B>Credential</B> : $($_.Object.Container.MasterCredentials.Name)"
                                                )

                                                Convert-DiaTableToHTML -Label $_.Name -Name $_.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug
                                            }
                                        }
                                        $Number++
                                    }

                                    Edge -From DummyCSVContainer -To $Group[0].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                    $Start = 0
                                    $LocalPGNum = 1
                                    while ($LocalPGNum -ne $Group.Length) {
                                        Edge -From $Group[$Start].Name -To $Group[$LocalPGNum].Name @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                                        $Start++
                                        $LocalPGNum++
                                    }
                                }
                            }
                            Edge -From MainSubGraph:s -To DummyCSVContainer @{minlen = 1; style = $EdgeDebug.style; color = $EdgeDebug.color }
                        }
                    }

                    Edge -From DummyFileProxyToPG -To MainSubGraph @{ltail = 'clusterMainSubGraphFileProxy'; lhead = 'clusterMainSubGraph'; minlen = 3 }
                }
            }
        } catch {
            $_
        }
    }
    end {}
}