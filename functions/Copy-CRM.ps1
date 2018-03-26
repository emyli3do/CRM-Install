function Copy-CRM {
<#
    .SYNOPSIS
        Copies the CRM folder contents to the CRM folder on the server.

    .DESCRIPTION
        Copies the CRM folder contents to the CRM folder on the server.

    .PARAMETER ComputerName
        The target Server(s).

    .PARAMETER Credential
        Allows you to login to $ComputerName using alternative credentials.

    .PARAMETER ReleasePath
        Path where the release folder is kept.

    .PARAMETER PushPath
        Path where we are pushing the release to.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        $Computers | Copy-CRM -ReleasePath "\\dcshare\Apps\Prod\Data\!CurrentRelease" -PushPath "C:\Program Files(x86)\CRM\Systems\Ours"
        
        Copies CRM folder to all computers for newest release.

    .NOTES
        Tags: CRM Copy
        
        Website: N/A
        Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
        License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
	param (
		[parameter(ValueFromPipeline,Mandatory=$true)]
		[string[]]$ComputerName,
		[parameter(Mandatory=$true)]
        [string]$ReleasePath,
        [parameter(Mandatory=$true)]
        [string]$PushPath
	)
process
    {
        $PushPath = $PushPath -Replace ":", "$"
        foreach ($computer in $ComputerName)
        {
            If ($pscmdlet.ShouldProcess("Item: $ReleasePath Destination: \\$computer\$PushPath\", "Copy CRM"))
            {
                Copy-Item -Path "$ReleasePath\CRM\" -Destination \\$computer\$PushPath\ -Recurse -Force
            }
        }
    }
}

