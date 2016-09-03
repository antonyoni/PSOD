$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Split-Path $here -Parent

if (Get-Module PSOD) { Remove-Module PSOD }

Import-Module $modulePath
. (Join-Path $modulePath PSOD.helpers.ps1)
