function Remove-InstallFiles {
<#
    .SYNOPSIS
        Removes no longer needed files from install
    .DESCRIPTION
        Removes no longer needed files from install
    .PARAMETER ComputerName
        The target Server(s).    
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
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
	param (
		[parameter(ValueFromPipeline,Mandatory=$true)]
		[string[]]$ComputerName
	)
process
    {
        $computer = $_
        If (Test-Path \\$computer\C$\Temp\StayinFrontInstall ) {Remove-Item -Path \\$computer\C$\Temp\StayinFrontInstall -Recurse -Force | Out-Null}
        If (Test-Path \\$computer\C$\Temp\StayinFrontLanguageInstall) {Remove-Item -Path \\$computer\C$\Temp\StayinFrontLanguageInstall -Recurse -Force | Out-Null}
        
        $InstallFiles = New-PSSession -ComputerName $_
        Invoke-Command -Session $InstallFiles -ScriptBlock {
            If (Get-ScheduledTask -TaskName "Install StayinFront CRM Languages" -ErrorAction SilentlyContinue)
            {
                Invoke-Command -ScriptBlock {Unregister-ScheduledTask -TaskName "Install StayinFront CRM Languages" -Confirm:$false}
            }
            If (Get-ScheduledTask -TaskName "Install StayinFront CRM" -ErrorAction SilentlyContinue)
            {
                Invoke-Command -ScriptBlock {Unregister-ScheduledTask -TaskName "Install StayinFront CRM" -Confirm:$false}
            }
        }
        Remove-PSSession -Session $InstallFiles
    }
}
