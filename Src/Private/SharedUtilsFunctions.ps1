function Get-IconType {
    <#
    .SYNOPSIS
        Translates repository type to icon type object for Veeam.Diagrammer.

    .DESCRIPTION
        The Get-IconType function takes a repository type as input and returns the corresponding icon type object.
        This is used by Veeam.Diagrammer to map different repository types to their respective icons.

    .PARAMETER String
        The repository type as a string. Possible values include:
        - LinuxLocal
        - Hardened
        - LinuxHardened
        - WinLocal
        - Cloud
        - GoogleCloudStorage
        - AmazonS3Compatible
        - AmazonS3Glacier
        - AmazonS3
        - AzureArchive
        - AzureBlob
        - DDBoost
        - HPStoreOnceIntegration
        - ExaGrid
        - SanSnapshotOnly
        - Proxy
        - ProxyServer
        - ESXi
        - HyperVHost
        - ManuallyDeployed
        - IndividualComputers
        - ActiveDirectory
        - CSV
        - CifsShare
        - Nfs
        - Netapp
        - Dell
        - VirtualLab
        - ApplicationGroups

    .EXAMPLE
        PS C:\> Get-IconType -String 'LinuxLocal'
        VBR_Linux_Repository

        This example translates the 'LinuxLocal' repository type to its corresponding icon type 'VBR_Linux_Repository'.

    .LINK
        https://github.com/jocolon/Veeam.Diagrammer
    #>
    param(
        [string]$String
    )

    $IconType = Switch ($String) {
        'LinuxLocal' { 'VBR_Linux_Repository' }
        'Hardened' { 'VBR_Linux_Repository' }
        'LinuxHardened' { 'VBR_Linux_Repository' }
        'WinLocal' { 'VBR_Windows_Repository' }
        'Cloud' { 'VBR_Cloud_Repository' }
        'GoogleCloudStorage' { 'VBR_Amazon_S3_Compatible' }
        'AmazonS3Compatible' { 'VBR_Amazon_S3_Compatible' }
        'AmazonS3Glacier' { 'VBR_Amazon_S3_Compatible' }
        'AmazonS3' { 'VBR_Amazon_S3' }
        'AzureArchive' { 'VBR_Azure_Blob' }
        'AzureBlob' { 'VBR_Azure_Blob' }
        'DDBoost' { 'VBR_Deduplicating_Storage' }
        'HPStoreOnceIntegration' { 'VBR_Deduplicating_Storage' }
        'ExaGrid' { 'VBR_Deduplicating_Storage' }
        'SanSnapshotOnly' { 'VBR_Storage_NetApp' }
        'Proxy' { 'VBR_Repository' }
        'ProxyServer' { 'VBR_Proxy_Server' }
        'ESXi' { 'VBR_ESXi_Server' }
        'HyperVHost' { 'Hyper-V_host' }
        'ManuallyDeployed' { 'VBR_AGENT_MC' }
        'IndividualComputers' { 'VBR_AGENT_IC' }
        'ActiveDirectory' { 'VBR_AGENT_AD' }
        'CSV' { 'VBR_AGENT_CSV' }
        'CifsShare' { 'VBR_NAS' }
        'Nfs' { 'VBR_NAS' }
        'Netapp' { 'VBR_NetApp' }
        'Dell' { 'VBR_Dell' }
        'VirtualLab' { 'VBR_Virtual_Lab' }
        'ApplicationGroups' { 'VBR_Application_Groups' }
        'ExtendableRepository' { 'VBR_SOBR_Repo' }
        default { 'VBR_No_Icon' }
    }

    return $IconType
}

