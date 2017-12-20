function Get-ServiceSettings {
<#
	.SYNOPSIS
		Take note of the service settings
	
	.DESCRIPTION
		Take note of the service settings
	
	.PARAMETER ComputerName
		The target Servers. Defaults to localhost.
	
	.PARAMETER Credential
		Allows you to login to $ComputerName using alternative credentials.
	
	.PARAMETER Service
		Services to track
	
	.PARAMETER Path
		The path to store the file that has the information
		
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		Get-ServiceSettings -ComputerName Server1 -Path C:\temp\ServicesSttings.csv
		
		Adds the local C:\temp\cert.cer to the remote server Server1 in LocalMachine\My (Personal).
	
	.NOTES
		Tags: Services
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
	param (
		[parameter(ValueFromPipeline)]$ComputerName = $env:COMPUTERNAME,
		[PSCredential]$Credential,
        [string]$Service = @("AeWorkflow","Watchdog","ActivElkSynch","StayinFront.MulticastHub","ActivElkComms","ActivElk"),
		[string]$Path
	)

begin
    {
        #$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
        #$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
        #$Computers       = Get-Content $LoadServerFile

        $ServiceStatuses = @()

        ForEach ($computer in $ComputerName)
        {
            Write-Message -Level Verbose -Message "Connecting to $computer"
            ForEach ($serv in $service)
            {
                Write-Message -Level Verbose -Message "Processing $serv"
                $objService = Get-WmiObject -Class WIN32_Service -ComputerName $computer -Filter "Name = '$serv'"
                $ServiceStatuses += $objService | select PSComputerName, name, startname, startmode
            }

        }

        $ServiceStatuses | select PSComputerName, name, startname, startmode | Export-Csv $Path -notypeinformation
        $ServiceStatuses | Format-Table
    }
}
