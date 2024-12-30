function New-VeeamDiagram {
    <#
    .SYNOPSIS
        Diagram the configuration of Veeam Backup & Replication infrastructure in PDF, SVG, DOT, and PNG formats using PSGraph and Graphviz.

    .DESCRIPTION
        This script generates diagrams of the Veeam Backup & Replication infrastructure in various formats (PDF, SVG, DOT, PNG) using PSGraph and Graphviz. It provides detailed visualization of the backup infrastructure, including different components and their relationships.

    .PARAMETER DiagramType
        Specifies the type of Veeam VBR diagram to generate.
        Supported types:
            'Backup-to-Sobr', 'Backup-to-vSphere-Proxy', 'Backup-to-HyperV-Proxy',
            'Backup-to-Repository', 'Backup-to-WanAccelerator', 'Backup-to-Tape',
            'Backup-to-File-Proxy', 'Backup-to-ProtectedGroup', 'Backup-Infrastructure'

    .PARAMETER Target
        Specifies the IP address or FQDN of the system to connect to.
        Multiple targets can be specified, separated by commas.

    .PARAMETER Port
        Specifies an optional port to connect to the Veeam VBR Service.
        Default: 9392

    .PARAMETER Credential
        Specifies the stored credential for the target system.

    .PARAMETER Username
        Specifies the username for the target system.

    .PARAMETER Password
        Specifies the password for the target system.

    .PARAMETER Format
        Specifies the output format of the diagram.
        Supported formats: PDF, PNG, DOT, SVG
        Multiple formats can be specified, separated by commas.

    .PARAMETER Direction
        Sets the direction in which resources are plotted in the visualization.
        Supported directions: 'top-to-bottom', 'left-to-right'
        Default: top-to-bottom

    .PARAMETER Theme
        Sets the theme of the diagram.
        Supported themes: 'Black', 'White', 'Neon'
        Default: White

    .PARAMETER NodeSeparation
        Controls the node separation ratio in the visualization.
        Default: 0.60

    .PARAMETER SectionSeparation
        Controls the section (subgraph) separation ratio in the visualization.
        Default: 0.75

    .PARAMETER EdgeType
        Controls how edge lines appear in the visualization.
        Supported types: 'polyline', 'curved', 'ortho', 'line', 'spline'
        Default: spline
        References: https://graphviz.org/docs/attrs/splines/

    .PARAMETER OutputFolderPath
        Specifies the folder path to save the diagram.

    .PARAMETER Filename
        Specifies a filename for the diagram.

    .PARAMETER EnableEdgeDebug
        Enables edge debugging (dummy edge and node lines).

    .PARAMETER EnableSubGraphDebug
        Enables subgraph debugging (subgraph lines).

    .PARAMETER EnableErrorDebug
        Enables error debugging.

    .PARAMETER AuthorName
        Sets the footer signature author name.

    .PARAMETER CompanyName
        Sets the footer signature company name.

    .PARAMETER Logo
        Changes the Veeam logo to a custom one.
        Image should be 400px x 100px or smaller.

    .PARAMETER SignatureLogo
        Changes the Veeam.Diagrammer signature logo to a custom one.
        Image should be 120px x 130px or smaller.

    .PARAMETER Signature
        Creates a footer signature.
        AuthorName and CompanyName must be set to use this property.

    .PARAMETER WatermarkText
        Adds a watermark to the output image (not supported in SVG format).

    .PARAMETER WatermarkColor
        Specifies the color used for the watermark text.
        Default: Green

    .NOTES
        Version:        0.6.9
        Author(s):      Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
        Credits:        Kevin Marquette (@KevinMarquette) - PSGraph module
                        Prateek Singh (@PrateekKumarSingh) - AzViz module

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

    #Requires -Version 5.1
    #Requires -PSEdition Desktop
    #Requires -RunAsAdministrator

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
            HelpMessage = 'Use it to set the diagram theme. (Black/White/Neon)'
        )]
        [ValidateSet('Black', 'White', 'Neon')]
        [string] $DiagramTheme = 'White',

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
        [ValidateSet('Backup-to-Tape', 'Backup-to-File-Proxy', 'Backup-to-HyperV-Proxy', 'Backup-to-vSphere-Proxy', 'Backup-to-Repository', 'Backup-to-Sobr', 'Backup-to-WanAccelerator', 'Backup-to-ProtectedGroup', 'Backup-Infrastructure')]
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
        [Switch] $Signature = $false,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow to add a watermark to the output image (Not supported in svg format)'
        )]
        [string] $WaterMarkText,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow to specified the color used for the watermark text'
        )]
        [string] $WaterMarkColor = 'Green'
    )


    begin {

        $Verbose = if ($PSBoundParameters.ContainsKey('Verbose')) {
            $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent
        } else {
            $false
        }

        if ($EnableErrorDebug) {
            $global:VerbosePreference = 'Continue'
            $global:DebugPreference = 'Continue'
        } else {
            $global:VerbosePreference = 'SilentlyContinue'
            $global:DebugPreference = 'SilentlyContinue'
        }

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
            'Backup-Infrastructure' { 'Backup Infrastructure Diagram' }
        }
        if ($Format -ne 'Base64') {
            Write-ColorOutput -Color 'Green' -String ("Please wait while the '{0}' is being generated." -f $MainGraphLabel)
        }

        $IconDebug = $false

        if ($EnableEdgeDebug) {
            $script:EdgeDebug = @{style = 'filled'; color = 'red' }
            $IconDebug = $true
        } else { $script:EdgeDebug = @{style = 'invis'; color = 'red' } }

        if ($EnableSubGraphDebug) {
            $script:SubGraphDebug = @{style = 'dashed'; color = 'red' }
            $script:NodeDebug = @{color = 'black'; style = 'red'; shape = 'plain' }
            $script:NodeDebugEdge = @{color = 'black'; style = 'red'; shape = 'plain' }
            $IconDebug = $true
        } else {
            $script:SubGraphDebug = @{style = 'invis'; color = 'gray' }
            $script:NodeDebug = @{color = 'transparent'; style = 'transparent'; shape = 'point' }
            $script:NodeDebugEdge = @{color = 'transparent'; style = 'transparent'; shape = 'none' }
        }

        # Used to set diagram theme
        if ($DiagramTheme -eq 'Black') {
            $MainGraphBGColor = 'Black'
            $Edgecolor = 'White'
            $Fontcolor = 'White'
            $NodeFontcolor = 'White'
            $EdgeArrowSize = 1
            $EdgeLineWidth = 3
            $BackupServerBGColor = 'Black'
            $BackupServerFontColor = 'White'
        } elseif ($DiagramTheme -eq 'Neon') {
            $MainGraphBGColor = 'grey14'
            $Edgecolor = 'gold2'
            $Fontcolor = 'gold2'
            $NodeFontcolor = 'gold2'
            $EdgeArrowSize = 1
            $EdgeLineWidth = 3
            $BackupServerBGColor = 'grey14'
            $BackupServerFontColor = 'gold2'
        } elseif ($DiagramTheme -eq 'White') {
            $MainGraphBGColor = 'White'
            $Edgecolor = '#71797E'
            $Fontcolor = '#565656'
            $NodeFontcolor = 'Black'
            $EdgeArrowSize = 1
            $EdgeLineWidth = 3
            $BackupServerBGColor = '#ceedc4'
            $BackupServerFontColor = '#005f4b'
        }

        $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $IconPath = Join-Path $RootPath 'icons'

        if ($DiagramType -eq 'Backup-Infrastructure') {

            $Dir = 'TB'
        } else {
            $Dir = switch ($Direction) {
                'top-to-bottom' { 'TB' }
                'left-to-right' { 'LR' }
            }
        }

        # Validate Custom logo
        if ($Logo) {
            $CustomLogo = Test-Logo -LogoPath (Get-ChildItem -Path $Logo).FullName -IconPath $IconPath -ImagesObj $Images
        } else {
            $CustomLogo = "VBR_Logo"
        }
        # Validate Custom Signature Logo
        if ($SignatureLogo) {
            $CustomSignatureLogo = Test-Logo -LogoPath (Get-ChildItem -Path $SignatureLogo).FullName -IconPath $IconPath -ImagesObj $Images
        }

        # Validate Veeam Powershell Module
        Get-VbrRequiredModule -Name 'Veeam.Backup.PowerShell' -Version '1.0'

        $MainGraphAttributes = @{
            pad = 1.0
            rankdir = $Dir
            overlap = 'false'
            splines = $EdgeType
            penwidth = 1.5
            fontname = "Segoe Ui Black"
            fontcolor = $Fontcolor
            fontsize = 32
            style = "dashed"
            labelloc = 't'
            imagepath = $IconPath
            nodesep = $NodeSeparation
            ranksep = $SectionSeparation
            bgcolor = $MainGraphBGColor

        }
    }

    process {

        foreach ($System in $Target) {

            Get-VbrServerConnection -Port $Port

            try {

                $script:VBRServer = Get-VBRServer -Type Local

            } Catch { throw "Unable to get Veeam Backup & Replication Server: $System" }

            Get-VBRBackupServerInfo

            $script:Graph = Graph -Name VeeamVBR -Attributes $MainGraphAttributes {
                # Node default theme
                Node @{
                    label = ''
                    shape = 'none'
                    labelloc = 't'
                    style = 'filled'
                    fillColor = 'transparent'
                    fontsize = $NodeFontSize
                    imagescale = $true
                    fontcolor = $NodeFontcolor
                }
                # Edge default theme
                Edge @{
                    style = 'dashed'
                    dir = 'both'
                    arrowtail = 'dot'
                    color = $Edgecolor
                    penwidth = $EdgeLineWidth
                    arrowsize = $EdgeArrowSize
                    fontcolor = $Edgecolor
                }

                if ($Signature) {
                    Write-Verbose "Generating diagram signature"
                    if ($CustomSignatureLogo) {
                        $Signature = (Get-DiaHtmlSignatureTable -ImagesObj $Images -Rows "Author: $($AuthorName)", "Company: $($CompanyName)" -TableBorder 2 -CellBorder 0 -Align 'left' -Logo $CustomSignatureLogo -IconDebug $IconDebug)
                    } else {
                        $Signature = (Get-DiaHtmlSignatureTable -ImagesObj $Images -Rows "Author: $($AuthorName)", "Company: $($CompanyName)" -TableBorder 2 -CellBorder 0 -Align 'left' -Logo "VBR_LOGO_Footer" -IconDebug $IconDebug)
                    }
                } else {
                    Write-Verbose "No diagram signature specified"
                    $Signature = " "
                }

                SubGraph OUTERDRAWBOARD1 -Attributes @{Label = $Signature; fontsize = 24; penwidth = 1.5; labelloc = 'b'; labeljust = "r"; style = $SubGraphDebug.style; color = $SubGraphDebug.color } {
                    SubGraph MainGraph -Attributes @{Label = (Get-DiaHTMLLabel -ImagesObj $Images -Label $MainGraphLabel -IconType $CustomLogo -IconDebug $IconDebug -IconWidth 300 -IconHeight 54); fontsize = 24; penwidth = 0; labelloc = 't'; labeljust = "c" } {

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
                        } elseif ($DiagramType -eq 'Backup-Infrastructure') {
                            $BackupInfra = Get-VbrInfraDiagram | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch
                            if ($BackupInfra) {
                                $BackupInfra
                            } else {
                                throw "No Backup Infrastructure available to diagram"
                            }
                        }
                    }
                }
            }
        }
    }
    end {
        #Export Diagram
        foreach ($OutputFormat in $Format) {

            $OutputDiagram = Export-Diagrammer -GraphObj ($Graph | Select-String -Pattern '"([A-Z])\w+"\s\[label="";style="invis";shape="point";]' -NotMatch) -ErrorDebug $EnableErrorDebug -Format $OutputFormat -Filename $Filename -OutputFolderPath $OutputFolderPath -WaterMarkText $WaterMarkText -WaterMarkColor $WaterMarkColor -IconPath $IconPath -Verbose:$Verbose -Rotate $Rotate

            if ($OutputDiagram) {
                if ($OutputFormat -ne 'Base64') {
                    # If not Base64 format return image path
                    Write-ColorOutput -Color 'White' -String ("Diagrammer diagram '{0}' has been saved to '{1}'" -f $OutputDiagram.Name, $OutputDiagram.Directory)
                } else {
                    Write-Verbose "Displaying Base64 string"
                    # Return Base64 string
                    $OutputDiagram
                }
            }
        }

        if ($EnableErrorDebug) {
            $global:VerbosePreference = 'SilentlyContinue'
            $global:DebugPreference = 'SilentlyContinue'
        }
    }
}