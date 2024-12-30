function Get-VbrRequiredModule {
    <#
    .SYNOPSIS
        Function to check if the required version of Veeam.Backup.PowerShell is installed
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
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Version
    )
    process {
        #region: Start Load VEEAM Snapin / Module
        # Loading Module or PSSnapin
        # Make sure PSModulePath includes Veeam Console
        $MyModulePath = "C:\Program Files\Veeam\Backup and Replication\Console\"
        if (-not (Get-Module -ListAvailable -Name Veeam.Backup.PowerShell)) {
            $env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$MyModulePath"
        }

        try {
            Write-Verbose -Message "Trying to import Veeam B&R modules."
            Import-Module -Name Veeam.Backup.PowerShell -ErrorAction Stop -WarningAction SilentlyContinue -Verbose:$false
        } catch {
            Write-Verbose -Message "Failed to load Veeam Modules, trying SnapIn."
            try {
                Add-PSSnapin -Name VeeamPSSnapIn -ErrorAction Stop | Out-Null
            } catch {
                throw "Failed to load VeeamPSSnapIn and no Modules found"
            }
        }

        $Module = Get-Module -Name Veeam.Backup.PowerShell
        if ($Module) {
            $VbrVersion = $Module.Version.ToString()
            Write-Verbose -Message "Using Veeam Powershell module version $($VbrVersion)."
        } else {
            $VbrVersion = (Get-PSSnapin VeeamPSSnapin -ErrorAction SilentlyContinue).PSVersion.ToString()
            Write-Verbose -Message "Using Veeam SnapIn version $($VbrVersion)."
        }

        # Check if the required version of the specified module is installed
        $RequiredModule = Get-Module -ListAvailable -Name $Name | Sort-Object -Property Version -Descending | Select-Object -First 1
        if (-not $RequiredModule) {
            throw "$Name $Version or higher is required to run the Veeam VBR As Built Report. Install the Veeam Backup & Replication console that provides the required modules."
        }

        $ModuleVersion = [version]$RequiredModule.Version
        if ($ModuleVersion -lt [version]$Version) {
            throw "$Name $Version or higher is required to run the Veeam.Diagrammer. Update the Veeam Backup & Replication console that provides the required modules."
        }
    }
    end {}
}
