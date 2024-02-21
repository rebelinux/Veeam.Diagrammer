function New-VeeamDiagram {
    <#
    .SYNOPSIS
        Diagram the configuration of Veeam Backup & Replication infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
    .DESCRIPTION
        Diagram the configuration of Veeam Backup & Replication infrastructure in PDF/SVG/DOT/PNG formats using PSGraph and Graphviz.
    .PARAMETER DiagramType
        Specifies the type of veeam vbr diagram that will be generated.
        The supported output diagrams are:
            'Backup-to-Sobr', 'Backup-to-vSphere-Proxy', 'Backup-to-HyperV-Proxy',
            'Backup-to-Repository', 'Backup-to-WanAccelerator', 'Backup-to-Tape',
            'Backup-to-File-Proxy', 'Backup-to-ProtectedGroup', 'Backup-to-All'
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
        The supported directions are:
            'top-to-bottom', 'left-to-right'
        By default, direction will be set to top-to-bottom.
    .PARAMETER NodeSeparation
        Controls Node separation ratio in visualization
        By default, NodeSeparation will be set to .60.
    .PARAMETER SectionSeparation
        Controls Section (Subgraph) separation ratio in visualization
        By default, NodeSeparation will be set to .75.
    .PARAMETER EdgeType
        Controls how edges lines appear in visualization
        The supported edge type are:
            'polyline', 'curved', 'ortho', 'line', 'spline'
        By default, EdgeType will be set to spline.
        References: https://graphviz.org/docs/attrs/splines/
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
    .PARAMETER AuthorName
        Allow to set footer signature Author Name.
    .PARAMETER CompanyName
        Allow to set footer signature Company Name.
    .PARAMETER Logo
        Allow to change the Veeam logo to a custom one.
        Image should be 400px x 100px or less in size.
    .PARAMETER SignatureLogo
        Allow to change the Veeam.Diagrammer signature logo to a custom one.
        Image should be 120px x 130px or less in size.
    .PARAMETER Signature
        Allow the creation of footer signature.
        AuthorName and CompanyName must be set to use this property.
    .NOTES
        Version:        0.5.9
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
        [ValidateScript( {
                if (Test-Path -Path $_) {
                    $true
                } else {
                    throw "Path $_ not found!"
                }
            })]
        [string] $OutputFolderPath = [System.IO.Path]::GetTempPath(),

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the path to the custom logo used for Signature'
        )]
        [ValidateScript( {
                if (Test-Path -Path $_) {
                    $true
                } else {
                    throw "File $_ not found!"
                }
            })]
        [string] $SignatureLogo,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the path to the custom logo'
        )]
        [ValidateScript( {
                if (Test-Path -Path $_) {
                    $true
                } else {
                    throw "File $_ not found!"
                }
            })]
        [string] $Logo,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specify the Diagram filename'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                if (($Format | Measure-Object).count -lt 2) {
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
        [ValidateSet('Backup-to-Tape', 'Backup-to-File-Proxy', 'Backup-to-HyperV-Proxy', 'Backup-to-vSphere-Proxy', 'Backup-to-Repository', 'Backup-to-Sobr', 'Backup-to-WanAccelerator', 'Backup-to-ProtectedGroup', 'Backup-to-All')]
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
        [Switch] $EnableErrorDebug = $false,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow to set footer signature Author Name'
        )]
        [string] $AuthorName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow to set footer signature Company Name'
        )]
        [string] $CompanyName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow the creation of footer signature'
        )]
        [Switch] $Signature = $false
    )


    begin {

        # If Username and Password parameters used, convert specified Password to secure string and store in $Credential
        #@tpcarman
        if (($Username -and $Password)) {
            $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
        }

        if (($Format -ne "base64") -and !(Test-Path $OutputFolderPath)) {
            Write-Error "OutputFolderPath '$OutputFolderPath' is not a valid folder path."
            break
        }

        if ($Signature -and (([string]::IsNullOrEmpty($AuthorName)) -or ([string]::IsNullOrEmpty($CompanyName)))) {
            throw "New-VeeamDiagram : AuthorName and CompanyName must be defined if the Signature option is specified"
        }

        $MainGraphLabel = Switch ($DiagramType) {
            'Backup-to-Sobr' { 'Scale-Out Backup Repository Diagram' }
            'Backup-to-File-Proxy' { 'File Backup Proxy Diagram' }
            'Backup-to-vSphere-Proxy' { 'VMware Backup Proxy Diagram' }
            'Backup-to-HyperV-Proxy' { 'HyperV Backup Proxy Diagram' }
            'Backup-to-Repository' { 'Backup Repository Diagram' }
            'Backup-to-WanAccelerator' { 'Wan Accelerators Diagram' }
            'Backup-to-Tape' { 'Tape Infrastructure Diagram' }
            'Backup-to-ProtectedGroup' { 'Physical Infrastructure Diagram' }
            'Backup-to-All' { 'Backup Infrastructure Diagram' }
        }

        $URLIcon = $false

        if ($EnableEdgeDebug) {
            $script:EdgeDebug = @{style = 'filled'; color = 'red' }
            $URLIcon = $true
        } else { $script:EdgeDebug = @{style = 'invis'; color = 'red' } }

        if ($EnableSubGraphDebug) {
            $script:SubGraphDebug = @{style = 'dashed'; color = 'red' }
            $URLIcon = $true
        } else { $script:SubGraphDebug = @{style = 'invis'; color = 'gray' } }

        $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $IconPath = Join-Path $RootPath 'icons'
        $script:GraphvizPath = Join-Path $RootPath 'Graphviz\bin\dot.exe'
        $Dir = switch ($Direction) {
            'top-to-bottom' { 'TB' }
            'left-to-right' { 'LR' }
        }

        # Validate Custom logo
        $CustomLogo = Test-Logo -LogoPath $Logo
        # Validate Custom Signature Logo
        $CustomSignatureLogo = Test-Logo -LogoPath $SignatureLogo -Signature

        # Validate Veeam Powershell Module
        Get-VbrRequiredModule -Name 'Veeam.Backup.PowerShell' -Version '1.0'

        $MainGraphAttributes = @{
            pad = 1.0
            rankdir = $Dir
            overlap = 'false'
            splines = $EdgeType
            penwidth = 1.5
            fontname = "Segoe Ui Black"
            fontcolor = '#005f4b'
            fontsize = 32
            style = "dashed"
            labelloc = 't'
            imagepath = $IconPath
            nodesep = $NodeSeparation
            ranksep = $SectionSeparation
        }
    }

    process {

        foreach ($System in $Target) {

            Get-VbrServerConnection -Port $Port

            try {

                $script:VBRServer = Get-VBRServer -Type Local

            } Catch { throw "Unable to get Veeam B&R Server" }

            Get-VBRBackupServerInfo

            $script:Graph = Graph -Name VeeamVBR -Attributes $MainGraphAttributes {
                # Node default theme
                Node @{
                    label = ''
                    shape = 'none'
                    labelloc = 't'
                    style = 'filled'
                    fillColor = 'white'
                    fontsize = 14;
                    imagescale = $true
                }
                # Edge default theme
                Edge @{
                    style = 'dashed'
                    dir = 'both'
                    arrowtail = 'dot'
                    color = '#71797E'
                    penwidth = 1.5
                    arrowsize = 1
                }

                if ($Signature) {
                    if ($CustomSignatureLogo) {
                        $Signature = (Get-HtmlTable -Rows "Author: $($AuthorName)", "Company: $($CompanyName)" -TableBorder 2 -CellBorder 0 -align 'left' -Logo $CustomSignatureLogo)
                    } else {
                        $Signature = (Get-HtmlTable -Rows "Author: $($AuthorName)", "Company: $($CompanyName)" -TableBorder 2 -CellBorder 0 -align 'left' -Logo "VBR_LOGO_Footer")
                    }
                } else {
                    $Signature = " "
                }

                SubGraph OUTERDRAWBOARD1 -Attributes @{Label = $Signature; fontsize = 24; penwidth = 1.5; labelloc = 'b'; labeljust = "r"; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                    SubGraph MainGraph -Attributes @{Label = (Get-HTMLLabel -Label $MainGraphLabel -IconType $CustomLogo); fontsize = 24; penwidth = 0; labelloc = 't'; labeljust = "c" } {

                        if ($DiagramType -eq 'Backup-to-HyperV-Proxy') {
                            $BackuptoHyperVProxy = Get-DiagBackupToHvProxy | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackuptoHyperVProxy) {
                                $BackuptoHyperVProxy
                            } else {
                                Write-Warning "No HyperV Proxy Infrastructure available to diagram"
                            }
                        } elseif ($DiagramType -eq 'Backup-to-vSphere-Proxy') {
                            $BackuptovSphereProxy = Get-DiagBackupToViProxy | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackuptovSphereProxy) {
                                $BackuptovSphereProxy
                            } else {
                                Write-Warning "No vSphere Proxy Infrastructure available to diagram"
                            }
                        } elseif ($DiagramType -eq 'Backup-to-File-Proxy') {
                            $BackuptoFileProxy = Get-DiagBackupToFileProxy | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackuptoFileProxy) {
                                $BackuptoFileProxy
                            } else {
                                Write-Warning "No File Proxy Infrastructure available to diagram"
                            }
                        } elseif ($DiagramType -eq 'Backup-to-WanAccelerator') {
                            $BackuptoWanAccelerator = Get-DiagBackupToWanAccel | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackuptoWanAccelerator) {
                                $BackuptoWanAccelerator
                            } else {
                                Write-Warning "No Wan Accelerators available to diagram"
                            }
                        } elseif ($DiagramType -eq 'Backup-to-Repository') {
                            $BackuptoRepository = Get-DiagBackupToRepo | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackuptoRepository) {
                                $BackuptoRepository
                            } else {
                                throw "No Backup Repository available to diagram"
                            }
                        } elseif ($DiagramType -eq 'Backup-to-ProtectedGroup') {
                            $BackuptoProtectedGroup = Get-DiagBackupToProtectedGroup | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackuptoProtectedGroup) {
                                $BackuptoProtectedGroup
                            } else {
                                throw "No Backup Protected Group available to diagram"
                            }
                        } elseif ($DiagramType -eq 'Backup-to-Tape') {
                            $BackupToTape = Get-DiagBackupToTape | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackupToTape) {
                                $BackupToTape
                            } else {
                                Write-Warning "No Tape Infrastructure available to diagram"
                            }
                        } elseif ($DiagramType -eq 'Backup-to-Sobr') {
                            $BackuptoSobr = Get-DiagBackupToSobr | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackuptoSobr) {
                                $BackuptoSobr
                            } else {
                                throw "No Scale-Out Backup Repository available to diagram"
                            }
                        } elseif ($DiagramType -eq 'Backup-to-All') {
                            if (Get-DiagBackupToHvProxy) {
                                Get-DiagBackupToHvProxy | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            } else { Write-Warning "No HyperV Proxy Infrastructure available to diagram" }
                            if (Get-DiagBackupToViProxy) {
                                Get-DiagBackupToViProxy | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            } else { Write-Warning "No vSphere Proxy Infrastructure available to diagram" }

                            Get-DiagBackupToWanAccel | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            Get-DiagBackupToRepo | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            Get-DiagBackupToSobr | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            Get-DiagBackupToTape | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                        }
                    }
                }
            }
        }
    }
    end {
        #Export Diagram
        Out-VbrDiagram -GraphObj ($Graph | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch) -ErrorDebug $EnableErrorDebug -Rotate $Rotate
    }
}