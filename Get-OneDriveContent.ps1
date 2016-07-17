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
        Get-OneDriveContent -Token $token -Path "Documents\onedrive file.txt"

        .EXAMPLE
        Get-OneDriveContent -Token $token -ItemId "1234ABC!123"

        .EXAMPLE
        $token | Get-OneDriveContent -ItemId "1234ABC!123"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odgc')]
    [OutputType()]
    Param
    (
        # The API authentication token.
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   Position=1)]
        [Alias('ApiToken', 'AccessToken')]
        [OneDriveToken]$Token,

        # API resource path.
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [Alias('ApiUrl', 'Resource')]
        [string]$Path,

        # The API path for the user's default drive's root. Default is 'drive/root:/'. 
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [string]$DriveRootPath = 'drive/root:/',

        # API item ID.
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item ID')]
        [Alias('id')]
        [string]$ItemId,

        # The API url to access a specified item. Default is 'drive/items/'.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item ID')]
        [string]$ItemIdRoot = 'drive/items/',

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

        if ($ItemId) {
            $item = Get-OneDriveItem -Token $Token -ItemId $ItemId -ItemIdRoot $ItemIdRoot
        } else {
            $item = Get-OneDriveItem -Token $Token -Path $Path -DriveRootPath $DriveRootPath
        }

        if ($item.folder) {
            $newDestination = Join-Path $Destination $item.name
            New-Item -ItemType Directory -Path $newDestination | Out-Null
            if ($ItemId) {
                $children = Get-OneDriveChildItem -Token $Token -ItemId $ItemId -ItemIdRoot $ItemIdRoot
            } else {
                $children = Get-OneDriveChildItem -Token $Token -Path $Path -DriveRootPath $DriveRootPath
            }
            $children | % {
                Get-OneDriveContent -Token $Token `
                                    -ItemId $_.id `
                                    -ItemIdRoot $ItemIdRoot `
                                    -Destination $newDestination
            }
        } else {
            $outFile = Join-Path $Destination $item.name
            $dloadPath = joinPath $ItemIdRoot $item.id
            $dloadPath = joinPath $dloadPath 'content'
            Invoke-OneDriveApiCall -Token $Token -Path $dloadPath -OutFile $outFile
        }

    }

}

Export-ModuleMember -Function 'Get-OneDriveContent' -Alias 'odgc'

<#
Import-Module ..\PSOD
Function joinPath($Path1, $Path2) {
    if (!$Path1) { $Path1 = "" }
    if (!$Path2) { $Path2 = "" }
    return $Path1.TrimEnd('/'), $Path2.TrimStart('/') -join '/'
}
if ((Get-Date) -ge $token.ExpiryDate) {
    $token = Get-Content .\onedrive.opt | Get-OneDriveAuthToken
}
#>
<#
cd "C:\Temp"
Get-OneDriveContent -Token $token -Path "Documents\Office Lens\28062016 2201 Office Lens.pdf"
Get-OneDriveContent -Token $token -Path "Documents\Office Lens\28062016 2149 Office Lens.pdf" -Destination "c:\temp"
Get-OneDriveContent -Token $token -ItemId "85B75A4CE0397EE!1399" -Verbose
$token | Get-OneDriveContent -ItemId '85B75A4CE0397EE!1436' -Verbose
Get-OneDriveContent -Token $token -Path "Documents"
$brk
#>
