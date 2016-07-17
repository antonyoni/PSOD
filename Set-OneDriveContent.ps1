################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Set-OneDriveContent {
    <#
        .SYNOPSIS
        Uploads a new file, or update the contents of an existing OneDrive file.
        
        .EXAMPLE
        

        .EXAMPLE
        

        .EXAMPLE
        
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odsc')]
    [OutputType([PsObject])]
    Param
    (
        # The API authentication token.
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   Position=1)]
        [Alias('ApiToken', 'AccessToken')]
        [OneDriveToken]$Token,

        # API resource destination path.
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

        # API destination item ID.
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

        # The local path of the source file or directory.
        [Parameter(Mandatory=$True,
                   Position=3)]
        [string]$Source
    )

    Begin {
        if (!$Destination) {
            $Destination = Get-Location
        }
    }

    Process {

        $upload = Get-Item -Path $Source

        if (!$upload) {
            return
        }

        Write-Verbose "Source path: $($upload.FullName)"

        if ($ItemId) {
            $remote = Get-OneDriveItem -Token $Token -ItemId $ItemId -ItemIdRoot $ItemIdRoot
        } else {
            $remote = Get-OneDriveItem -Token $Token -Path $Path -DriveRootPath $DriveRootPath
        }

        if ($remote.folder) {
            if ($ItemId) {
                $uploadPath = joinPath $ItemIdRoot $ItemId
                $uploadPath = joinPath $uploadPath 'children'
                $uploadPath = joinPath $uploadPath $upload.Name
                $uploadPath = joinPath $uploadPath 'content'
            } else {
                $uploadPath = joinPath $DriveRootPath $Path
                $uploadPath = joinPath $uploadPath $upload.Name
                $uploadPath = joinPath $uploadPath ':/content'
            }
            Write-Verbose "Destination path: $uploadPath"
            Invoke-OneDriveApiCall -Token $Token `
                                   -Path $uploadPath `
                                   -Method PUT `
                                   -InFile $upload.FullName
        } else {

        }

<#
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
#>

    }

}

#Export-ModuleMember -Function 'Set-OneDriveContent' -Alias 'odsc'

#<#
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
#<#
cd "C:\Temp"
Set-OneDriveContent -Token $token -Path "temp" -Source 'C:\Temp\test1.pdf' -Verbose
<#
Set-OneDriveContent -Token $token -Path "Documents\Office Lens\28062016 2149 Office Lens.pdf" -Destination "c:\temp"
Set-OneDriveContent -Token $token -ItemId "85B75A4CE0397EE!1399" -Verbose
$token | Set-OneDriveContent -ItemId '85B75A4CE0397EE!1436' -Verbose
Set-OneDriveContent -Token $token -Path "Documents"
#>
$brk
