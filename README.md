# PSOD - PowerShell OneDrive API wrapper

This module is a wrapper for [OneDrive API 2.0](http://dev.onedrive.com/).

### Installation and Prerequisites

To use this module, please follow the instructions on the [OneDrive authentication and sign-in](https://dev.onedrive.com/auth/msa_oauth.htm) page.

A temporary application token can be obtained on that page to test this module. If using it permanently, then you can register a new API application:

* Go to https://apps.dev.microsoft.com and log in
* Click on 'Add an app'
* Enter a name - PSOD
* Click on 'Add Platform' > Web
* Tick the 'Allow Implicit Flow' box and enter `http://localhost:8080` in the 'Redirect URIs' box
* Tick the 'Live SDK support' box at the bottom of the page
* Click Save
* Copy the 'Application Id' at the top of the page and save it in the PSOD module directory in a file called `onedrive.opt`

The module uses the [Token Flow](https://dev.onedrive.com/auth/msa_oauth.htm#token-flow) for authentication and stores the token in a module variable, renewing it once it expires.

### Configuration

The module has a configuration file [PSOD.config.json](PSOD.config.json). The configuration is set up for OneDrive personal. It's possible to change the path and item roots if using a non-default drive. Currently, no testing has been done with OneDrive for Business.

The Application Id obtained during setup can be added directly to this file, however to avoid it from being committed to Git, use the `onedrive.opt` file.

### Available Functions

| Function | Alias | Description |
|:---------| :---: |:------------|
| `Copy-OneDriveItem` | `odcp`, `odcopy` | Copies an item from one path to another. |
| `Get-OneDriveAuthToken` | | Gets an authorization token for the application defined in the `PSOD.config.json` or `onedrive.opt` file.<br>By default, *onedrive.readwrite* permissions are requested. |
| `Get-OneDriveChildItem` | `odgci`, `odls` | Gets all items in the specified *Path*, or that are children of the specified *ItemId*.<br>By default, gets items in the default drive's root. |
| `Get-OneDriveContent` | `odgc` | Downloads the contents of an item and saves it to the specified *Destination*. If no destination is specified, the current directory is used.<br>Can be used with files or folders. If used with a folder, will recreate the folder structure locally. |
| `Get-OneDriveItem` | `odgi` | Gets item (folder/file) details from the OneDrive API.<br>By default gets the default drive's root.<br>Can be used with either a *Path*, or an *ItemId*. |
| `Invoke-OneDriveApiCall` | | Wrapper for Invoke-RestMethod to send commands to the OneDrive API. |
| `Move-OneDriveItem` | `odmv`,`odmove` | Move an item from one path to another. |
| `New-OneDriveFolder` | `odnf`, `odmkdir` | Create a new folder in the specified location.<br>Can be used with either a *Path*, or with a *Name* and *ParentId*.<br>If used with path, will recursively create all folders.<br>If folder already exists, returns the item details. |
| `New-OneDriveToken` | `odnt` | Creates a new OneDrive Authentication token from an API response. |
| `Remove-OneDriveItem` | `odrm`, `oddel` | Deletes the specified item from OneDrive. |
| `Set-OneDriveContent` | `odsc` | Uploads a new file, or updates the contents of an existing file. Currently works with files only.<br>Recursively creates all folders in *Path*.<br>Add a '/' to the end of the *Path* if you're uploading to a directory that does not exist; otherwise, the path leaf is used as the remote file name. |

### Examples

#### Get details of an OneDrive item or folder
```powershell
Get-OneDriveItem -Path Documents
# or
odgi 'Documents'
```
will output:
```
PS> odgi 'Documents'

    Path:  /drive/root:

Type           LastModifiedTime         Length Name       
----           ----------------         ------ ----       
folder         26/08/2016 01:15       54854799 Documents  
```

#### Recursively list all the items and folders in the 'Documents' folder
```powershell
Get-OneDriveChildItem -Path Documents -Recurse
# or
odgci 'Documents' -rec
```

#### Download a file or directory 
```powershell
# Download to the current directory
Get-OneDriveContent -Path "Documents/document.docx"
# Download to a specific directory
Get-OneDriveContent -Path "Documents/document.docx" -Destination "c:\local\dir" 
# or
"Documents/document.docx", "Documents/workbook.xlsx" | odgc
# Recursively download an entire directory - same as a file
Get-OneDriveContent -Path "Documents" -Destination "c:\local\dir"
```

#### Upload a local file 
```powershell
Set-OneDriveContent -Path "OneDrive/Remote/Path" -Source "c:\path\to\file.txt"
# or
odsc "OneDrive/Remote/Path" "c:\path\to\file.txt"
```
Note that if the remote directory does not exist, the script will treat the leaf of the *Path* as the remote file name. So in this example, if 'OneDrive/Remote/Path' does not exist, then the script will create a new file called 'Path' in 'OneDrive/Remote' and upload the contents of `file.txt` to it. To avoid this, add a '/' to the end of the *Path*.

#### Upload a local directory
```powershell
$FolderToUpload  = 'C:\Temp\Folder1'
$DestinationPath = 'PSOD/Test'

Get-ChildItem $folderToUpload -Recurse -File | % {
    $relativePath = Join-Path $DestinationPath $_.FullName.Replace($folderToUpload, '')
    Set-OneDriveContent -Path $relativePath -Source $_.FullName
}
```

The local directory structure:
```
PS> Get-ChildItem $folderToUpload -Recurse -File

    Directory: C:\Temp\Folder1

Mode                LastWriteTime         Length Name         
----                -------------         ------ ----         
-a----       17/07/2016     18:48         405935 test1.pdf    
-a----       17/07/2016     18:48         445694 test2.pdf    

    Directory: C:\Temp\Folder1\Folder2

Mode                LastWriteTime         Length Name         
----                -------------         ------ ----         
-a----       17/07/2016     18:48         405935 test3.pdf    
```
The output from running the upload script:
```
    Path:  /drive/root:/PSOD/Test

Type           LastModifiedTime         Length Name           
----           ----------------         ------ ----           
file           04/09/2016 15:16         405935 test1.pdf      
file           04/09/2016 15:16         445694 test2.pdf      

    Path:  /drive/root:/PSOD/Test/Folder2

Type           LastModifiedTime         Length Name           
----           ----------------         ------ ----           
file           04/09/2016 15:16         405935 test3.pdf      
```

#### Move file or directory from one location to another
```powershell
Move-OneDriveItem -Path Documents/psod.docx -Destination Documents/PSOD
# or
'Documents/psod.docx' | odmv -Destination Documents/PSOD
```

### Testing

The `tests` folder contains [Pester](https://github.com/pester/Pester) tests for all the functions. There is a `setup-test.ps1` file that is run before a `Describe` block to set up the module and helper functions. If `testing.bootstrap` is set to `true` in the `PSOD.config.json` file, then this file also sets up the required folders and dummy files in OneDrive. The test folder structure is:

```
┬ PSOD
├──┬ odcp
│  ├─── DestinationFolder
│  ├──┬ Folder1
│  │  ├─── doc1.docx
│  │  └─── excel1.xlsx
│  └─── Folder2
├──┬ odgci
│  ├──┬ Subfolder1
│  │  ├──┬ Subfolder2
│  │  │  └─── doc1.docx
│  │  ├─── doc1.docx
│  │  └─── excel1.xlsx
│  ├─── doc1.docx
│  └─── excel1.xlsx
├─── odrm
└─── odsc
```

Once an Application Id has been obtained, navigate to the `tests` directory and run `Invoke-Pester` to ensure that the module is working correctly.

### License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a>
This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
