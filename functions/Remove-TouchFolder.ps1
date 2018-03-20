function Remove-TouchFolder {
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
		Remove-TouchFolder -ComputerName $Computer
		
		Backs up the registry key of reg on remote computer $Computer To the local folder of C:\Temp
	
	.NOTES
		Tags: Backup Registry
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
	param (
		[parameter(ValueFromPipeline)][string[]]$ComputerName = $env:COMPUTERNAME
		#[string]$Path Eventually add logging
	)
	begin
    {

    }
	process
	{
        ForEach ($computer in $ComputerName)
        {
            $NewPSSession = New-PSSession -ComputerName $computer
            Invoke-Command -Session $NewPSSession -ScriptBlock { Remove-Item –Path "C:\Program Files (x86)\StayinFront\Touch" -Force -Recurse -ErrorAction SilentlyContinue }
            Remove-PSSession -Session $NewPSSession
        }
    }
}

