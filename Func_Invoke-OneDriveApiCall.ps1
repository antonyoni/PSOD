################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Invoke-OneDriveApiCall {
    <#
        .SYNOPSIS
        Wrapper for Invoke-RestMethod to send commands to the OneDrive API.
        
        .EXAMPLE
        Invoke-OneDriveApiCall -Path $path -Token $token.Token

        .EXAMPLE
        'drive', 'drives' | Invoke-OneDriveApiCall -Token $token.Token

        .EXAMPLE
        $token | Invoke-OneDriveApiCall -Path 'drive/view.recent'
    #>
    [CmdletBinding()]
    [OutputType([PsObject])]
    Param
    (
        # API resource path.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [Alias("ApiUrl", "Resource")]
        [string]$Path,

        # The API authentication token.
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [Alias("ApiToken", "AccessToken")]
        [PsObject]$Token,

        # The method used for the API request.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,

        # Data to be sent as part of the API request.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]  
        $Body,

        # Gets the content of the request from the specified file.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]  
        [string]$InFile,

        # Saves the response to the specified path.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]  
        [string]$OutFile,

        # Additional headers for the request.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]  
        [hashtable]$AdditionalRequestHeaders
    )

    Process {
        
        Write-Verbose $PSOD
        
        $requestUri = joinPath $PSOD.api.url $Path

        Write-Verbose "Request URI:`n$requestUri"

        $requestHeaders = @{
            Authorization = "bearer $Token"
            Accept        = 'application/json'
        }

        if ($AdditionalRequestHeaders) {
            $requestHeaders += $AdditionalRequestHeaders
        }

        $irmParams = @{
            Uri         = $requestUri
            Headers     = $requestHeaders
            ContentType = 'application/json'
        }

        if ($Method) {
            $irmParams['Method'] = $Method
        }

        if ($Body) {
            $irmParams['Body'] = $Body
        }

        if ($InFile) {
            $irmParams['InFile'] = $InFile
        }

        if ($OutFile) {
            $irmParams['OutFile'] = $OutFile
        }

        try {
            $rsp = Invoke-RestMethod @irmParams
        } catch {
            $errorMessage = $err.ErrorDetails.Message | ConvertFrom-Json
            Write-Error "'$Path' - $($errorMessage.error.message). (Error code: $($errorMessage.error.code))"
            $httpResponse = $err.Exception.Response
            Write-Verbose "HTTP status code        : $($httpResponse.StatusCode.value__)"
            Write-Verbose "HTTP status description : $($httpResponse.StatusDescription)"
        }

        Write-Output $rsp
    }
    
}

Export-ModuleMember -Function 'Invoke-OneDriveApiCall'

#. .\setup-test.ps1
#$path = 'drive'
#Invoke-OneDriveApiCall -Path $path -Token $token -Verbose
#'drive', 'drive' | Invoke-OneDriveApiCall -Token $token
#Get-Content .\onedrive.opt | Get-OneDriveAuthToken | Invoke-OneDriveApiCall -Resource drive
#$token | Invoke-OneDriveApiCall -Path 'drive/view.recent'
<#
[pscustomobject]@{
    Path  = 'drive/shared'
    Token = $token
} | Invoke-OneDriveApiCall
#>
<#
Invoke-OneDriveApiCall -Path 'drive/root:/Documents:/children'`
                   -Token $token `
                   -Method Post `
                   -Body ([ordered]@{
                       name   = 'TestFolder'
                       folder = @{}
                   } | ConvertTo-Json) `
                   -Verbose
#>
