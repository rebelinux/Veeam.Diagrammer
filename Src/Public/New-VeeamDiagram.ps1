function New-VeeamDiagram {
    <#
.SYNOPSIS
    Diagram the configuration of Veeam Backup & Replication infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
.DESCRIPTION
    Diagram the configuration of Veeam Backup & Replication infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
.PARAMETER DiagramType
    Specifies the type of veeam vbr diagram that will be generated.
.PARAMETER Target
    Specifies the IP/FQDN of the system to connect.
    Multiple targets may be specified, separated by a comma.
.PARAMETER Port
    Specifies a optional port to connect to Veeam VBR Service.
    By default, port will be set to 9392
.PARAMETER Credential
    Specifies the stored credential of the target system.
.PARAMETER Username
    Specifies the username for the target system.
.PARAMETER Password
    Specifies the password for the target system.
.PARAMETER Format
    Specifies the output format of the diagram.
    The supported output formats are PDF, PNG, DOT & SVG.
    Multiple output formats may be specified, separated by a comma.
.PARAMETER Direction
    Set the direction in which resource are plotted on the visualization
    By default, direction will be set to top-to-bottom.
.PARAMETER NodeSeparation
    Controls Node separation ratio in visualization
    By default, NodeSeparation will be set to .60.
.PARAMETER SectionSeparation
    Controls Section (Subgraph) separation ratio in visualization
    By default, NodeSeparation will be set to .75.
.PARAMETER EdgeType
    Controls how edges lines appear in visualization
    By default, EdgeType will be set to spline.
.PARAMETER OutputFolderPath
    Specifies the folder path to save the diagram.
.PARAMETER Filename
    Specifies a filename for the diagram.
.PARAMETER EnableEdgeDebug
    Control to enable edge debugging ( Dummy Edge and Node lines ).
.PARAMETER EnableSubGraphDebug
    Control to enable subgraph debugging ( Subgraph Lines ).
.PARAMETER EnableErrorDebug
    Control to enable error debugging.
.NOTES
    Version:        0.5.1
    Author(s):      Jonathan Colon
    Twitter:        @jcolonfzenpr
    Github:         rebelinux
    Credits:        Kevin Marquette (@KevinMarquette) -  PSGraph module
    Credits:        Prateek Singh (@PrateekKumarSingh) - AzViz module
.LINK
    https://github.com/rebelinux/Veeam.Diagrammer
    https://github.com/KevinMarquette/PSGraph
    https://github.com/PrateekKumarSingh/AzViz
#>

[Diagnostics.CodeAnalysis.SuppressMessage(
    'PSUseShouldProcessForStateChangingFunctions',
    ''
)]

[CmdletBinding(
    PositionalBinding = $false,
    DefaultParameterSetName = 'Credential'
)]

param (

    [Parameter(
        Position = 0,
        Mandatory = $true,
        HelpMessage = 'Please provide the IP/FQDN of the system'
    )]
    [ValidateNotNullOrEmpty()]
    [Alias('Server', 'IP')]
    [String[]] $Target,

    [Parameter(
        Position = 1,
        Mandatory = $true,
        HelpMessage = 'Please provide credentials to connect to the system',
        ParameterSetName = 'Credential'
    )]
    [ValidateNotNullOrEmpty()]
    [PSCredential] $Credential,

    [Parameter(
        Position = 2,
        Mandatory = $true,
        HelpMessage = 'Please provide the username to connect to the target system',
        ParameterSetName = 'UsernameAndPassword'
    )]
    [ValidateNotNullOrEmpty()]
    [String] $Username,

    [Parameter(
        Position = 3,
        Mandatory = $true,
        HelpMessage = 'Please provide the password to connect to the target system',
        ParameterSetName = 'UsernameAndPassword'
    )]
    [ValidateNotNullOrEmpty()]
    [String] $Password,

    [Parameter(
        Position = 4,
        Mandatory = $false,
        HelpMessage = 'Please provide the diagram output format'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('pdf', 'svg', 'png', 'dot', 'base64', 'jpg')]
    [Array] $Format = 'pdf',

    [Parameter(
        Position = 5,
        Mandatory = $false,
        HelpMessage = 'TCP Port of target Veeam Backup Server'
    )]
    [string] $Port = '9392',

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Direction in which resource are plotted on the visualization'
    )]
    [ValidateSet('left-to-right', 'top-to-bottom')]
    [string] $Direction = 'top-to-bottom',

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Please provide the path to the diagram output file'
    )]
    [ValidateScript( { Test-Path -Path $_ -IsValid })]
    [string] $OutputFolderPath = (Join-Path ([System.IO.Path]::GetTempPath()) "$Filename.$Format"),

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Specify the Diagram filename'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        if ($Format.count -lt 2) {
            $true
        } else {
            throw "Format value must be unique if Filename is especified."
        }
    })]
    [String] $Filename,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Controls how edges lines appear in visualization'
    )]
    [ValidateSet('polyline', 'curved', 'ortho', 'line', 'spline')]
    [string] $EdgeType = 'spline',

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Controls Node separation ratio in visualization'
    )]
    [ValidateSet(0, 1, 2, 3)]
    [string] $NodeSeparation = .60,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Controls Section (Subgraph) separation ratio in visualization'
    )]
    [ValidateSet(0, 1, 2, 3)]
    [string] $SectionSeparation = .75,

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Controls type of Veeam VBR generated diagram'
    )]
    [ValidateSet('Backup-to-Tape', 'Backup-to-HyperV-Proxy', 'Backup-to-vSphere-Proxy', 'Backup-to-Repository', 'Backup-to-Sobr', 'Backup-to-WanAccelerator', 'Backup-to-All')]
    [string] $DiagramType,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Allow to enable edge debugging ( Dummy Edge and Node lines)'
    )]
    [Switch] $EnableEdgeDebug = $false,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Allow to enable subgraph debugging ( Subgraph Lines )'
    )]
    [Switch] $EnableSubGraphDebug = $false,
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Allow to enable error debugging'
    )]
    [Switch] $EnableErrorDebug = $false
)


