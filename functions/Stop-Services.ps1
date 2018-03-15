function Stop-Services {
<#
	.SYNOPSIS
		Stops Specified Services
	
	.DESCRIPTION
		Stops Specified Services
	
	.PARAMETER ComputerName
		The target Server(s).

	.PARAMETER ServiceName
		Services to stop
			
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		Stop-Services -ComputerName Server1 -Path C:\temp\ServicesSttings.csv
		
		NEEDS WRITTEN
	
	.NOTES
		Tags: Services
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
	param (
		[parameter(ValueFromPipeline,Mandatory=$true)]
		[string[]]$ComputerName,
		[string[]]$ServiceName = @("AeWorkflow","Watchdog","ActivElkSynch","StayinFront.MulticastHub","ActivElkComms","ActivElk"),
		[string]$Path
	)

	process
	{foreach ($computer in $Computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock {$ServiceNames = "AeWkfSvr","StayinFront.Watchdog.Monitor","AeSynch","StayinFront.MulticastHub","aeCommsE","AeServer","mmc","StayinFront.ServerMonitor","StayinFrontCRM"}
    Invoke-Command -Session $NewPSSession -ScriptBlock {foreach ($ServiceName in $ServiceNames) {Stop-Process -Name $ServiceName -Force -ErrorAction SilentlyContinue}}
    Remove-PSSession -Session $NewPSSession
}
	}
}