function Get-RoleType {
    <#
    .SYNOPSIS
        Translates a role type string to a function type object.

    .DESCRIPTION
        The Get-RoleType function takes a string input representing a role type and translates it into a more descriptive function type object. This is used by Veeam.Diagrammer to provide meaningful role descriptions.

    .PARAMETER String
        The role type string to be translated. Possible values include:
        - LinuxLocal
        - LinuxHardened
        - WinLocal
        - DDBoost
        - HPStoreOnceIntegration
        - ExaGrid
        - InfiniGuard
        - Cloud
        - SanSnapshotOnly
        - vmware
        - hyperv
        - agent
        - nas
        - CifsShare
        - Nfs

    .RETURNS
        A string representing the translated function type object. Possible return values include:
        - Linux Local
        - Linux Hardened
        - Windows Local
        - Dedup Appliances
        - Cloud
        - SAN
        - VMware Backup Proxy
        - HyperV Backup Proxy
        - Agent and Files Backup Proxy
        - NAS Backup Proxy
        - SMB Share
        - NFS Share
        - Unknown

    .NOTES
        Version: 0.6.5
        Author: Jonathan Colon

    .EXAMPLE
        PS C:\> Get-RoleType -String 'LinuxLocal'
        Linux Local

        PS C:\> Get-RoleType -String 'vmware'
        VMware Backup Proxy

    .LINK
        https://github.com/veeam/veeam-diagrammer
    #>

    param(
        [string]$String
    )

    $RoleType = Switch ($String) {
        'LinuxLocal' { 'Linux Local' }
        'LinuxHardened' { 'Linux Hardened' }
        'WinLocal' { 'Windows Local' }
        'DDBoost' { 'Dedup Appliances' }
        'HPStoreOnceIntegration' { 'Dedup Appliances' }
        'ExaGrid' { 'Dedup Appliances' }
        'InfiniGuard' { 'Dedup Appliances' }
        'Cloud' { 'Cloud' }
        'SanSnapshotOnly' { 'SAN' }
        "vmware" { 'VMware Backup Proxy' }
        "hyperv" { 'HyperV Backup Proxy' }
        "agent" { 'Agent and Files Backup Proxy' }
        "nas" { 'NAS Backup Proxy' }
        "CifsShare" { 'SMB Share' }
        'Nfs' { 'NFS Share' }
        default { 'Unknown' }
    }
    return $RoleType
}
function ConvertTo-TextYN {
    <#
    .SYNOPSIS
        Converts a boolean string representation to "Yes" or "No".

    .DESCRIPTION
        This function is used to convert boolean string values ("True" or "False") to their corresponding
        textual representations ("Yes" or "No"). If the input is an empty string, a space, or null, it returns "--".
        Any other input is returned as-is.

    .PARAMETER TEXT
        The string value to be converted. It can be "True", "False", an empty string, a space, or null.

    .OUTPUTS
        [String] The converted string value.

    .NOTES
        Version: 0.3.0
        Author: LEE DAILEY

    .EXAMPLE
        PS C:\> ConvertTo-TextYN -TEXT "True"
        Yes

        PS C:\> ConvertTo-TextYN -TEXT "False"
        No

        PS C:\> ConvertTo-TextYN -TEXT ""
        --

        PS C:\> ConvertTo-TextYN -TEXT " "
        --

        PS C:\> ConvertTo-TextYN -TEXT $Null
        --

        PS C:\> ConvertTo-TextYN -TEXT "Maybe"
        Maybe

    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [OutputType([String])]
    Param (
        [Parameter (
            Position = 0,
            Mandatory)]
        [AllowEmptyString()]
        [string] $TEXT
    )

    switch ($TEXT) {
        "" { "--"; break }
        " " { "--"; break }
        $Null { "--"; break }
        "True" { "Yes"; break }
        "False" { "No"; break }
        default { $TEXT }
    }
} # end

function ConvertTo-FileSizeString {
    <#
    .SYNOPSIS
    Used by As Built Report to convert bytes automatically to GB or TB based on size.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        [Parameter (
            Position = 0,
            Mandatory)]
        [int64] $Size,
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'Please provide the source space unit'
        )]
        [ValidateSet('MB', 'GB', 'TB', 'PB')]
        [string] $SourceSpaceUnit,
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Please provide the space unit to output'
        )]
        [ValidateSet('MB', 'GB', 'TB', 'PB')]
        [string] $TargetSpaceUnit,
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'Please provide the value to round the storage unit'
        )]
        [int] $RoundUnits = 0
    )

    if ($SourceSpaceUnit) {
        return "$([math]::Round(($Size * $("1" + $SourceSpaceUnit) / $("1" + $TargetSpaceUnit)), $RoundUnits)) $TargetSpaceUnit"
    } else {
        $Unit = Switch ($Size) {
            { $Size -gt 1PB } { 'PB' ; Break }
            { $Size -gt 1TB } { 'TB' ; Break }
            { $Size -gt 1GB } { 'GB' ; Break }
            { $Size -gt 1Mb } { 'MB' ; Break }
            Default { 'KB' }
        }
        return "$([math]::Round(($Size / $("1" + $Unit)), $RoundUnits)) $Unit"
    }
} # end

function Convert-Size {
    [cmdletbinding()]
    param(
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$From,
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$To,
        [Parameter(Mandatory = $true)]
        [double]$Value,
        [int]$Precision = 4
    )
    switch ($From) {
        "Bytes" { $value = $Value }
        "KB" { $value = $Value * 1024 }
        "MB" { $value = $Value * 1024 * 1024 }
        "GB" { $value = $Value * 1024 * 1024 * 1024 }
        "TB" { $value = $Value * 1024 * 1024 * 1024 * 1024 }
    }

    switch ($To) {
        "Bytes" { return $value }
        "KB" { $Value = $Value / 1KB }
        "MB" { $Value = $Value / 1MB }
        "GB" { $Value = $Value / 1GB }
        "TB" { $Value = $Value / 1TB }

    }

    return [Math]::Round($value, $Precision, [MidPointRounding]::AwayFromZero)
}