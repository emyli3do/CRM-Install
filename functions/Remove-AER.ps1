function Remove-AER {
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
        $Computers | Remove-AER
        
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
        [string]$Path = 'C:\Program Files (x86)\StayinFront\CRM\'
	)
process
    {
        ForEach ($computer in $ComputerName)
        {
            $NewPSSession = New-PSSession -ComputerName $computer
            Invoke-Command -Session $NewPSSession -ScriptBlock {param($Path) Get-ChildItem -Path $Path -Filter "*.aer" | Remove-Item } -ArgumentList $Path
            Remove-PSSession -Session $NewPSSession
        }
    }
}
