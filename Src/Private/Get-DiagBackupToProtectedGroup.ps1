function Get-DiagBackupToProtectedGroup {
    <#
    .SYNOPSIS
        Function to build a Backup Server to Protected Group diagram.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.6.16
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

                        Node FileProxies @{Label = (Get-DiaHTMLNodeTable -ImagesObj $Images -inputObject ($FileBackupProxy | ForEach-Object { $_.Name.split('.')[0] }) -Align "Center" -iconType "VBR_Proxy_Server" -columnSize 4 -IconDebug $IconDebug -MultiIcon -AditionalInfo $FileBackupProxy.AditionalInfo -Subgraph -SubgraphIconType "VBR_Proxy" -SubgraphLabel "File Backup Proxies" -SubgraphLabelPos "top" -SubgraphTableStyle "dashed,rounded" -fontColor $Fontcolor -TableBorderColor $Edgecolor -TableBorder "1"); shape = 'plain'; fontsize = 14; fontname = "Segoe Ui" }

                        Edge $BackupServerInfo.Name -To FileProxies @{minlen = 3 }

                    }
                }
            } catch {
                Write-Verbose -Message $_.Exception.Message
            }

            if ($ProtectedGroups.Container) {
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
                            try {
                                $ADCNodesSubgraph = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ADCNodes -Align 'Center' -IconDebug $IconDebug -Label 'Active Directory Computers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2 -IconType "VBR_AGENT_AD"
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
                            try {
                                $MCNodesSubgraph = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $MCNodes -Align 'Center' -IconDebug $IconDebug -Label 'Manual Computers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2 -IconType "VBR_AGENT_MC"
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
                            try {
                                $ICCNodesSubgraph = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ICCNodes -Align 'Center' -IconDebug $IconDebug -Label 'Individual Computers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2 -IconType "VBR_AGENT_IC"
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
                            try {
                                $CSVCNodesSubgraph = Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $CSVCNodes -Align 'Center' -IconDebug $IconDebug -Label 'CSV Computers' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 2 -IconType "VBR_AGENT_CSV_Logo"
                            } catch {
                                Write-Verbose "Error: Unable to create CSVCNodesSubgraph Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }
                            $ComputerAgentsArray += $CSVCNodesSubgraph
                        }
                    }

                    if ($ComputerAgentsArray) {
                        if ($Dir -eq 'LR') {
                            try {
                                $ComputerAgentSubGraph = Node -Name "ComputerAgentsSubgraph" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ComputerAgentsArray -Align 'Center' -IconDebug $IconDebug -Label 'Protected Groups' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 1); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
                            } catch {
                                Write-Verbose "Error: Unable to create ComputerAgentsSubgraph Objects. Disabling the section"
                                Write-Debug "Error Message: $($_.Exception.Message)"
                            }
                        } else {
                            try {
                                $ComputerAgentSubGraph = Node -Name "ComputerAgentsSubgraph" -Attributes @{Label = (Get-DiaHTMLSubGraph -ImagesObj $Images -TableArray $ComputerAgentsArray -Align 'Center' -IconDebug $IconDebug -Label 'Protected Groups' -LabelPos "top" -fontColor $Fontcolor -TableStyle "dashed,rounded" -TableBorderColor $Edgecolor -TableBorder "1" -columnSize 4); shape = 'plain'; fillColor = 'transparent'; fontsize = 14; fontname = "Segoe Ui" }
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