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
	
	.PARAMETER ServiceName
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
		[Parameter(ParameterSetName = "ServiceName")]
		[string[]]$ServiceName,
        	#[string]$Service = @("AeWorkflow","Watchdog","ActivElkSynch","StayinFront.MulticastHub","ActivElkComms","ActivElk"),
		[string]$Path
	)

begin
    {
        #$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
        #$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
        #$Computers       = Get-Content $LoadServerFile

        If(!$ServiceName)
        {
            $ServiceName = @("AeWorkflow","Watchdog","ActivElkSynch","StayinFront.MulticastHub","ActivElkComms","ActivElk")
        }

        $ServiceStatuses = @()

        ForEach ($computer in $ComputerName)
        {
            Write-Verbose -Message "Connecting to $computer"
            ForEach ($Service in $ServiceName)
            {

                Write-Verbose -Message "Processing $Service"
                $objService = Get-WmiObject -Class WIN32_Service -ComputerName $computer -Filter "Name = '$Service'"
                $ServiceStatuses += $objService | select PSComputerName, name, startname, startmode

            }

        }
	    If ($Path)
        {
		    $ServiceStatuses | select PSComputerName, name, startname, startmode | Export-Csv $Path -notypeinformation
	    }
        
        $ServiceStatuses | Format-Table
    }
}
