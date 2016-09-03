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

Describe "Get-OneDriveItem" {

    It "gets the default drive root by default" {
        $rsp = Get-OneDriveItem
        $rsp.name | Should Be "root"
    }

    $path     = "PSOD"
    $itemId   = ""
    $response = Get-OneDriveItem -Path $path
    $itemId   = $response.id

    It "gets item by path" {
        $response.name | Should Be $path
    }

    It "gets item by path from pipeline" {
        $rsp = $path | Get-OneDriveItem
        $rsp.name | Should Be $path
    }

    It "gets item by path from property" {
        $rsp = [pscustomobject]@{ Resource = $path } | Get-OneDriveItem
        $rsp.name | Should Be $path
    }

    It "gets item by ID" {
        $rsp = Get-OneDriveItem -ItemId $itemId
        $rsp.id | Should Be $itemId
    }

    It "gets item by ID from property" {
        $rsp = [pscustomobject]@{ id = $itemId } | Get-OneDriveItem
        $rsp.id | Should Be $itemId
    }

    Context "-> Custom type formatting" {

        $parentPath = [System.Web.HttpUtility]::UrlDecode($response.parentReference.Path)

        It "has a type of PSOD.OneDriveItem" {
            $response.PsObject.TypeNames[0] | Should Be "PSOD.OneDriveItem"
        }
        It "DownloadUrl" {
            $response.DownloadUrl | Should Be $response."@content.downloadUrl"
        }
        It "FullName" {
            $response.FullName | Should Be ($parentPath + "/" + $path)
        }
        It "Length" {
            $response.Length | Should Be $response.size
        }
        It "ToString" {
            $response.ToString() | Should Be $response.Path
        }
        It "BaseName" {
            $response.BaseName | Should Be $path
        }
        It "Parent" {
            $response.Parent | Should Be ([System.Web.HttpUtility]::UrlDecode($response.parentReference.Path))
        }
        It "ParentId" {
            $response.ParentId | Should Be $response.parentReference.id
        }
        It "Path" {
            $response.Path | Should Be ($parentPath + "/" + $path)
        }
        It "Type" {
            $response.Type | Should Be "folder"
        }
        It "Root" {
            $response.Root | Should Be $PSOD.drive.pathRoot
        }

    }

    Context "-> Alias" {
        It "works with the alias odgi" {
            $rsp = $path | odgi
            $rsp.name | Should Be $path
        }
    }
    
}
