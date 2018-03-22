function Add-MimeType {
<#
	.SYNOPSIS
		Create the StayinFront AppPool with default settings
	
	.DESCRIPTION
		Create the StayinFront AppPool with default settings
	
	.PARAMETER ComputerName
		The target Server(s). Defaults to localhost.
	
	.PARAMETER Credential
		Allows you to login to $ComputerName using alternative credentials.

    .PARAMETER Path
		The path to store the file that has the information
		
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		New-StayinFrontAppPool -ComputerName Server1 -Path C:\temp\ServicesSttings.csv
		
		Creates the StayinFront AppPool with default settings
	
	.NOTES
		Tags: Services
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
	param (
		[parameter(ValueFromPipeline)]
		[string[]]$ComputerName = $env:COMPUTERNAME
    [parameter(mandatory=$true)]
		[string]$FileExtension
    [parameter(mandatory=$true)]
		[string]$MimeType
    
	)
begin
    {
        If (!($FileExtension.StartsWith("."))
        {
            $FileExtension = ".$FileExtension"
        }
    }
process
    {
    foreach ($Computer in $ComputerName)
    {
        if ($pscmdlet.ShouldProcess("$Computer", "Add Mime Type $fileextension"))
        {
            $NewPSSession = New-PSSession -ComputerName $Computer
            Invoke-Command -Session $NewPSSession -ScriptBlock { Import-Module WebAdministration }
            Invoke-Command -Session $NewPSSession -ScriptBlock {param($FileExtension,$MimeType)
                IF ((Get-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Filter "system.webServer/staticContent/mimeMap[@fileExtension='$FileExtension']" -Name fileExtension) -eq $null)
                {
                    Add-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" "system.webServer/staticContent" -name collection -value @{fileExtension=$FileExtension; mimeType=,$MimeType}
                }
            } -ArgumentList $FileExtension,$MimeType
            Remove-PSSession -Session $NewPSSession        
        }
    }
}
