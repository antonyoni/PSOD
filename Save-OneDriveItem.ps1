################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Save-OneDriveItem {
    <#
        .SYNOPSIS
        Saves a local copy of the specified OneDrive item.
        
        .EXAMPLE

    #>
    [CmdletBinding()]
    [OutputType([PsObject])]
    Param
    (
        # The API authentication token.
        [Parameter(Mandatory=$True,
                   Position=1)]
        [string]$Token,

        # Details of the item to save.
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipeline=$True)]
        [psobject]$Item,

        # The path to the destination directory / file.
        [Parameter(Mandatory=$False,
                   Position=3)]
        [string]$Destination
    )

    Begin {
        if (!$Destination) {
            $Destination = Get-Location
        }
    }

    Process {

        if ($Item.File) {
            $outFile = Join-Path $Destination $Item.name
            Invoke-WebRequest -Uri $Item.'@content.downloadUrl' -OutFile $outFile -UseBasicParsing
        } else {
            $rec = Get-OneDriveItem -Token $token.Token -Path $Item.
        }

    }

}

#Export-ModuleMember -Function 'Save-OneDriveItem'

#<#
if ((Get-Date) -ge $token.ExpiryDT) {
    $token = Get-Content .\PSOD\onedrive.opt | Get-OneDriveAuthToken
}
$items = Get-OneDriveItem -Token $token.Token -Path "Documents\Office Lens"
Save-OneDriveItem $token.Token $items[0] -Destination C:\Temp
$dir = Get-OneDriveItem -Token $token.Token -Path "Documents"
Save-OneDriveItem $token.Token $dir -Destination C:\Temp

#>
