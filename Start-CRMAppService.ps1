function Start-CRMAppService {
<#
	.SYNOPSIS
		Starts The Application Service
	
	.DESCRIPTION
		Starts The Application Service
	
	.PARAMETER ComputerName
		The target Server(s).
	
	.PARAMETER Credential
		Allows you to login to $ComputerName using alternative credentials.
			
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		$Computers | Start-CRMAppService
		
		Starts Application Service on all the servers that are in the $Computers array
	
	.NOTES
		Tags: Web CRM Application Service Start
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
	param (
		[parameter(ValueFromPipeline,Mandatory=$true)]
		[string[]]$ComputerName,
		[PSCredential]$credential,
		[string]$Path
	)
process
    {
        foreach ($computer in $ComputerName)
        {
            Set-Service -ComputerName $computer -Name ActivElk -StartupType Automatic
        }

        foreach ($computer in $ComputerName)
        {
            $NewPSSession = New-PSSession -ComputerName $computer
            Invoke-Command -Session $NewPSSession {Start-Service -Name ActivElk -WarningAction SilentlyContinue}
            Remove-PSSession -Session $NewPSSession
        }
    }
}

