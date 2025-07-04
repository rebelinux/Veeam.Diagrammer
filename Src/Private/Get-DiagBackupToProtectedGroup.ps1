function Get-DiagBackupToProtectedGroup {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Protected Group diagram.
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

    begin {
    }

    process {
        try {
            $ProtectedGroups = Get-VbrBackupProtectedGroupInfo
            $ADContainer = $ProtectedGroups | Where-Object { $_.Container -eq 'ActiveDirectory' }
            $ManualContainer = $ProtectedGroups | Where-Object { $_.Container -eq 'ManuallyDeployed' }
            $IndividualContainer = $ProtectedGroups | Where-Object { $_.Container -eq 'IndividualComputers' }
            $CSVContainer = $ProtectedGroups | Where-Object { $_.Container -eq 'CSV' }

            if ($ProtectedGroups.Container) {
                try {
                    $FileBackupProxy = Get-VbrBackupProxyInfo -Type 'nas'
                    if ($BackupServerInfo) {
                        if ($FileBackupProxy) {
                            if ($FileBackupProxy.Name.Count -eq 1) {
                                $FileBackupProxyColumnSize = 1
                            } elseif ($ColumnSize) {
                                $FileBackupProxyColumnSize = $ColumnSize
                            } else {
                                $FileBackupProxyColumnSize = $FileBackupProxy.Name.Count
                            }

                            Node FileProxies @{Label = (Add-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($FileBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize $FileBackupProxyColumnSize -IconDebug $IconDebug -MultiIcon -AditionalInfo $FileBackupProxy.AditionalInfo -Subgraph -SubgraphIconType "VBR_Proxy" -SubgraphLabel "File Backup Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1" -SubgraphLabelFontsize 24 -fontSize 18); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                            Edge BackupServers -To FileProxies @{minlen = 3 }

                        }
                    }
                } catch {
                    Write-Verbose -Message $_.Exception.Message
                }
                if ($ProtectedGroups) {
                    $ComputerAgentsArray = @()
                    if ($ADContainer) {
                        try {
                            $ADCNodes = foreach ($PGOBJ in ($ADContainer | Sort-Object -Property Name)) {
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

                                Convert-DiaTableToHTML -Label $PGOBJ.Name -Name $PGOBJ.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug -HTMLOutput $true
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create ADCNodes Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($ADCNodes) {
                            if ($ADCNodes.Count -eq 1) {
                                $ADCNodesColumnSize = 1
                            } elseif ($ColumnSize) {
                                $ADCNodesColumnSize = $ColumnSize
                            } else {
                                $ADCNodesColumnSize = $ADCNodes.Count
                            }
                            try {
                                $ADCNodesSubgraph = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ADCNodes -Align 'Center' -IconDebug $IconDebug -Label 'Active Directory Computers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $ADCNodesColumnSize -IconType "VBR_AGENT_AD" -fontSize 18
                            } catch {
                                Write-Verbose "Error: Unable to create ADCNodesSubgraph Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }
                            $ComputerAgentsArray += $ADCNodesSubgraph
                        }
                    }
                    if ($ManualContainer) {
                        try {
                            $MCNodes = foreach ($PGOBJ in ($ManualContainer | Sort-Object -Property Name)) {
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

                                Convert-DiaTableToHTML -Label $PGOBJ.Name -Name $PGOBJ.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug -HTMLOutput $true
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create MCNodes Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($MCNodes) {
                            if ($MCNodes.Count -eq 1) {
                                $MCNodesColumnSize = 1
                            } elseif ($ColumnSize) {
                                $MCNodesColumnSize = $ColumnSize
                            } else {
                                $MCNodesColumnSize = $MCNodes.Count
                            }
                            try {
                                $MCNodesSubgraph = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $MCNodes -Align 'Center' -IconDebug $IconDebug -Label 'Manual Computers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $MCNodesColumnSize -IconType "VBR_AGENT_MC" -fontSize 18
                            } catch {
                                Write-Verbose "Error: Unable to create MCNodesSubgraph Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }
                            $ComputerAgentsArray += $MCNodesSubgraph
                        }
                    }
                    if ($IndividualContainer) {
                        try {
                            $ICCNodes = foreach ($PGOBJ in ($IndividualContainer | Sort-Object -Property Name)) {
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

                                Convert-DiaTableToHTML -Label $PGOBJ.Name -Name $PGOBJ.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug -HTMLOutput $true
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create ICCNodes Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($ICCNodes) {
                            if ($ICCNodes.Count -eq 1) {
                                $ICCNodesColumnSize = 1
                            } elseif ($ColumnSize) {
                                $ICCNodesColumnSize = $ColumnSize
                            } else {
                                $ICCNodesColumnSize = $ICCNodes.Count
                            }
                            try {
                                $ICCNodesSubgraph = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ICCNodes -Align 'Center' -IconDebug $IconDebug -Label 'Individual Computers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $ICCNodesColumnSize -IconType "VBR_AGENT_IC" -fontSize 18
                            } catch {
                                Write-Verbose "Error: Unable to create ICCNodesSubgraph Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }
                            $ComputerAgentsArray += $ICCNodesSubgraph
                        }
                    }
                    if ($CSVContainer) {
                        try {
                            $CSVCNodes = foreach ($PGOBJ in ($CSVContainer | Sort-Object -Property Name)) {
                                $PGHASHTABLE = @{}
                                $PGOBJ.psobject.properties | ForEach-Object { $PGHASHTABLE[$_.Name] = $_.Value }
                                $Rows = @(
                                    "<B>Type</B>: $($PGOBJ.Object.Type) <B>Status</B>: $($Status) <B>Schedule</B>: $($PGOBJ.Object.ScheduleOptions.PolicyType)"
                                    "<B>Distribution Server</B> : $($PGOBJ.Object.DeploymentOptions.DistributionServer.Name)"
                                    "<B>CSV File</B> : $($PGOBJ.Object.Container.Path)"
                                    "<B>Credential</B> : $($PGOBJ.Object.Container.MasterCredentials.Name)"
                                )

                                Convert-DiaTableToHTML -Label $PGOBJ.Name -Name $PGOBJ.Name -Row $Rows -HeaderColor "#005f4b" -HeaderFontColor "white" -BorderColor "black" -FontSize 14 -IconDebug $IconDebug -HTMLOutput $true
                            }
                        } catch {
                            Write-Verbose "Error: Unable to create CSVCNodes Objects. Disabling the section"
                            Write-Debug "Error Message: $($_.Exception.Message)"
                        }

                        if ($CSVCNodes) {
                            if ($CSVCNodes.Count -eq 1) {
                                $CSVCNodesColumnSize = 1
                            } elseif ($ColumnSize) {
                                $CSVCNodesColumnSize = $ColumnSize
                            } else {
                                $CSVCNodesColumnSize = $CSVCNodes.Count
                            }
                            try {
                                $CSVCNodesSubgraph = Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CSVCNodes -Align 'Center' -IconDebug $IconDebug -Label 'CSV Computers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $CSVCNodesColumnSize -IconType "VBR_AGENT_CSV_Logo" -fontSize 18
                            } catch {
                                Write-Verbose "Error: Unable to create CSVCNodesSubgraph Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }
                            $ComputerAgentsArray += $CSVCNodesSubgraph
                        }
                    }

                    if ($ComputerAgentsArray) {
                        if ($ComputerAgentsArray.Count -eq 1) {
                            $ComputerAgentsArrayColumnSize = 1
                        } elseif ($ColumnSize) {
                            $ComputerAgentsArrayColumnSize = $ColumnSize
                        } else {
                            $ComputerAgentsArrayColumnSize = $ComputerAgentsArray.Count
                        }
                        if ($Dir -eq 'LR') {
                            try {
                                $ComputerAgentSubGraph = Node -Name "ComputerAgentsSubgraph" -Attributes @{Label = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ComputerAgentsArray -Align 'Center' -IconDebug $IconDebug -Label 'Protected Groups' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $ComputerAgentsArrayColumnSize -fontSize 26); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                            } catch {
                                Write-Verbose "Error: Unable to create ComputerAgentsSubgraph Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }
                        } else {
                            try {
                                $ComputerAgentSubGraph = Node -Name "ComputerAgentsSubgraph" -Attributes @{Label = (Add-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ComputerAgentsArray -Align 'Center' -IconDebug $IconDebug -Label 'Protected Groups' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize $ComputerAgentsArrayColumnSize -fontSize 26); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                            } catch {
                                Write-Verbose "Error: Unable to create ComputerAgentsSubgraph Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }
                        }
                    }

                    if ($ComputerAgentSubGraph) {
                        $ComputerAgentSubGraph
                        Edge -From FileProxies -To ComputerAgentsSubgraph @{minlen = 3 }
                    }
                }
            }
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }
    }
    end {}
}