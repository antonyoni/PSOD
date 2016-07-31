$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = Split-Path $here -Parent

Import-Module $modulePath
. (Join-Path $modulePath PSOD.helpers.ps1)
