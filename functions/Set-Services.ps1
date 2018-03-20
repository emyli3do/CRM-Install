function Set-Services {
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
		Stop-Services -ComputerName Server1
		
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
		[parameter(Mandatory=$true)]
		[string]$Setting,
		[string[]]$ServiceName = @("ActivElk","ActivElkComms","ActivElkSynch","AeWorkflow","StayinFront.MulticastHub","Watchdog"),
		[string]$Path
	)

process
    {
        foreach ($computer in $ComputerName)
        {
            foreach ($Service in $ServiceName)
            {
                Write-Verbose "Setting $service on $computer to $Setting"
                Set-Service -ComputerName $computer -Name $Service -StartupType $Setting
            }
        }
    }
}
