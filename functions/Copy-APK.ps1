function Copy-APK {
<#
    .SYNOPSIS
        Copies the APK to the APK folder on the server.
        
    .DESCRIPTION
        Copies the APK to the APK folder on the server.
        
    .PARAMETER ComputerName
        The target Server(s).

    .PARAMETER ReleasePath
        Path where the release folder is kept.
        
    .PARAMETER PushPath
        Path where we are pushing the release to.
        
    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
        
    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
        
    .EXAMPLE
        $Computers | Copy-Model -ReleasePath "\\dcshare\Apps\Prod\Data\!CurrentRelease" -PushPath "C:\Program Files(x86)\CRM\Systems\Ours"
        
        Copies Model folder to all computers for newest release.
        
    .NOTES
        Tags: APK Copy
        
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
        [string]$PushPath,
        [parameter(Mandatory=$true)]
        [string]$Environment
	)
process
    {
        $PushPath = $PushPath -Replace ":", "$"
        $keepgoing = 0

        If ($Environment -eq 'Prod') {$keepgoing = 1}
        If ($Environment -eq 'UAT') {$keepgoing = 1}
        If ($Environment -eq 'QA') {$keepgoing = 1}
        If ($Environment -eq 'Dev') {$keepgoing = 1}

        If ($keepgoing -eq 1)
        {
            foreach ($computer in $Computers)
            {
                If ($pscmdlet.ShouldProcess("Item: $ReleasePath\APK\$Environment\ Destination: \\$computer\$PushPath\", "Copy APK"))
                {
                    Copy-Item -Path $ReleasePath\APK\$Environment\* -Destination \\$computer\$PushPath -Force
                }
            }
        }
        Else
        {
            Write-Error -Message "Error: Unknown Environment Specification." -Category InvalidArgument
        }
    }
}

#\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease
#C:\inetpub\StayinFrontTouch\ASMTouch\Install\
