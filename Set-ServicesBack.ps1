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
    #$bDebug = 0
    #$credential = Get-Credential -Message "Please enter in the password for ASM\SIF.Service as it will be used to setup services and Web AppPools" -UserName "ASM\SIF.Service"
    #$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
    #$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'

    $ServiceStatuses = Import-Csv $Path
    #$Computers = Get-Content $LoadServerFile
    
    If(!$ServiceName)
        {
            $ServiceName = @("AeWorkflow","Watchdog","ActivElkSynch","StayinFront.MulticastHub","ActivElkComms","ActivElk")
        }

        $ServiceStatuses = @()

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
                        If ($ServiceStatus.startname -ne 'LocalSystem')
                        if ($pscmdlet.ShouldProcess("$Computer", "Set Service to file settings"))
                        {
                            {
                                $params = @{
                                  "Namespace" = "root\CIMV2"
                                  "Class" = "Win32_Service"
                                  "Filter" = "ServiceName='$service'"
                                }

                                $WMIservice = Get-WmiObject @params -ComputerName $computer

                                $WMIservice.Change($null,
                                  $null,
                                  $null,
                                  $null,
                                  $null,
                                  $null,
                                  'ASM\SIF.Service',
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

