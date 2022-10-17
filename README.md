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
    <a href='https://ko-fi.com/F1F8DEV80' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'            border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
</p>

# Veeam VBR Diagrammer

<!-- ********** REMOVE THIS MESSAGE WHEN THE MODULE IS FUNCTIONAL ********** -->
## :exclamation: THIS POWERSHELL MODULE IS CURRENTLY IN DEVELOPMENT AND MIGHT NOT YET BE FUNCTIONAL ❗

Veeam Diagrammer is a PowerShell module to automatically generate Veeam Backup & Replication topology diagrams by just typing a PowerShell cmdlet and passing the name of the Backup Server.

## This project is extensively based on the [`AzViz`](https://github.com/PrateekKumarSingh/AzViz) module.

> Special thanks & shoutout to [`Kevin Marquette`](https://twitter.com/KevinMarquette) and his [`PSGraph`](https://github.com/KevinMarquette/PSGraph) module and to [`Prateek Singh`](https://twitter.com/singhprateik) and his [`AzViz`](https://github.com/PrateekKumarSingh/AzViz) project without it work the Veeam.Diagrammer won't be possible!



## :books: Sample Diagram

### Scale-Out Backup Repository Diagram

![Scale-Out Backup Repository Diagram](https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/dev/Samples/Backup_SOBR.png "Scale-Out Backup Repository Diagram")

### Backup Repository Diagram

![Backup Repository Diagram](https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/dev/Samples/Backup_Repository.png "Backup Repository Diagram")

### Backup Proxy Diagram

![Backup Proxy Diagram](https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/dev/Samples/VBR_Backup_Proxy_with_Debug.png "Backup Proxy Diagram")


# :beginner: Getting Started

Below are the instructions on how to install, configure and generate a Veeam.Diagrammer diagram.

## :floppy_disk: Supported Versions
<!-- ********** Update supported Veeam versions ********** -->
The Veeam.Diagrammer supports the following Veeam Backup & Replication version;

- Veeam Backup & Replication V11 (Standard, Enterprise & Enterprise Plus Edition)

### :closed_lock_with_key: Required Privileges

Only users with Veeam Backup Administrator role assigned can generate a Diagram
### PowerShell

This project is compatible with the following PowerShell versions;

<!-- ********** Update supported PowerShell versions ********** -->
| Windows PowerShell 5.1 |     PowerShell 7    |
|:----------------------:|:--------------------:|
|   :white_check_mark:   | :x: |

## :wrench: System Requirements

PowerShell 5.1, and the following PowerShell modules are required for generating a Veeam.Diagrammer diagram.

- [Veeam.Backup.PowerShell Module](https://helpcenter.veeam.com/docs/backup/powershell/getting_started.html?ver=110)
- [PSGraph Module](https://github.com/KevinMarquette/PSGraph)

## What is GraphViz?

[Graphviz](http://graphviz.org/) is open source graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks. It has important applications in networking, bioinformatics,  software engineering, database and web design, machine learning, and in visual interfaces for other technical domains. 


We need to install GraphViz on our system before we can proceed with using the 'Veeam.Diagrammer' PowerShell module.
### Installing GraphViz
Make sure you are running Powershell 5.0 (WMF 5.0). I don't know that it is a hard requirement at the moment but I plan on using 5.0 features.

```powershell
# Install GraphViz from the Chocolatey repo
Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/
Find-Package graphviz | Install-Package -ForceBootstrap
```

## :package: Module Installation

### PowerShell

```powershell
# Install PSGraph from the Powershell Gallery
Install-Module -Name PSGraph

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

The `New-VeeamDiagram` cmdlet is used to generate a Veeam Backup & Replication diagram. The type of diagram to generate is specified by using the `DiagramType` parameter. The DiagramType parameter relies on additional diagram modules being created alongside the defaults module. The `Target` parameter specifies one or more Veeam VBR servers on which to connect and run the diagram. User credentials to the system are specifed using the `Credential`, or the `Username` and `Password` parameters. One or more document formats, such as `PNG`, `PDF`, `SVG`, `BASE64` or `DOT` can be specified using the `Format` parameter. Additional parameters are outlined below.

```powershell
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
    The supported output formats are BASE64, PDF, PNG, DOT & SVG.
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
    Control to enable edge debugging ( Dummy Edge and Node lines).
.PARAMETER EnableSubGraphDebug
    Control to enable subgraph debugging ( Subgraph Lines ).
```

For a full list of common parameters and examples you can view the `New-VeeamDiagram` cmdlet help with the following command;

```powershell
Get-Help New-VeeamDiagram -Full
```

## :computer: Examples

There are a few examples listed below on running the Veeam.Diagrammer script against a Veeam Backup Server. Refer to the `README.md` file in the main Veeam.Diagrammer project repository for more examples.

```powershell
# Generate a Veeam.Diagrammer diagram for Backup Server 'veeam-vbr.pharmax.local' using specified credentials. Export report to PDF & PNG formats. Use default report style. Save reports to 'C:\Users\Jon\Documents'
PS C:\> New-VeeamDiagram -DiagramType Backup-to-Proxy -Target veeam-vbr.pharmax.local -Username 'Domain\veeam_admin' -Password 'P@ssw0rd' -Format pdf,png -OutputFolderPath 'C:\Users\Jon\Documents'

# Generate a Veeam.Diagrammer diagram for Backup Server veeam-vbr.pharmax.local using stored credentials. Export report to DOT & SVG formats. Save reports to 'C:\Users\Jon\Documents'.
PS C:\> $Creds = Get-Credential
PS C:\> New-VeeamDiagram -DiagramType Backup-to-Proxy -Target veeam-vbr.pharmax.local -Credential $Creds -Format DOT,SVG -OutputFolderPath 'C:\Users\Jon\Documents'

```

## :x: Known Issues

- Since many of Veeam's features depend on the Standard+ license, the Community edition will not be supported.