begin {

    # If Username and Password parameters used, convert specified Password to secure string and store in $Credential
    #@tpcarman
    if (($Username -and $Password)) {
        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
    }

    if (($Format -ne "base64") -and  !(Test-Path $OutputFolderPath)) {
        Write-Error "OutputFolderPath '$OutputFolderPath' is not a valid folder path."
        break
    }

    $MainGraphLabel = Switch ($DiagramType) {
        'Backup-to-Sobr' {'Scale-Out Backup Repository Diagram'}
        'Backup-to-Proxy' {'Backup Proxy Diagram'}
        'Backup-to-Repository' {'Backup Repository Diagram'}
        'Backup-to-WanAccelerator' {'Wan Accelerators Diagram'}
        'Backup-to-Tape' {'Tape Infrastructure Diagram'}
        'Backup-to-All' {'Backup Infrastructure Diagram'}
    }

    if ($EnableEdgeDebug) {
        $EdgeDebug = @{style='filled'; color='red'}
    } else {$EdgeDebug = @{style='invis'; color='red'}}

    if ($EnableSubGraphDebug) {
        $SubGraphDebug = @{style='dashed'; color='red'}
    } else {$SubGraphDebug = @{style='invis'; color='gray'}}

    $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $IconPath = Join-Path $RootPath 'icons'
    $Dir = switch ($Direction) {
        'top-to-bottom' {'TB'}
        'left-to-right' {'LR'}
    }

    Get-VbrRequiredModule -Name 'Veeam.Backup.PowerShell' -Version '1.0'

    $MainGraphAttributes = @{
        pad = 1.0
        rankdir   = $Dir
        overlap   = 'false'
        splines   = $EdgeType
        penwidth  = 1.5
        fontname  = "Segoe Ui Black"
        fontcolor = '#005f4b'
        fontsize  = 32
        style = "dashed"
        labelloc = 't'
        imagepath = $IconPath
        nodesep = $NodeSeparation
        ranksep = $SectionSeparation
        # size = "7.5,10"
    }
}

