<p align="center">
    <a href="https://github.com/rebelinux/Veeam.Diagrammer" alt="Veeam.Diagrammer"></a>
            <img src='https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/dev/icons/verified_recoverability.png' width="8%" height="8%" /></a>
</p>
<p align="center">
    <a href="https://www.powershellgallery.com/packages/Veeam.Diagrammer/" alt="PowerShell Gallery Version">
        <img src="https://img.shields.io/powershellgallery/v/Veeam.Diagrammer.svg" /></a>
    <a href="https://www.powershellgallery.com/packages/Veeam.Diagrammer/" alt="PS Gallery Downloads">
        <img src="https://img.shields.io/powershellgallery/dt/Veeam.Diagrammer.svg" /></a>
    <a href="https://www.powershellgallery.com/packages/Veeam.Diagrammer/" alt="PS Platform">
        <img src="https://img.shields.io/powershellgallery/p/Veeam.Diagrammer.svg" /></a>
</p>
<p align="center">
    <a href="https://github.com/rebelinux/Veeam.Diagrammer/graphs/commit-activity" alt="GitHub Last Commit">
        <img src="https://img.shields.io/github/last-commit/rebelinux/Veeam.Diagrammer.svg" /></a>
    <a href="https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/master/LICENSE" alt="GitHub License">
        <img src="https://img.shields.io/github/license/rebelinux/Veeam.Diagrammer.svg" /></a>
    <a href="https://github.com/rebelinux/Veeam.Diagrammer/graphs/contributors" alt="GitHub Contributors">
        <img src="https://img.shields.io/github/contributors/rebelinux/Veeam.Diagrammer.svg"/></a>
</p>
<p align="center">
    <a href="https://twitter.com/jcolonfzenpr" alt="Twitter">
            <img src="https://img.shields.io/twitter/follow/jcolonfzenpr.svg?style=social"/></a>
</p>

<p align="center">
    <a href='https://ko-fi.com/F1F8DEV80' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://ko-fi.com/img/githubbutton_sm.svg' border='0' alt='Want to keep alive this project? Support me on Ko-fi' /></a>
</p>

> [!WARNING]
> I was recently contacted regarding the status of this project. Maintaining this report and the associated tools requires significant time and resources. If you would like to help keep this project active, please consider supporting its development by donating through Ko-fi.

# Veeam VBR Diagrammer

Veeam Diagrammer is a PowerShell module to automatically generate Veeam Backup & Replication topology diagrams by just typing a PowerShell cmdlet and passing the name of the Backup Server.

## This project is extensively based on the [`AzViz`](https://github.com/PrateekKumarSingh/AzViz) module.

