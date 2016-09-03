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

Describe "Copy-OneDriveItem" {

    $path    = "PSOD/odcp" # Folder containing three folders, two empty, one with two docs
    $file1   = "doc1.docx"
    $file2   = "excel1.xlsx"
    $folder1 = "PSOD/odcp/Folder1"
    $folder2 = "PSOD/odcp/Folder2"
    $folder3 = "PSOD/odcp/DestinationFolder"

    $timeToCopy = 5 # Seconds. Increase if getting test failures.

    It "check test folder setup (if this fails, results might not be accurate)" {
        $rsp = Get-OneDriveChildItem -Path $path -Recurse
        $rsp.Count | Should Be 5
    }

    Context "-> File Copy" {
        It "copies files by path" {
            $p = joinPath $folder1 $file1
            Copy-OneDriveItem -Path $p -Destination $folder2
            Start-Sleep -Seconds $timeToCopy
            $check = joinPath $folder2 $file1
            $item = Get-OneDriveItem $check
            Remove-OneDriveItem $check | Out-Null
            $item | Should Not BeNullOrEmpty
        }
        It "copies files by path from pipeline" {
            (joinPath $folder1 $file1) | Copy-OneDriveItem -Destination $folder2
            Start-Sleep -Seconds $timeToCopy
            $check = joinPath $folder2 $file1
            $item = Get-OneDriveItem $check
            Remove-OneDriveItem $check | Out-Null
            $item | Should Not BeNullOrEmpty
        }
        It "copies files by id" {
            $p = joinPath $folder1 $file2
            $id = (Get-OneDriveItem $p).id
            Copy-OneDriveItem -ItemId $id -Destination $folder2
            Start-Sleep -Seconds $timeToCopy
            $check = joinPath $folder2 $file2
            $item = Get-OneDriveItem $check
            Remove-OneDriveItem $check | Out-Null
            $item | Should Not BeNullOrEmpty
        }
    }

    Context "-> Directory Copy" {
        It "copies directories by path" {
            Copy-OneDriveItem -Path $folder1 -Destination $folder3
            Start-Sleep -Seconds $timeToCopy
            $items = Get-OneDriveChildItem $folder3 -Recurse
            Remove-OneDriveItem (joinPath $folder3 'Folder1') | Out-Null
            $items.Count | Should Be 3
        }
        It "copies directories by id" {
            $id = (Get-OneDriveItem $folder1).id
            Copy-OneDriveItem -ItemId $id -Destination $folder3
            Start-Sleep -Seconds $timeToCopy
            $items = Get-OneDriveChildItem $folder3 -Recurse
            Remove-OneDriveItem (joinPath $folder3 'Folder1') | Out-Null
            $items.Count | Should Be 3
        }
    }

    Context "-> Alias" {
        It "works with the alias odcp" {
            $p = joinPath $folder1 $file1
            odcp $p $folder2
            Start-Sleep -Seconds $timeToCopy
            $check = joinPath $folder2 $file1
            $item = Get-OneDriveItem $check
            Remove-OneDriveItem $check | Out-Null
            $item | Should Not BeNullOrEmpty
        }
        It "works with the alias odcopy" {
            (joinPath $folder1 $file2) | odcopy -Destination $folder2
            Start-Sleep -Seconds $timeToCopy
            $check = joinPath $folder2 $file2
            $item = Get-OneDriveItem $check
            Remove-OneDriveItem $check | Out-Null
            $item | Should Not BeNullOrEmpty
        }
    }

    Context "-> Correctly sets parameters for Invoke-RestMethod" {
        Mock -ModuleName PSOD Invoke-RestMethod { return $Headers }
        It "Additional Headers" {
            $m = Copy-OneDriveItem -Path "test-path" -Destination "test-destination"
            $m['Prefer'] | Should Be 'respond-async'
        }
    }

}
