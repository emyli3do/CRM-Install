function Set-StayinFrontAppPool {
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
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
param
    (
		[parameter(ValueFromPipeline)]
		$ComputerName = $env:COMPUTERNAME
	)

process
    {
    	$Computer = $_
        if ($pscmdlet.ShouldProcess("$Computer", "Add and configure AppPool"))
        {
            $NewPSSession = New-PSSession -ComputerName $Computer
            Invoke-Command -Session $NewPSSession -ScriptBlock { Import-Module WebAdministration }
            Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name managedRuntimeVersion -Value 'v2.0' }
            Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name Failure -Value @{RapidFailProtection='False'} }
            Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name Recycling.PeriodicRestart.time -Value '00:00:00' }
            Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"} }
            Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name Recycling.PeriodicRestart.privateMemory -Value 1200000 }
            Remove-PSSession -Session $NewPSSession        
        }
    }
}
