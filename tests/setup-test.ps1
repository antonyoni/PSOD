$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Split-Path $here -Parent

if (Get-Module PSOD) { Remove-Module PSOD }

Import-Module $modulePath
. (Join-Path $modulePath PSOD.helpers.ps1)

if ($PSOD.testing.bootstrap) {
    # Set up the required folder hierarchy for testing
    $testFolder = Get-OneDriveItem "PSOD" -ErrorAction SilentlyContinue

    if (!$testFolder) {
        Write-Host "Test folder 'PSOD' not found in OneDrive. Setting up."

        @(
            "PSOD/odcp/DestinationFolder"
            "PSOD/odcp/Folder1"
            "PSOD/odcp/Folder2"
            "PSOD/odgci/Subfolder1/Subfolder2"
            "PSOD/odrm"
            "PSOD/odsc"
        ) | New-OneDriveFolder | Out-Null

        $file1 = Join-Path $here temp.txt
        "test file 1" | Set-Content $file1

        @(
            "PSOD/odcp/Folder1/doc1.docx"
            "PSOD/odcp/Folder1/excel1.xlsx"
            "PSOD/odgci/doc1.docx"
            "PSOD/odgci/excel1.xlsx"
            "PSOD/odgci/Subfolder1/doc1.docx"
            "PSOD/odgci/Subfolder1/excel1.xlsx"
            "PSOD/odgci/Subfolder1/Subfolder2/doc1.docx"
        ) | Set-OneDriveContent -Source $file1 | Out-Null

        Remove-Item $file1

        Describe "Test Bootstrap" {
            It "has the right number of files and folders" {
                (Get-OneDriveChildItem PSOD -Recurse).count | Should BeExactly 16
            }
        }
    }
}
