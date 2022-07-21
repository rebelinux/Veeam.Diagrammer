
function Remove-SpecialChars {
    <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to remove unsupported characters.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Prateek Singh
    .EXAMPLE
    .LINK
    #>
    param(
        [string]$String,
        [string]$SpecialChars = "()[]{}&."
    )

    $String -replace $($SpecialChars.ToCharArray().ForEach( { [regex]::Escape($_) }) -join "|"), ""
}


function Get-IconType {
    <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to translate repository type to icon type object.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
    #>
    param(
        [string]$String
    )

    $IconType = Switch ($String) {
        'LinuxLocal' {'VBR_Linux_Repository'}
        'WinLocal' {'VBR_Windows_Repository'}
        'Cloud' {'VBR_Cloud_Repository'}
        'AzureBlob' {'VBR_Cloud_Repository'}
        'AmazonS3' {'VBR_Cloud_Repository'}
        'AmazonS3Compatible' {'VBR_Cloud_Repository'}
        'AmazonS3Glacier' {'VBR_Cloud_Repository'}
        'AzureArchive' {'VBR_Cloud_Repository'}
        'DDBoost' {'VBR_Deduplicating_Storage'}
        'HPStoreOnceIntegration' {'VBR_Deduplicating_Storage'}
        'SanSnapshotOnly' {'VBR_Storage_NetApp'}
        'Proxy' {'VBR_Repository'}
        'ESXi' {'VBR_ESXi_Server'}
        'HyperVHost' {'Hyper-V_host'}
        default {'VBR_No_Icon'}
    }

    return $IconType
}

function Get-RoleType {
    <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to translate role type to function type object.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
    #>
    param(
        [string]$String
    )

    $RoleType = Switch ($String) {
        'LinuxLocal' {'Linux Local'}
        'WinLocal' {'Windows Local'}
        'DDBoost' {'Dedup Appliances'}
        'HPStoreOnceIntegration' {'Dedup Appliances'}
        'Cloud' {'Cloud'}
        'SanSnapshotOnly' {'SAN'}
        "vmware" {'VMware Backup Proxy'}
        "hyperv" {'HyperV Backup Proxy'}
        default {'Backup Repository'}
    }

    return $RoleType
}

function Get-NodeIP {
    <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to translate node name to an network ip address type object.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Jonathan Colon
    .EXAMPLE
    .LINK
    #>
    param(
        [string]$Hostname
    )

    try {
        $NodeIP = Switch ((Resolve-DnsName $Hostname -ErrorAction SilentlyContinue).IPAddress) {
            $Null {'Unknown'}
            default {(Resolve-DnsName $Hostname -ErrorAction SilentlyContinue).IPAddress}
        }
    }
    catch {
        $_
    }

    return $NodeIP
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

    Param
        (
        [Parameter (
            Position = 0,
            Mandatory)]
            [AllowEmptyString()]
            [string]
            $TEXT
        )

    switch ($TEXT) {
        "" {"-"}
        $Null {"-"}
        "True" {"Yes"; break}
        "False" {"No"; break}
        default {$TEXT}
    }
} # end

function Write-ColorOutput {
        <#
    .SYNOPSIS
        Used by Veeam.Diagrammer to output colored text.
    .DESCRIPTION
    .NOTES
        Version:        0.1.0
        Author:         Prateek Singh
    .EXAMPLE
    .LINK
    #>

    [CmdletBinding()]
    [OutputType([String])]

    Param
        (
            [Parameter(
                Position = 0,
                Mandatory = $true
            )]
            [ValidateNotNullOrEmpty()]
            [String] $Color,

            [Parameter(
                Position = 1,
                Mandatory = $true
            )]
            [ValidateNotNullOrEmpty()]
            [String] $String
        )
    # save the current color
    $ForegroundColor = $Host.UI.RawUI.ForegroundColor

    # set the new color
    $Host.UI.RawUI.ForegroundColor = $Color

    # output
    if ($String) {
        Write-Output $String
    }

    # restore the original color
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
}