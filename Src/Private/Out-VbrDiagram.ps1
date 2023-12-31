function Out-VbrDiagram {
    <#
    .SYNOPSIS
        Function to export diagram to expecified format.
    .DESCRIPTION
        Build a diagram of the configuration of Veeam VBR in PDF/PNG/SVG formats using Psgraph.
    .NOTES
        Version:        0.5.4
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .LINK
        https://github.com/rebelinux/Veeam.Diagrammer
    #>
    [CmdletBinding()]

    Param
    (

    )
    process {
        if ($EnableErrorDebug) {
            $Graph
        } else {
            # If Filename parameter is not specified, set filename to the Output.$OutputFormat
            foreach ($OutputFormat in $Format) {
                if ($Filename) {
                    Try {
                        if ($OutputFormat -ne "base64") {
                            if($OutputFormat -ne "svg") {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat $OutputFormat
                                Write-ColorOutput -Color green  "Diagram '$FileName' has been saved to '$OutputFolderPath'."
                            } else {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat $OutputFormat
                                #Fix icon path issue with svg output
                                $images = Select-String -Path $($Document.fullname) -Pattern '<image xlink:href=".*png".*>' -AllMatches
                                foreach($match in $images) {
                                    $matchFound = $match -Match '"(.*png)"'
                                    if ($matchFound -eq $false) {
                                        continue
                                    }
                                    $iconName = $Matches.Item(1)
                                    $iconNamePath = "$IconPath\$($Matches.Item(1))"
                                    $iconContents = Get-Content $iconNamePath -Encoding byte
                                    $iconEncoded = [convert]::ToBase64String($iconContents)
                                    ((Get-Content -Path $($Document.fullname) -Raw) -Replace $iconName, "data:image/png;base64,$($iconEncoded)") | Set-Content -Path $($Document.fullname)
                                }
                                if ($Document) {
                                    Write-ColorOutput -Color green "Diagram '$FileName' has been saved to '$OutputFolderPath'."
                                }

                            }
                        } else {
                            $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($FileName)" -OutputFormat 'png'
                            if ($Document) {
                                # Code used to allow rotating image!
                                if ($Rotate) {
                                    Add-Type -AssemblyName System.Windows.Forms
                                    $RotatedIMG = new-object System.Drawing.Bitmap $Document.FullName
                                    $RotatedIMG.RotateFlip("Rotate90FlipNone")
                                    $RotatedIMG.Save($Document.FullName,"png")
                                    if ($RotatedIMG) {
                                        $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                        if ($Base64) {
                                            Remove-Item -Path $Document.FullName
                                            $Base64
                                        } else {Remove-Item -Path $Document.FullName}
                                    }
                                } else {
                                    # Code used to output image to base64 format
                                    $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                    if ($Base64) {
                                        Remove-Item -Path $Document.FullName
                                        $Base64
                                    } else {Remove-Item -Path $Document.FullName}

                                }
                            }
                        }
                    } catch {
                        $Err = $_
                        Write-Error $Err
                    }
                }
                elseif (!$Filename) {
                    if ($OutputFormat -ne "base64") {
                        $File = "Output.$OutputFormat"
                    } else {$File = "Output.png"}
                    Try {
                        if ($OutputFormat -ne "base64") {
                            if($OutputFormat -ne "svg") {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat $OutputFormat
                                Write-ColorOutput -Color green  "Diagram '$File' has been saved to '$OutputFolderPath'."
                            } else {
                                $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat $OutputFormat
                                $images = Select-String -Path $($Document.fullname) -Pattern '<image xlink:href=".*png".*>' -AllMatches
                                foreach($match in $images) {
                                    $matchFound = $match -Match '"(.*png)"'
                                    if ($matchFound -eq $false) {
                                        continue
                                    }
                                    $iconName = $Matches.Item(1)
                                    $iconNamePath = "$IconPath\$($Matches.Item(1))"
                                    $iconContents = Get-Content $iconNamePath -Encoding byte
                                    $iconEncoded = [convert]::ToBase64String($iconContents)
                                    ((Get-Content -Path $($Document.fullname) -Raw) -Replace $iconName, "data:image/png;base64,$($iconEncoded)") | Set-Content -Path $($Document.fullname)
                                }
                                if ($Document) {
                                    Write-ColorOutput -Color green  "Diagram '$File' has been saved to '$OutputFolderPath'."
                                }
                            }
                        } else {
                            $Document = Export-PSGraph -Source $Graph -DestinationPath "$($OutputFolderPath)$($File)" -OutputFormat 'png'
                            if ($Document) {
                                $Base64 = [convert]::ToBase64String((get-content $Document -encoding byte))
                                if ($Base64) {
                                    Remove-Item -Path $Document.FullName
                                    $Base64
                                } else {Remove-Item -Path $Document.FullName}
                            }
                        }
                    } catch {
                        $Err = $_
                        Write-Error $Err
                    }
                }
            }
        }
    }
    end {

    }
}