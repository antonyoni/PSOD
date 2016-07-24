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
        Set-OneDriveContent -Token $token -Path "Documents" -Source 'C:\Temp\test.pdf' -Force

        .EXAMPLE
        Set-OneDriveContent -Token $token -Path "Documents/aNewDirectory/" -Source 'C:\Temp\test.pdf'

        .EXAMPLE
        $token | Set-OneDriveContent -Path "Documents/another-name.pdf" -Source 'C:\Temp\test.pdf'

        .EXAMPLE
        Set-OneDriveContent -Token $token -ItemId "85B75A4CE0397EE!1450" -Source 'C:\Temp\test.pdf'
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
        [PsObject]$Token,

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
        [string]$Source,

        # By default, remote items are not overwritten. Set this to overwrite.
        [Parameter(Mandatory=$False)]
        [switch]$Force
    )

    Process {

        $upload = Get-Item -Path $Source

        if (!$upload) {
            return
        }

        Write-Verbose "Source path: $($upload.FullName)"

        if ($ItemId) {
            $remote = Get-OneDriveItem -Token $Token -ItemId $ItemId -ItemIdRoot $ItemIdRoot
            if (!$remote) {
                return
            }
        } else {
            try {
                $remote = Get-OneDriveItem -Token $Token -Path $Path -DriveRootPath $DriveRootPath
            } catch {
                # supress errors. OneDrive creates the full path if it doesn't exist.
            }
        }

        if (!$remote -and !$Path.EndsWith('/')) {
            # Assume path leaf is the file name even if no extension
            $uploadPath = joinPath $DriveRootPath $Path
            $uploadPath = $uploadPath.TrimEnd('/') + ':/content'
        } elseif ($remote.folder -or $Path.EndsWith('/')) {
            if ($ItemId) {
                $uploadPath = joinPath $ItemIdRoot $ItemId
                $uploadPath = joinPath $uploadPath 'children'
                $uploadPath = joinPath $uploadPath $upload.Name
                $uploadPath = joinPath $uploadPath 'content'
            } else {
                $uploadPath = joinPath $DriveRootPath $Path
                $uploadPath = joinPath $uploadPath $upload.Name
                $uploadPath += ':/content'
            }
        } else {
            if ($ItemId) {
                $uploadPath = joinPath $ItemIdRoot $remote.parentReference.id
                $uploadPath += ':'
                $uploadPath = joinPath $uploadPath $remote.name 
                $uploadPath += ':/content'
            } else {
                $uploadPath = joinPath $DriveRootPath $Path
                $uploadPath = $uploadPath.TrimEnd('/') + ':/content'
            }
        }

        Write-Verbose "Destination path: $uploadPath"

        if ($Force) {
            $uploadPath += '?@name.conflictBehavior=replace'
        } else {
            $uploadPath += '?@name.conflictBehavior=fail'
        }
        
        Invoke-OneDriveApiCall -Token $Token `
                               -Path $uploadPath `
                               -Method PUT `
                               -InFile $upload.FullName

    }

}

Export-ModuleMember -Function 'Set-OneDriveContent' -Alias 'odsc'

#. .\setup-test.ps1
<#
cd "C:\Temp"
$newItem = Set-OneDriveContent -Token $token -Path "temp" -Source 'C:\Temp\test1.pdf' -Verbose
$newItem
Set-OneDriveContent -Token $token -Path "temp/another1" -Source 'C:\Temp\test1.pdf' -Verbose
Set-OneDriveContent -Token $token -Path "temp/another2/" -Source 'C:\Temp\test1.pdf' -Verbose
Set-OneDriveContent -Token $token -Path "temp/temp.pdf" -Source 'C:\Temp\test1.pdf' -Verbose
#test overwrite - should fail
Set-OneDriveContent -Token $token -Path "temp" -Source 'C:\Temp\test1.pdf' -Verbose
Set-OneDriveContent -Token $token -Path "temp" -Source 'C:\Temp\test1.pdf' -Verbose -Force
#upload by id of destination directory:
$dir = $token | Get-OneDriveItem -Path 'temp'
Set-OneDriveContent -Token $token -ItemId $dir.id -Source 'C:\Temp\test3.pdf' -Verbose
#upload by id of destination file:
$etagbf = ($token | Get-OneDriveItem -id $newItem.id).etag
Set-OneDriveContent -Token $token -ItemId $newItem.id -Source 'C:\Temp\test1.pdf' -Verbose -Force
$etagaf = ($token | Get-OneDriveItem -id $newItem.id).etag
$etagbf
$etagaf
$etagbf -ne $etagaf
#>
