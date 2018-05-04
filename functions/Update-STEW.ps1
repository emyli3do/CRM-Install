function Update-STEW {
<#
	.SYNOPSIS
		Create the StayinFront AppPool with default settings
	
	.DESCRIPTION
		Create the StayinFront AppPool with default settings
	
	.PARAMETER ComputerName
		The target Server(s). Defaults to localhost.
			
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		Update-STEW -ComputerName Server1
		
		Copies the STEW Project to Server1
	
	.NOTES
		Tags: Services
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
	param (
		[parameter(ValueFromPipeline)]
		[string[]]$ComputerName = $env:COMPUTERNAME
	)
begin
    {
     
    }
process
    {
        foreach ($computer IN $ComputerName)
        {
            Copy-Item -Path \\asm.lan\dcshare\app\sif\prod\data\release\iq-files\Pre-reqs\STEW -Destination \\$computer\C$\Temp\StayinFront\Pre-reqs\ -Force -Recurse
            Copy-Item -Path \\$computer\C$\Temp\StayinFront\Pre-reqs\STEW \\$computer\C$\inetpub\wwwroot\ -Force -Recurse

        }
    }
}
