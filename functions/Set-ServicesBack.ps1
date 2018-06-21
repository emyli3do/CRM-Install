function Set-ServicesBack {
<#
	.SYNOPSIS
		Place Service Settings back to recorded
	
	.DESCRIPTION
		Place Service Settings back to recorded
	
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
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
	param (
		[parameter(Mandatory=$true,ValueFromPipeline)]
		[string[]]$ComputerName = $env:COMPUTERNAME,
		[parameter(Mandatory=$true)]
		[PSCredential]$Credential,
		[Parameter(ParameterSetName = "ServiceName")]
		[string[]]$ServiceName,
		[parameter(Mandatory=$true)]
		[string]$Path
	)

process
    {

        $ServiceStatuses = Import-Csv $Path
       
        If(!$ServiceName)
            {
                $ServiceName = @("AeWorkflow","Watchdog","ActivElkSynch","StayinFront.MulticastHub","ActivElkComms","ActivElk")
            }
    
        ForEach ($computer in $ComputerName)
        {
            ForEach ($service in $ServiceName)
            {
                ForEach ($ServiceStatus in $ServiceStatuses)
                {
                    If ($ServiceStatus.PSComputerName -eq $computer)
                    {
                        If ($ServiceStatus.name -eq $service)
                        {
                            If ($pscmdlet.ShouldProcess("$Computer", "Set $service to file settings"))
                            {
			    	If ($ServiceStatus.startname -ne "LocalSystem")
                                {
                                    $params = @{
                                      "Namespace" = "root\CIMV2"
                                      "Class" = "Win32_Service"
                                      "Filter" = "Name='$service'"
                                    }
    
                                    $WMIservice = Get-WmiObject @params -ComputerName $computer
    
                                    $WMIservice.Change($null,
                                      $null,
                                      $null,
                                      $null,
                                      $null,
                                      $null,
                                      $credential.UserName,
                                      $credential.GetNetworkCredential().Password,
                                      $null,
                                      $null,
                                      $null) | Out-Null
                                }
    
                                If ($ServiceStatus.startmode -eq "Auto")
                                {
                                    Set-Service -Name $service -ComputerName $computer -StartupType Automatic
                                }
                                Else
                                {
                                    Set-Service -Name $service -ComputerName $computer -StartupType Disabled
                                }
                            }
                        }
                    }
                }   
            }
        }
    }
}
