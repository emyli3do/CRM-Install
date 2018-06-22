function Install-CRMLanguagePack {
<#
       .SYNOPSIS
             Installs the CRM Language Pack       
       .DESCRIPTION
             Installs the CRM Language Pack
       .PARAMETER ComputerName
             The target Servers. Defaults to localhost.
       .PARAMETER Credential
             Allows you to login to $ComputerName using alternative credentials.
       .PARAMETER WhatIf
             If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
       .PARAMETER Confirm
             If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
       .EXAMPLE
             Get-ServiceSettings -ComputerName Server1 -Path C:\temp\ServicesSttings.csv
             
             Adds the local C:\temp\cert.cer to the remote server Server1 in LocalMachine\My (Personal).       
       .NOTES
             Tags: Services
             
             Website: N/A
             Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
             License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
    param (
            [parameter(ValueFromPipeline,Mandatory=$true)]
            [string[]]$ComputerName = $env:COMPUTERNAME,
            [parameter(Mandatory=$true)]
            [string]$ReleasePath
    )
    begin
    {
        $sourcefolder = (Get-ChildItem $ReleasePath -Filter "StayinFrontCRM*" -Directory).Name
        $sourcefolder = "$ReleasePath\$sourcefolder"
        
        $sourcefile = (Get-ChildItem $sourcefolder -Filter "StayinFrontCRM-Languages*" -File).Name
        $sourcefile = "$sourcefolder\$SourceFile"

        $FileHashCurrentRelease = (Get-ChildItem $sourcefile).LastWriteTime

    }
    process
    {
        $computer = $_
        $destinationFolder = "\\$computer\C$\Temp\StayinFrontLanguageInstall"
        $DestinationFile = "$DestinationFolder\StayinFrontCRM-Languages.msi"

        <#START - Copy New Installer Package to Computer#>
        If (Test-Path -Path $DestinationFile)
        {
            Write-Verbose "Calculating Installer File Hash"
            $FileHashServer        = (Get-ChildItem $DestinationFile).LastWriteTime
            Write-Verbose "File Hash for release CRM: $FileHashCurrentRelease"
            Write-Verbose "File Hash on server      : $FileHashServer"
        }
        If ($FileHashCurrentRelease -ne $FileHashServer)
        {
            Write-Verbose -Message "Removing Old Folder on $computer"
            if ($pscmdlet.ShouldProcess("$destinationfolder", "Remove Directory"))
            {
              If (Test-Path $destinationFolder)
              {
                     Remove-Item $destinationFolder -Recurse
              }
            }
            
            Write-Verbose -Message "Creating Install Package Folder on $computer"
            if ($pscmdlet.ShouldProcess("$destinationfolder", "Create Directory")) {New-Item $destinationFolder -ItemType Directory |out-null}

            Write-Verbose -Message "Copying Install Package to $computer"
            if ($pscmdlet.ShouldProcess("$destinationfolder", "Copy File $sourcefile")) {Copy-Item -Path $sourcefile -Destination "$DestinationFile"}
        }
        Else
        {
            Write-Host "Files Identical so not copied"
        }
        <#END - Copy New Installer Package to Computer#>

        Write-Verbose -Message "Installing to $computer"
        #Action
        $FilePath = (Get-Module -ListAvailable CRMInstall).path
        $FilePath = $FilePath | Split-Path -Parent
        $filepath = "$FilePath\functions\Install-CRMLanguagePackPerServer.ps1"
        Invoke-Command -ComputerName $computer -FilePath $filepath

    }
}

