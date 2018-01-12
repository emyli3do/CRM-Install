function Delete-Cache {
<#
	.SYNOPSIS
		Deletes Cache files that should be re-created after release.
	
	.DESCRIPTION
		Deletes Cache files that should be re-created after release.
	
	.PARAMETER ComputerName
		The target Server(s).
			
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		$Computers | Delete-Cache -BaseFolder "C$\ProgramData\StayinFront\"
		
		Deletes the Cache files on all computers listed in the $Computers Array
	
	.NOTES
		Tags: Cahce
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
	param (
		[parameter(ValueFromPipeline,Mandatory=$true)]
		[string[]]$ComputerName,
        [parameter(Mandatory=$true)]
        [string]$BaseFolder
	)

process
    {
        $BaseFolder = $BaseFolder -Replace ":", "$"
        foreach ($computer in $ComputerName)
        {
            If ($pscmdlet.ShouldProcess("$computer", "Delete Cache"))
            {
                Remove-Item -Path \\$computer\$BaseFolder\ServerModels\*
                Remove-Item -Path \\$computer\$BaseFolder\ClientModels\32\*
                Remove-Item -Path \\$computer\$BaseFolder\ClientModels\64\*
            }
        }
    }
}
