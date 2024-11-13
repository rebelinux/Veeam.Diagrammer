function Get-IconType {
    <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to translate repository type to icon type object.
    .DESCRIPTION
    .NOTES
        Version:        0.6.5
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
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
        default { 'VBR_No_Icon' }
    }

    return $IconType
}

function Get-RoleType {
    <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to translate role type to function type object.
    .DESCRIPTION
    .NOTES
        Version:        0.6.5
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
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
        Used by As Built Report to convert true or false automatically to Yes or No.
    .DESCRIPTION

    .NOTES
        Version:        0.3.0
        Author:         LEE DAILEY

    .EXAMPLE

    .LINK

    #>
    [CmdletBinding()]
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
        [int64]
        $Size
    )

    $Unit = Switch ($Size) {
        { $Size -gt 1PB } { 'PB' ; Break }
        { $Size -gt 1TB } { 'TB' ; Break }
        { $Size -gt 1GB } { 'GB' ; Break }
        { $Size -gt 1Mb } { 'MB' ; Break }
        Default { 'KB' }
    }
    return "$([math]::Round(($Size / $("1" + $Unit)), 0)) $Unit"
} # end