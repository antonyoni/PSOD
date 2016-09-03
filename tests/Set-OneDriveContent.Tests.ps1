################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the
# Creative Commons Attribution-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-sa/4.0/
################################################################################

. .\setup-test.ps1

Describe "Set-OneDriveContent" {

    $path = 'TestDrive:\'

    $file1 = 'doc1.docx'
    $file2 = 'excel1.xlsx'

    #$folder1 = 'Subfolder1' 

    $destination   = 'PSOD/odsc/'
    $destinationId = (Get-OneDriveItem $destination).id

    # setup test
    @(
        (joinPath 'PSOD/odgci' $file1)
        (joinPath 'PSOD/odgci' $file2)
        #(joinPath 'PSOD/odgci' $folder1)
    ) | Get-OneDriveContent -Destination $path

    It "check test folder setup (if this fails, results might not be accurate)" {
        (Get-ChildItem $path).Count | Should BeExactly 2
    }

    Context "-> Upload files" {

        $sourcePath = Join-Path $path $file1
        $remoteFile = joinPath $destination $file1

        It "upload file by destination path" {
            $item = Set-OneDriveContent -Path $destination -Source $sourcePath
            $item | Should Not BeNullOrEmpty
        }
        It "upload file by destination id" {
            $p = Join-Path $path $file2
            $item = Set-OneDriveContent -ItemId $destinationId -Source $p
            Remove-OneDriveItem -ItemId $item.id | Out-Null
            $item | Should Not BeNullOrEmpty
        }
        It "fails if the file already exists" {
            $etagBefore = (Get-OneDriveItem -Path $RemoteFile).etag
            $item = Set-OneDriveContent -Path $destination -Source $sourcePath -ErrorAction SilentlyContinue
            $item | Should BeNullOrEmpty
        }
        It "overwrites if -Force is used" {
            $etagBefore = (Get-OneDriveItem -Path $RemoteFile).etag
            $item = Set-OneDriveContent -Path $destination -Source $sourcePath -Force
            $item.etag | Should Not Be $etagBefore
        }

        Remove-OneDriveItem $remoteFile
    }

    Context "-> Alias" {
        It "works with the alias odsc" {
            $p = Join-Path $path $file2
            $item = $destination | odsc -Source $p
            Remove-OneDriveItem -ItemId $item.id | Out-Null
            $item | Should Not BeNullOrEmpty
        }
    }

}
