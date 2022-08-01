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
    <a href="https://twitter.com/jcolonfzenr" alt="Twitter">
            <img src="https://img.shields.io/twitter/follow/jcolonfzenpr.svg?style=social"/></a>
</p>
<p align="center">
    <a href='https://ko-fi.com/F1F8DEV80' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'            border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
</p>

# Veeam VBR Diagrammer

Veeam VBR As Built Report is a PowerShell module to automatically generate Veeam Backup & Replication topology diagrams by just typing a PowerShell cmdlet and passing the name of the Backup Server.


# :books: Sample Diagram

## Scale-Out Backup Repository Diagram

![Scale-Out Backup Repository Diagram](https://raw.githubusercontent.com/rebelinux/Veeam.Diagrammer/dev/Samples/Backup_SOBR.png "Scale-Out Backup Repository Diagram")


# :beginner: Getting Started

Below are the instructions on how to install, configure and generate a Veeam VBR As Built report.

## :floppy_disk: Supported Versions
<!-- ********** Update supported Veeam versions ********** -->
The Veeam.Diagrammer supports the following Veeam Backup & Replication version;

- Veeam Backup & Replication V11 (Standard, Enterprise & Enterprise Plus Edition)

### PowerShell

This project is compatible with the following PowerShell versions;

<!-- ********** Update supported PowerShell versions ********** -->
| Windows PowerShell 5.1 |     PowerShell 7    |
|:----------------------:|:--------------------:|
|   :white_check_mark:   | :x: |

## :wrench: System Requirements

PowerShell 5.1, and the following PowerShell modules are required for generating a Veeam VBR As Built report.

- [Veeam.Backup.PowerShell Module](https://helpcenter.veeam.com/docs/backup/powershell/getting_started.html?ver=110)

### :closed_lock_with_key: Required Privileges

Only users with Veeam Backup Administrator role assigned can generate a Diagram

## :package: Module Installation

### PowerShell

```powershell
install-module Veeam.Diagrammer
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

## :computer: Examples

There are a few examples listed below on running the AsBuiltReport script against a Veeam Backup Server. Refer to the `README.md` file in the main AsBuiltReport project repository for more examples.

```powershell
# Generate a Veeam VBR As Built Report for Backup Server 'veeam-vbr.pharmax.local' using specified credentials. Export report to HTML & DOCX formats. Use default report style. Append timestamp to report filename. Save reports to 'C:\Users\Jon\Documents'
PS C:\> New-AsBuiltReport -Report Veeam.VBR -Target veeam-vbr.pharmax.local -Username 'Domain\veeam_admin' -Password 'P@ssw0rd' -Format Html,Word -OutputFolderPath 'C:\Users\Jon\Documents' -Timestamp

# Generate a Veeam VBR As Built Report for Backup Server veeam-vbr.pharmax.local using specified credentials and report configuration file. Export report to Text, HTML & DOCX formats. Use default report style. Save reports to 'C:\Users\Jon\Documents'. Display verbose messages to the console.
PS C:\> New-AsBuiltReport -Report Veeam.VBR -Target veeam-vbr.pharmax.local -Username 'Domain\veeam_admin' -Password 'P@ssw0rd' -Format Text,Html,Word -OutputFolderPath 'C:\Users\Jon\Documents' -ReportConfigFilePath 'C:\Users\Jon\AsBuiltReport\AsBuiltReport.Veeam.VBR.json' -Verbose

# Generate a Veeam VBR As Built Report for Backup Server veeam-vbr.pharmax.local using stored credentials. Export report to HTML & Text formats. Use default report style. Highlight environment issues within the report. Save reports to 'C:\Users\Jon\Documents'.
PS C:\> $Creds = Get-Credential
PS C:\> New-AsBuiltReport -Report Veeam.VBR -Target veeam-vbr.pharmax.local -Credential $Creds -Format Html,Text -OutputFolderPath 'C:\Users\Jon\Documents' -EnableHealthCheck

# Generate a Veeam VBR As Built Report for Backup Server veeam-vbr.pharmax.local using stored credentials. Export report to HTML & DOCX formats. Use default report style. Reports are saved to the user profile folder by default. Attach and send reports via e-mail.
PS C:\> New-AsBuiltReport -Report Veeam.VBR -Target veeam-vbr.pharmax.local -Username 'Domain\veeam_admin' -Password 'P@ssw0rd' -Format Html,Word -OutputFolderPath 'C:\Users\Jon\Documents' -SendEmail

```

## :x: Known Issues

- Since many of Veeam's features depend on the Standard+ license, the Community edition will not be supported.
