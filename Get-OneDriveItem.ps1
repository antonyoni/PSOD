

if ((Get-Date) -ge $token.ExpiryDT) {
    $token = Get-Content .\PSOD\onedrive.opt | Get-OneDriveAuthToken
}

#$rsp = $token | Invoke-OneDriveApiCall -Path 'drive/root:/:/children'
#$rsp.value | select name, id, size, webUrl | Format-Table

Function Get-OneDriveItem ($Path, [switch]$Recurse) {
    $p = JoinPath 'drive/root:/' $Path
    $p = JoinPath $p ':/children'
    $rsp = $token | Invoke-OneDriveApiCall -Path $p
    if ($rsp.value) {
        Write-Output $rsp.value
    } else {
        Write-Output $rsp
    }
    if ($Recurse) {
        $rsp.value | ? { $_.folder.childCount -gt 0 } | % {
            Get-OneDriveItem (JoinPath $Path $_.name) -Recurse
        }
    }
}

Get-OneDriveItem -Recurse | select name, id, size, webUrl | Format-Table
