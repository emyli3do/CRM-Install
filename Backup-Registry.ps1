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
		[parameter(ValueFromPipeline)][string[]]$ComputerName = $env:COMPUTERNAME,
		[parameter(Mandatory=$true)][string]$BackupFolder,
		[PSCredential]$Credential,
		[string]$RegistryKey = "HKLM:\SOFTWARE\Wow6432Node\StayinFront"
		#[string]$Path Eventually add logging
	)
	begin
    {
        $RegCommandRegistryKey = $RegistryKey -replace ":",""
        $cmd = "cmd /c ""reg export $RegCommandRegistryKey C:\Temp\Registry.reg"" /y"
    }
	process
	{
	    If (!(Test-Path $BackupFolder)) {New-Item $BackupFolder -ItemType directory}

	    ForEach ($computer in $ComputerName)
	    {
	    	IF ($computer -eq $env:COMPUTERNAME)
		{
			If (!(Test-Path C:\Temp\))
		    	{
		    		New-Item C:\Temp -ItemType directory
		    		$CreatedFolder = 1
		    	}
		    	IF (Test-Path $RegistryKey) {cmd /c $cmd} Else {Write-Error "Could not find Registry Key on $env:computername"}
		}
		Else
		{
		    $NewPSSession = New-PSSession -ComputerName $computer
		    $CreatedFolder = Invoke-Command -Session $NewPSSession -ScriptBlock {param($RegistryKey,$cmd)
		    	If (!(Test-Path C:\Temp\))
		    	{
		    		New-Item C:\Temp -ItemType directory
		    		$CreatedFolder = 1
		    	}
		    	IF (Test-Path $RegistryKey) {cmd /c $cmd} Else {Write-Error "Could not find Registry Key on $env:computername"}
		    } -ArgumentList $RegistryKey,$cmd
		    Remove-PSSession -Session $NewPSSession
		}
        Write-Verbose "Copying Registry.reg from created computer to backup destination as $BackupFolder\$computer.reg"
		Copy-Item -Path \\$computer\C$\Temp\Registry.reg -Destination $BackupFolder\$computer.reg
		Remove-Item -Path \\$computer\C$\Temp\Registry.reg
		If ($CreatedFolder -eq 1) {Remove-Item -Path \\$computer\C$\Temp}
	    }
	}
}
