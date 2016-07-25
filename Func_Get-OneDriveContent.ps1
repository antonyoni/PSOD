################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
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
        if (!$Destination) {
            $Destination = Get-Location
        }
    }

    Process {

        if ($ItemId) {
            $item = Get-OneDriveItem -ItemId $ItemId
        } else {
            $item = Get-OneDriveItem -Path $Path
        }

        if ($item.folder) {
            $newDestination = Join-Path $Destination $item.name
            New-Item -ItemType Directory -Path $newDestination | Out-Null
            if ($ItemId) {
                $children = Get-OneDriveChildItem -ItemId $ItemId
            } else {
                $children = Get-OneDriveChildItem -Path $Path
            }
            $children | % {
                Get-OneDriveContent -ItemId $_.id `
                                    -Destination $newDestination
            }
        } else {
            $outFile = Join-Path $Destination $item.name
            $dloadPath = joinPath $PSOD.drive.itemRoot $item.id
            $dloadPath = joinPath $dloadPath 'content'
            Invoke-OneDriveApiCall -Path $dloadPath -OutFile $outFile
        }

    }

}

Export-ModuleMember -Function 'Get-OneDriveContent' -Alias 'odgc'

#. .\setup-test.ps1
<#
cd "C:\Temp"
Get-OneDriveContent -Path "Documents\Office Lens\28062016 2201 Office Lens.pdf"
Get-OneDriveContent -Path "Documents\Office Lens\28062016 2149 Office Lens.pdf" -Destination "c:\temp\other"
Get-OneDriveContent -ItemId "85B75A4CE0397EE!1399" -Verbose
Get-OneDriveContent -ItemId '85B75A4CE0397EE!1436' -Verbose
Get-OneDriveContent -Path "Documents"
#>
