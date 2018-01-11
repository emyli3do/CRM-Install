function Backup-Registry {
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
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
	param (
		[parameter(ValueFromPipeline)]$ComputerName = $env:COMPUTERNAME,
		[parameter(Mandatory=$true)][string]$BackupFolder,
		[PSCredential]$Credential,
		[string]$RegistryKey
		#[string]$Path Eventually add logging
	)

begin
{
    If(!($RegistryKey)) {$RegistryKey = "HKLM\SOFTWARE\Wow6432Node\StayinFront"}
    If (!(Test-Path $BackupFolder)) {New-Item $BackupFolder -directory}
    
    ForEach ($computer in $ComputerName)
    {
        $NewPSSession = New-PSSession -ComputerName $computer
        Invoke-Command -Session $NewPSSession -ScriptBlock { 
		If (!(Test-Path C:\Temp\))
		{
			New-Item C:\Temp -directory
			$CreatedFolder = 1
		}
		cmd /c "reg export $ReristryKey C:\Temp\Registry.reg"
        }
	Remove-PSSession -Session $NewPSSession
	Copy-Item -Path \\$computer\C$\Temp\Registry.reg -Destination C:\Temp\Registry\$computer.reg
	Remove-Item -Path \\$computer\C$\Temp\Registry.reg
	If ($CreatedFolder -eq 1) {Remove-Item -Path \\$computer\C$\Temp}
    }
}
