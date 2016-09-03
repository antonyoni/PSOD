################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

. .\setup-test.ps1

Describe "Get-OneDriveContent" {

    $path = 'PSOD/odgci' # Folder containing one folder, two documents, 7 item recursively

    $file1   = 'doc1.docx'
    $file2   = 'excel1.xlsx'
    $folder1 = 'Subfolder1'

    $destination  = 'TestDrive:\'
    $destination2 = Join-Path 'TestDrive:\' '2'

    New-Item -ItemType Directory -Path $destination2

    Context "-> get files" {
        It "get file by path" {
            $p = joinPath $path $file1
            Get-OneDriveContent -Path $p -Destination $destination
            Join-Path $destination $file1 | Should Exist
        }
        It "get file by id" {
            $p = joinPath $path $file2
            $id = (Get-OneDriveItem $p).id
            Get-OneDriveContent -ItemId $id -Destination $destination
            Join-Path $destination $file2 | Should Exist
        }
    }

    Context "-> Get directories" {

        $p = joinPath $path $folder1
        $remoteCount = (Get-OneDriveChildItem -Path $p).Count

        It "get directory by path" {
            Get-OneDriveContent -Path $p -Destination $destination
            $localCount  = (Get-ChildItem (Join-Path $destination $folder1)).Count
            $localCount | Should BeExactly $remoteCount
        }
        It "get directory by id" {
            $id = (Get-OneDriveItem $p).id
            Get-OneDriveContent -ItemId $id -Destination $destination2
            $localCount  = (Get-ChildItem (Join-Path $destination2 $folder1)).Count
            $localCount | Should BeExactly $remoteCount
        }
    }

    Context "-> Alias" {
        It "works with the alias odgc" {
            $p = joinPath $path $file1
            Get-OneDriveContent -Path $p -Destination $destination2
            Join-Path $destination2 $file1 | Should Exist
        }
    }

    Context "-> Error handling" {
        It "fails when destination doesn't exist" {
            $p = joinPath $path $file1
            { Get-OneDriveContent -Path $p -Destination 'does-not-exist' -ErrorAction Stop } |
                Should Throw
        }
    }

}
