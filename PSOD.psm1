################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

################################################################################

Add-Type -Language CSharp -TypeDefinition @"
using System;
using System.Text.RegularExpressions;

public class OneDriveToken {

    private string _accessToken;
    private string _type;
    private string _scope;
    private string _userId;
    private int _expires;
    private DateTime _created;

    public string AccessToken {
        get { return this._accessToken; }
    }

    public string Type {
        get { return this._type; }
    }

    public string Scope {
        get { return this._scope; }
    }

    public string UserId {
        get { return this._userId; }
    }

    public int ExpiresIn {
        get { return this._expires; }
    }

    public DateTime ExpiryDate {
        get { return this._created.AddSeconds(ExpiresIn); }
    }

    public OneDriveToken (string accessToken, string type, string scope, string userId, int expiresIn) {
        this._accessToken = accessToken;
        this._type = type;
        this._scope = scope;
        this._userId = userId;
        this._expires = expiresIn;
        this._created = System.DateTime.Now;
    }

    public OneDriveToken (string responseUrl) : this (
        Regex.Match(responseUrl, "access_token=(.+?)&").Groups[1].Value,
        Regex.Match(responseUrl, "token_type=(.+?)&").Groups[1].Value,
        Regex.Match(responseUrl, "scope=(.+?)&").Groups[1].Value,
        Regex.Match(responseUrl, "user_id=(.+?)(&|$)").Groups[1].Value,
        Convert.ToInt32(Regex.Match(responseUrl, "expires_in=(.+?)&").Groups[1].Value)
    ) {}

    public override string ToString() {
        return AccessToken;
    }

}
"@

################################################################################

. (Join-Path -Path $psScriptRoot -ChildPath 'PSOD.helpers.ps1')

Get-ChildItem -Path $psScriptRoot `
    | ? { $_ -match '^Func_.+$' } `
    | % {
        . (Join-Path -Path $psScriptRoot -ChildPath $_)
    }