process {

    foreach ($System in $Target) {

        Get-VbrServerConnection

        try {

            $VBRServer = Get-VBRServer -Type Local

        } Catch {throw "Unable to get Veeam B&R Server"}

        Get-VbrBackupServerInfo

        $Graph = Graph -Name VeeamVBR -Attributes $MainGraphAttributes {
            # Node default theme
            node @{
                label = ''
                shape = 'none'
                labelloc = 't'
                style = 'filled'
                fillColor = 'white'
                fontsize = 14;
                imagescale = $true
            }
            # Edge default theme
            edge @{
                style = 'dashed'
                dir = 'both'
                arrowtail = 'dot'
                color = '#71797E'
                penwidth = 1.5
                arrowsize = 1
            }

            SubGraph MainGraph -Attributes @{Label=(Get-HTMLLabel -Label $MainGraphLabel -Type "VBR_LOGO" ); fontsize=24; penwidth=0} {

                SubGraph BackupServer -Attributes @{Label='Backup Server'; style="rounded"; bgcolor="#ceedc4"; fontsize=18; penwidth=2} {
                    if (($DatabaseServerInfo.Name -ne $BackupServerInfo.Name) -and $EMServerInfo) {
                        $BSHASHTABLE = @{}
                        $DBHASHTABLE = @{}
                        $EMHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        $DatabaseServerInfo.psobject.properties | ForEach-Object { $DBHASHTABLE[$_.Name] = $_.Value }
                        $EMServerInfo.psobject.properties | ForEach-Object { $EMHASHTABLE[$_.Name] = $_.Value }

                        node $BackupServerInfo.Name -Attributes @{Label=$BSHASHTABLE.Label; fillColor='#ceedc4'}
                        node $DatabaseServerInfo.Name -Attributes @{Label=$DBHASHTABLE.Label; fillColor='#ceedc4'}
                        node $EMServerInfo.Name -Attributes @{Label=$EMHASHTABLE.Label; fillColor='#ceedc4'}

                        if ($Dir -eq 'LR') {
                            rank $EMServerInfo.Name,$BackupServerInfo.Name
                            edge -from $BackupServerInfo.Name -to $EMServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3;}
                            edge -from $BackupServerInfo.Name -to $DatabaseServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3; xlabel=$DatabaseServerInfo.DBPort}
                        } else {
                            rank $EMServerInfo.Name,$BackupServerInfo.Name,$DatabaseServerInfo.Name
                            edge -from $EMServerInfo.Name -to $BackupServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3;}
                            edge -from $BackupServerInfo.Name -to $DatabaseServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3; xlabel=$DatabaseServerInfo.DBPort}
                        }
                    }
                    elseif (($DatabaseServerInfo.Name -ne $BackupServerInfo.Name) -and (-Not $EMServerInfo)) {
                        $BSHASHTABLE = @{}
                        $DBHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        $DatabaseServerInfo.psobject.properties | ForEach-Object { $DBHASHTABLE[$_.Name] = $_.Value }

                        node $BackupServerInfo.Name -Attributes @{Label=$BSHASHTABLE.Label; fillColor='#ceedc4'}
                        node $DatabaseServerInfo.Name -Attributes @{Label=$DBHASHTABLE.Label; fillColor='#ceedc4'}

                        if ($Dir -eq 'LR') {
                            rank $BackupServerInfo.Name,$DatabaseServerInfo.Name
                            edge -from $BackupServerInfo.Name -to $DatabaseServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3; xlabel=$DatabaseServerInfo.DBPort}
                        } else {
                            rank $BackupServerInfo.Name,$DatabaseServerInfo.Name
                            edge -from $BackupServerInfo.Name -to $DatabaseServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3; xlabel=$DatabaseServerInfo.DBPort}
                        }
                    }
                    elseif ($EMServerInfo -and (-Not $DatabaseServerInfo)) {
                        $BSHASHTABLE = @{}
                        $EMHASHTABLE = @{}

                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        $EMServerInfo.psobject.properties | ForEach-Object { $EMHASHTABLE[$_.Name] = $_.Value }

                        node $BackupServerInfo.Name -Attributes @{Label=$BSHASHTABLE.Label; fillColor='#ceedc4'}
                        node $EMServerInfo.Name -Attributes @{Label=$EMHASHTABLE.Label; fillColor='#ceedc4'}

                        if ($Dir -eq 'LR') {
                            rank $EMServerInfo.Name,$BackupServerInfo.Name
                            edge -from $BackupServerInfo.Name -to $EMServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3;}
                        } else {
                            rank $EMServerInfo.Name,$BackupServerInfo.Name
                            edge -from $EMServerInfo.Name -to $BackupServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3;}
                        }
                    } else {
                        $BSHASHTABLE = @{}
                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        node $BackupServerInfo.Name -Attributes @{Label=$BSHASHTABLE.Label; fillColor='#ceedc4'}
                    }
                }

                if ($DiagramType -eq 'Backup-to-HyperV-Proxy') {
                    if (Get-DiagBackupToHvProxy) {
                        Get-DiagBackupToHvProxy
                    } else {Write-Warning "No HyperV Proxy Infrastructure available to diagram"}
                }
                elseif ($DiagramType -eq 'Backup-to-vSphere-Proxy') {
                    if (Get-DiagBackupToViProxy) {
                        Get-DiagBackupToViProxy
                    } else {Write-Warning "No vSphere Proxy Infrastructure available to diagram"}
                }
                elseif ($DiagramType -eq 'Backup-to-WanAccelerator') {
                    if (Get-DiagBackupToWanAccel) {
                        Get-DiagBackupToWanAccel
                    } else {Write-Warning "No Wan Accelerators available to diagram"}
                }
                elseif ($DiagramType -eq 'Backup-to-Repository') {
                    if (Get-DiagBackupToRepo) {
                        Get-DiagBackupToRepo
                    } else {Write-Warning "No Backup Repository available to diagram"}
                }
                elseif ($DiagramType -eq 'Backup-to-Tape') {
                    $BackupToTape = Get-DiagBackupToTape
                    if ($BackupToTape) {
                        $BackupToTape
                    } else {Write-Warning "No Tape Infrastructure available to diagram"}
                }
                elseif ($DiagramType -eq 'Backup-to-Sobr') {
                    if (Get-DiagBackupToSobr) {
                        Get-DiagBackupToSobr
                    } else {Write-Warning "No Scale-Out Backup Repository available to diagram"}
                }
                elseif ($DiagramType -eq 'Backup-to-All') {
                    if (Get-DiagBackupToHvProxy) {
                        Get-DiagBackupToHvProxy
                    } else {Write-Warning "No HyperV Proxy Infrastructure available to diagram"}
                    if (Get-DiagBackupToViProxy) {
                        Get-DiagBackupToViProxy
                    } else {Write-Warning "No vSphere Proxy Infrastructure available to diagram"}
                    Get-DiagBackupToWanAccel
                    Get-DiagBackupToRepo
                    Get-DiagBackupToSobr
                    Get-DiagBackupToTape
                }
            }

        }

        if ($EnableErrorDebug) {
            $Graph
        } else {
            # If Filename parameter is not specified, set filename to the Output.$OutputFormat
            foreach ($OutputFormat in $Format) {
                if ($Filename) {
                    Try {
                    if ($OutputFormat -ne "base64") {
                            if($OutputFormat -ne "svg") {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat $OutputFormat
                                Write-ColorOutput -Color green  "Diagram '$FileName' has been saved to '$OutputFolderPath'."
                            } else {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat $OutputFormat
                                #Fix icon path issue with svg output
                                $images = Select-String -Path $($Document.fullname) -Pattern '<image xlink:href=".*png".*>' -AllMatches
                                foreach($match in $images) {
                                    $matchFound = $match -Match '"(.*png)"'
                                    if ($matchFound -eq $false) {
                                        continue
                                    }
                                    $iconName = $Matches.Item(1)
                                    $iconNamePath = "$IconPath\$($Matches.Item(1))"
                                    $iconContents = Get-Content $iconNamePath -Encoding byte
                                    $iconEncoded = [convert]::ToBase64String($iconContents)
                                    ((Get-Content -Path $($Document.fullname) -Raw) -Replace $iconName, "data:image/png;base64,$($iconEncoded)") | Set-Content -Path $($Document.fullname)
                                }
                                if ($Document) {
                                    Write-ColorOutput -Color green "Diagram '$FileName' has been saved to '$OutputFolderPath'."
                                }

                            }
                        } else {
                            $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat 'png'
                            if ($Document) {
                                # Code used to allow rotating image!
                                if ($Rotate) {
                                    Add-Type -AssemblyName System.Windows.Forms
                                    $RotatedIMG = new-object System.Drawing.Bitmap $Document.FullName
                                    $RotatedIMG.RotateFlip("Rotate90FlipNone")
                                    $RotatedIMG.Save($Document.FullName,"png")
                                    if ($RotatedIMG) {
                                        $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                        if ($Base64) {
                                            Remove-Item -Path $Document.FullName
                                            $Base64
                                        } else {Remove-Item -Path $Document.FullName}
                                    }
                                } else {
                                    # Code used to output image to base64 format
                                    $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                    if ($Base64) {
                                        Remove-Item -Path $Document.FullName
                                        $Base64
                                    } else {Remove-Item -Path $Document.FullName}

                                }
                            }
                        }
                    } catch {
                        $Err = $_
                        Write-Error $Err
                    }
                }
                elseif (!$Filename) {
                    if ($OutputFormat -ne "base64") {
                        $File = "Output.$OutputFormat"
                    } else {$File = "Output.png"}
                    Try {
                        if ($OutputFormat -ne "base64") {
                            if($OutputFormat -ne "svg") {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat $OutputFormat
                                Write-ColorOutput -Color green  "Diagram '$File' has been saved to '$OutputFolderPath'."
                            } else {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat $OutputFormat
                                $images = Select-String -Path $($Document.fullname) -Pattern '<image xlink:href=".*png".*>' -AllMatches
                                foreach($match in $images) {
                                    $matchFound = $match -Match '"(.*png)"'
                                    if ($matchFound -eq $false) {
                                        continue
                                    }
                                    $iconName = $Matches.Item(1)
                                    $iconNamePath = "$IconPath\$($Matches.Item(1))"
                                    $iconContents = Get-Content $iconNamePath -Encoding byte
                                    $iconEncoded = [convert]::ToBase64String($iconContents)
                                    ((Get-Content -Path $($Document.fullname) -Raw) -Replace $iconName, "data:image/png;base64,$($iconEncoded)") | Set-Content -Path $($Document.fullname)
                                }
                                if ($Document) {
                                    Write-ColorOutput -Color green  "Diagram '$File' has been saved to '$OutputFolderPath'."
                                }
                            }
                        } else {
                            $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat 'png'
                            if ($Document) {
                                $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                if ($Base64) {
                                    Remove-Item -Path $Document.FullName
                                    $Base64
                                } else {Remove-Item -Path $Document.FullName}
                            }
                        }
                    } catch {
                        $Err = $_
                        Write-Error $Err
                    }
                }
            }
        }
    }

}
end {}
}