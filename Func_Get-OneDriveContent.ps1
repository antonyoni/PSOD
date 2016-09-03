################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the
# Creative Commons Attribution-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-sa/4.0/
################################################################################

Function Get-OneDriveContent {
    <#
        .SYNOPSIS
        Downloads the contents of a file and saves it to the specified destination. If no destination is specified, the current directory is used.
        
        .EXAMPLE
        Get-OneDriveContent -Path "Documents\onedrive file.txt"

        .EXAMPLE
        Get-OneDriveContent -ItemId "1234ABC!123"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odgc')]
    [OutputType()]
    Param
    (
        # API resource path.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [Alias('ApiUrl', 'Resource')]
        [string]$Path,

        # API item ID.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item ID')]
        [Alias('id')]
        [string]$ItemId,

        # The path to the destination directory / file.
        [Parameter(Mandatory=$False,
                   Position=2)]
        [string]$Destination
    )

    Begin {
        if ($Destination) {
            if (!(Test-Path $Destination)) {
                Write-Error "The destination directory '$Destination' does not exist."
                break
            }
        } else {
            $Destination = Get-Location
        }
    }

    Process {

        if ($ItemId) {
            $item = Get-OneDriveItem -ItemId $ItemId
        } else {
            $item = Get-OneDriveItem -Path $Path
        }

        if ($item.Type -eq 'folder') {
            $newDestination = Join-Path $Destination $item.Name
            if (Test-Path $newDestination) {
                Write-Error "Destination directory '$newDestination' already exists."
            } else {
                New-Item -ItemType Directory -Path $newDestination | Out-Null
                if (Test-Path $newDestination) {
                    Get-OneDriveChildItem -id $item.id | % {
                        Get-OneDriveContent -ItemId $_.id -Destination $newDestination
                    }
                } else {
                    Write-Warning "Unable to create new directory '$newDestination'."
                }
            }
        } else {
            $outFile = Join-Path $Destination $item.Name
            $dloadPath = joinPath $PSOD.drive.itemRoot $item.Id
            $dloadPath = joinPath $dloadPath 'content'
            Invoke-OneDriveApiCall -Path $dloadPath -OutFile $outFile
        }

    }

}

Export-ModuleMember -Function 'Get-OneDriveContent' -Alias 'odgc'
