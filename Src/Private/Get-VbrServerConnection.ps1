function Get-VbrServerConnection {
    <#
    .SYNOPSIS
        Used by As Built Report to establish conection to Veeam B&R Server.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.0.2
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]
    param (

    )

    begin {
        Write-Verbose -Message "Establishing initial connection to Backup Server: $($System)."
    }

    process {
        Write-Verbose -Message "Looking for veeam existing server connection."
        #Code taken from @vMarkus_K
        $OpenConnection = (Get-VBRServerSession).Server
        if($OpenConnection -eq $System) {
            Write-Verbose -Message "Existing veeam server connection found"
        }
        elseif ($null -eq $OpenConnection) {
            Write-Verbose -Message "No existing veeam server connection found"
            try {
                Write-Verbose -Message "Connecting to $($System) with $($Credential.USERNAME) credentials"
                Connect-VBRServer -Server $System -Credential $Credential -Port $Port
            }
            catch {
                Write-Output -Debug $_.Exception.Message
                Throw "Failed to connect to Veeam Backup Server Host $($System):$($Port) with username $($Credential.USERNAME)"
            }
        }
        else {
            Write-Verbose -Message "Actual veeam server connection not equal to $($System). Disconecting connection."
            Disconnect-VBRServer
            try {
                Write-Verbose -Message "Trying to open a new connection to $($System)"
                Connect-VBRServer -Server $System -Credential $Credential -Port $Port
            }
            catch {
                Write-Output -Debug $_.Exception.Message
                Throw "Failed to connect to Veeam Backup Server Host $($System):$($Port) with username $($Credential.USERNAME)"
            }
        }
        Write-Verbose -Message "Validating connection to $($System)"
        $NewConnection = (Get-VBRServerSession).Server
        if ($null -eq $NewConnection) {
            Write-Output -Debug $_.Exception.Message
            Throw "Failed to connect to Veeam Backup Server Host $($System):$($Port) with username $($Credential.USERNAME)"
        }
        elseif ($NewConnection) {
            Write-Verbose -Message "Successfully connected to $($System):$($Port) Backup Server."
        }
    }
    end {}

}