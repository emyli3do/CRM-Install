function Copy-Model {
<#
	.SYNOPSIS
		Copies the model folder contents to the model folder on the server.
	
	.DESCRIPTION
		Copies the model folder contents to the model folder on the server.
	
	.PARAMETER ComputerName
		The target Server(s).
	
	.PARAMETER Credential
		Allows you to login to $ComputerName using alternative credentials.
    
    .PARAMETER ReleasePath
        Path where the release folder is kept.

    .PARAMETER PushPath
        Path where the release folder is kept.

	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		$Computers | Copy-Model -ReleasePath "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease" -PushPath "C:\Program Files(x86)\StayinFront\CRM\Systems\ASM"
		
		Starts IIS on all the servers that are in the $Computers array
	
	.NOTES
		Tags: Web IIS Start
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High)]
	param (
		[parameter(ValueFromPipeline,Mandatory=$true)]
		[string[]]$ComputerName,
		[PSCredential]$credential,
		[parameter(Mandatory=$true)]
        [string]$ReleasePath
        [parameter(Mandatory=$true)]
        [string]$PushPath
	)
process
    {
        $PushPath -Replace ":", "$"
        foreach ($computer in $Computers)
        {
            If ($pscmdlet.ShouldProcess("$computer", "Copying Model Folder from $Release Path"))
            {
                Copy-Item -Path "$ReleasePath\Model\" -Destination \\$computer\$PushPath\ -Recurse -Force
            }
        }
    }
}