> Special thanks & shoutout to [`Kevin Marquette`](https://twitter.com/KevinMarquette) and his [`PSGraph`](https://github.com/KevinMarquette/PSGraph) module and to [`Prateek Singh`](https://twitter.com/singhprateik) and his [`AzViz`](https://github.com/PrateekKumarSingh/AzViz) project without it work the Veeam.Diagrammer won't be possible!

## :books: Sample Diagram

### Scale-Out Backup Repository Diagram

![Scale-Out Backup Repository Diagram](https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/dev/Samples/Backup_SOBR.webp "Scale-Out Backup Repository Diagram")

### Backup Repository Diagram

![Backup Repository Diagram](https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/dev/Samples/Backup_Repository.webp "Backup Repository Diagram")

### Backup Infrastructure Diagram

![Backup Infrastructure Diagram](https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/dev/Samples/BackupInfastructure.webp "Backup Infrastructure Diagram")


# :beginner: Getting Started

Below are the instructions on how to install, configure and generate a Veeam.Diagrammer diagram.

## :floppy_disk: Supported Versions
<!-- ********** Update supported Veeam versions ********** -->
The Veeam.Diagrammer supports the following Veeam Backup & Replication version;

- Veeam Backup & Replication v12+ (Standard, Enterprise & Enterprise Plus Edition)

### :closed_lock_with_key: Required Privileges

Only users with Veeam Backup Administrator role assigned can generate a Diagram

### PowerShell

This project is compatible with the following PowerShell versions;

<!-- ********** Update supported PowerShell versions ********** -->
| Windows PowerShell 5.1 | PowerShell 7 |
| :--------------------: | :----------: |
|   :white_check_mark:   |     :x:      |

## :wrench: System Requirements

PowerShell 5.1, and the following PowerShell modules are required for generating a Veeam.Diagrammer diagram.

- [Veeam.Backup.PowerShell Module](https://helpcenter.veeam.com/docs/backup/powershell/getting_started.html?ver=110)
- [PSGraph Module](https://github.com/KevinMarquette/PSGraph)
- [Diagrammer.Core Module](https://github.com/rebelinux/Diagrammer.Core)


## What is GraphViz?

[Graphviz](http://graphviz.org/) is open source graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks. It has important applications in networking, bioinformatics,  software engineering, database and web design, machine learning, and in visual interfaces for other technical domains. 

No need to install GraphViz on your system because from now on it's libraries are included in the local module path.

## :package: Module Installation

### PowerShell

```powershell

# Install Veeam.Diagrammer from the Powershell Gallery
install-module -Name Veeam.Diagrammer

```

### GitHub

If you are unable to use the PowerShell Gallery, you can still install the module manually. Ensure you repeat the following steps for the [system requirements](https://github.com/rebelinux/Veeam.Diagrammer#wrench-system-requirements) also.

1. Download the code package / [latest release](https://github.com/rebelinux/Veeam.Diagrammer/releases/latest) zip from GitHub
2. Extract the zip file
3. Copy the folder `Veeam.Diagrammer` to a path that is set in `$env:PSModulePath`.
4. Open a PowerShell terminal window and unblock the downloaded files with

    ```powershell
    $path = (Get-Module -Name Veeam.Diagrammer -ListAvailable).ModuleBase; Unblock-File -Path $path\*.psd1; Unblock-File -Path $path\Src\Public\*.ps1; Unblock-File -Path $path\Src\Private\*.ps1
    ```

5. Close and reopen the PowerShell terminal window.

_Note: You are not limited to installing the module to those example paths, you can add a new entry to the environment variable PSModulePath if you want to use another path._


## :pencil2: Commands

### **New-VeeamDiagram**

The `New-VeeamDiagram` cmdlet is used to generate a Veeam Backup & Replication diagram. The type of diagram to generate is specified by using the `DiagramType` parameter. The DiagramType parameter relies on additional diagram modules being created alongside the defaults module. The `Target` parameter specifies one or more Veeam VBR servers on which to connect and run the diagram. User credentials to the system are specified using the `Credential`, or the `Username` and `Password` parameters. One or more document formats, such as `PNG`, `PDF`, `SVG`, `BASE64` or `DOT` can be specified using the `Format` parameter. Additional parameters are outlined below.

```markdown
    .PARAMETER DiagramType
        Specifies the type of Veeam VBR diagram to generate.
        Supported values:
            - 'Backup-to-Sobr'
            - 'Backup-to-vSphere-Proxy'
            - 'Backup-to-HyperV-Proxy'
            - 'Backup-to-Repository'
            - 'Backup-to-WanAccelerator'
            - 'Backup-to-Tape'
            - 'Backup-to-File-Proxy'
            - 'Backup-to-ProtectedGroup'
            - 'Backup-Infrastructure'
            - 'Backup-to-CloudConnect'
            - 'Backup-to-CloudConnect-Tenant'

    .PARAMETER Target
        One or more IP addresses or FQDNs of Veeam VBR servers to connect to.
        Multiple targets can be specified, separated by commas.

    .PARAMETER Port
        Optional. The port number for connecting to the Veeam VBR Service.
        Default: 9392

    .PARAMETER Credential
        A PSCredential object containing the username and password for authentication to the target system.

    .PARAMETER Username
        The username for authenticating to the target system. Used if Credential is not provided.

    .PARAMETER Password
        The password for authenticating to the target system. Used if Credential is not provided.

    .PARAMETER Format
        Specifies one or more output formats for the generated diagram.
        Supported values: PDF, PNG, DOT, SVG
        Multiple formats can be specified, separated by commas.

    .PARAMETER Direction
        Sets the layout direction of the diagram.
        Supported values: 'top-to-bottom', 'left-to-right'
        Default: 'top-to-bottom'

    .PARAMETER Theme
        Sets the visual theme of the diagram.
        Supported values: 'Black', 'White', 'Neon'
        Default: 'White'

    .PARAMETER NodeSeparation
        Adjusts the spacing between nodes in the diagram.
        Default: 0.60

    .PARAMETER SectionSeparation
        Adjusts the spacing between sections (subgraphs) in the diagram.
        Default: 0.75

    .PARAMETER EdgeType
        Defines the style of edge lines connecting nodes.
        Supported values: 'polyline', 'curved', 'ortho', 'line', 'spline'
        Default: 'spline'
        See: https://graphviz.org/docs/attrs/splines/

    .PARAMETER OutputFolderPath
        The directory path where the generated diagram files will be saved.

    .PARAMETER Filename
        The base filename for the generated diagram files.

    .PARAMETER DraftMode
        Switch. Enables debugging visualization for subgraphs, edges & nodes.

    .PARAMETER EnableErrorDebug
        Switch. Enables detailed error debugging output.

    .PARAMETER AuthorName
        The name of the author to include in the diagram footer signature.

    .PARAMETER CompanyName
        The company name to include in the diagram footer signature.

    .PARAMETER Logo
        Path to a custom logo image to replace the default Veeam logo.
        Recommended size: 400px x 100px or smaller.

    .PARAMETER SignatureLogo
        Path to a custom signature logo image for the diagram footer.
        Recommended size: 120px x 130px or smaller.

    .PARAMETER Signature
        Switch. Adds a footer signature to the diagram. Requires AuthorName and CompanyName.

    .PARAMETER WatermarkText
        Text to be used as a watermark on the output image (not supported for SVG format).

    .PARAMETER WatermarkColor
        The color of the watermark text.
        Default: 'Green'

    .PARAMETER ColumnSize
        Sets the number of columns in the node table layout.
        Default: 4

    .PARAMETER NewIcons
        Switch. Enables the use of new icons for the diagram (default: false).
```

For a full list of common parameters and examples you can view the `New-VeeamDiagram` cmdlet help with the following command;

```powershell
Get-Help New-VeeamDiagram -Full
```

## :computer: Examples

There are a few examples listed below on running the Veeam.Diagrammer script against a Veeam Backup Server. Refer to the `README.md` file in the main Veeam.Diagrammer project repository for more examples.

```powershell
# Generate a Veeam.Diagrammer diagram for Backup Server 'veeam-vbr.pharmax.local' using specified credentials. Export report to PDF & PNG formats. Use default report style. Save reports to 'C:\Users\Jon\Documents'
PS C:\> New-VeeamDiagram -DiagramType Backup-to-SOBR -Target veeam-vbr.pharmax.local -Username 'Domain\veeam_admin' -Password 'P@ssw0rd' -Format pdf,png -OutputFolderPath 'C:\Users\Jon\Documents'

# Generate a Veeam.Diagrammer diagram for Backup Server veeam-vbr.pharmax.local using stored credentials. Export report to DOT & SVG formats. Save reports to 'C:\Users\Jon\Documents'.
PS C:\> $Creds = Get-Credential
PS C:\> New-VeeamDiagram -DiagramType Backup-to-SOBR -Target veeam-vbr.pharmax.local -Credential $Creds -Format dot,pdf -OutputFolderPath 'C:\Users\Jon\Documents'

```

## :x: Known Issues

- Since many of Veeam's features depend on the Standard+ license, the Community edition is not supported.
