function New-VeeamDiagram {

    [Diagnostics.CodeAnalysis.SuppressMessage(
        'PSUseShouldProcessForStateChangingFunctions',
        ''
    )]

    [CmdletBinding()]

    param (

        # Names of target Veeam Backup Server
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

        # TCP Port of target Veeam Backup Server
        [Parameter(Mandatory = $false)]
        [string] $Port = '9392',

        # Output format of the vizualization
        [ValidateSet('pdf', 'svg', 'png', 'dot')]
        [string] $OutputFormat = 'pdf',

        # Direction in which resource groups are plotted on the visualization
        [ValidateSet('left-to-right', 'top-to-bottom')]
        [string] $Direction = 'top-to-bottom',

        # Output file path
        [ValidateScript( { Test-Path -Path $_ -IsValid })]
        [string] $OutputFilePath = (Join-Path ([System.IO.Path]::GetTempPath()) "output.$OutputFormat"),

        # Controls how edges appear in visualization
        [ValidateSet('polyline', 'curved', 'ortho', 'line', 'spline')]
        [string] $EdgeType = 'ortho',

        # type of resources to be excluded in the visualization
        [ValidateNotNullOrEmpty()]
        [string[]] $ExcludeTypes,

        # Direction in which resource groups are plotted on the visualization
        [ValidateSet(0, 1, 2, 3)]
        [string] $NodeSeparation = .60,

        # Direction in which resource groups are plotted on the visualization
        [ValidateSet(0, 1, 2, 3)]
        [string] $SectionSeparation = .75,

        # Direction in which resource groups are plotted on the visualization
        [ValidateSet('fill', 'compress')]
        [string] $Ratio = 'fill',

        # Type of generated diagram
        [ValidateSet('Backup-to-Proxy', 'Backup-to-Repository', 'Backup-to-Sobr', 'Backup-to-WanAccelerator', 'Backup-to-All')]
        [string] $DiagramType = 'Backup-to-All'
    )


    begin {

        # If Username and Password parameters used, convert specified Password to secure string and store in $Credential
        if (($Username -and $Password)) {
            $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
        }

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
            fontname  = "Comic Sans MS bold"
            fontcolor = '#005f4b'
            fontsize  = 32
            style = "dashed"
            ratio = $Ratio
            labelloc = 't'
            imagepath = $IconPath
            nodesep = $NodeSeparation
            ranksep = $SectionSeparation
        }
    }

    process {

        foreach ($System in $Target) {

            Get-VbrServerConnection

            $VBRServer = Get-VBRServer -Type Local

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
                    group = "main"
                }
                # Edge default theme
                edge @{
                    style = 'dashed'
                    dir = 'both'
                    arrowtail = 'dot'
                    color = '#71797E'
                    penwidth = 1.5
                    arrowsize = 2
                }

                $MainGraphLabel = Switch ($DiagramType) {
                    'Backup-to-Sobr' {'Scale-Out Backup Repository Diagram'}
                    'Backup-to-Proxy' {'Backup Proxy Diagram'}
                    'Backup-to-Repository' {'Backup Repository Diagram'}
                    'Backup-to-WanAccelerator' {'Wan Accelerators Diagram'}
                    'Backup-to-All' {'Backup Infrastructure Diagram'}
                }

                SubGraph MainGraph -Attributes @{Label=(Get-HTMLLabel -Label $MainGraphLabel -Type "VBR_LOGO" ); fontsize=24; penwidth=0} {

                    SubGraph BackupServer -Attributes @{Label='Backup Server'; style="rounded"; bgcolor="#ceedc4"; fontsize=18; penwidth=2} {
                        $BSHASHTABLE = @{}
                        $BackupServerInfo.psobject.properties | ForEach-Object { $BSHASHTABLE[$_.Name] = $_.Value }
                        node $BackupServerInfo.Name -Attributes @{Label=$BSHASHTABLE.Label; fillColor='#ceedc4'}
                        if ($DatabaseServerInfo) {
                            $DBHASHTABLE = @{}
                            $DatabaseServerInfo.psobject.properties | ForEach-Object { $DBHASHTABLE[$_.Name] = $_.Value }
                            node  $DatabaseServerInfo.Name -Attributes @{Label=$DBHASHTABLE.Label; fillColor='#ceedc4'}
                            rank $BackupServerInfo.Name,$DatabaseServerInfo.Name
                            if ($Dir -eq 'LR') {
                                edge -from $DatabaseServerInfo.Name -to $BackupServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3; xlabel=$DatabaseServerInfo.DBPort}
                            } else {
                                edge -from $BackupServerInfo.Name -to $DatabaseServerInfo.Name @{arrowtail="normal"; arrowhead="normal"; minlen=3; xlabel=$DatabaseServerInfo.DBPort}
                            }
                        }
                        else {
                            edge $BackupServerInfo
                        }
                    }

                    if ($DiagramType -eq 'Backup-to-Proxy') {
                        Get-DiagBackupToProxy
                    }
                    elseif ($DiagramType -eq 'Backup-to-WanAccelerator') {
                        Get-DiagBackupToWanAccel
                    }
                    elseif ($DiagramType -eq 'Backup-to-Repository') {
                        Get-DiagBackupToRepo
                    }
                    elseif ($DiagramType -eq 'Backup-to-Sobr') {
                        Get-DiagBackupToSobr
                    }
                    elseif ($DiagramType -eq 'Backup-to-All') {
                        Get-DiagBackupToProxy
                        Get-DiagBackupToWanAccel
                        Get-DiagBackupToRepo
                        Get-DiagBackupToSobr
                    }
                }

            }


            $Graph | Export-PSGraph -DestinationPath $OutputFilePath -OutputFormat $OutputFormat

        }

    }
    end {}
}