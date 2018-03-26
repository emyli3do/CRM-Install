function Remove-CRMLanguage {
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
		Backup-Registry -ComputerName $Computer -BackupFolder "C:\Temp" -RegistryKey $reg
		
		Backs up the registry key of reg on remote computer $Computer To the local folder of C:\Temp
	
	.NOTES
		Tags: Backup Registry
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
param
	(
        [parameter(ValueFromPipeline,mandatory=$true)]
        [string[]]$ComputerName
    )
begin
    {

    }
process
    {
        Write-Verbose "UnInstalling CRM Language Pack from $_"
        $CRMLanguagePack = New-PSSession -ComputerName $_
        Invoke-Command -Session $CRMLanguagePack -ScriptBlock { $app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "StayinFront CRM language pack"} }
        Invoke-Command -Session $CRMLanguagePack -ScriptBlock { $cmd = "msiexec.exe /x " + $app.IdentifyingNumber + " /qn /L*vx C:\Temp\StayinFrontCRMLanguagePackUninstall.txt" }
        Invoke-Command -Session $CRMLanguagePack -ScriptBlock { cmd /c $cmd }
        Remove-PSSession -Session $CRMLanguagePack
    }
}
