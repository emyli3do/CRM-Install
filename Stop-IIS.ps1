function Stop-IIS {
<#
	.SYNOPSIS
		Stops The World Wide Web Publishing Service (IIS)
	
	.DESCRIPTION
		Stops The World Wide Web Publishing Service (IIS)
	
	.PARAMETER ComputerName
		The target Server(s).
	
	.PARAMETER Credential
		Allows you to login to $ComputerName using alternative credentials.
			
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
		[parameter(ValueFromPipeline,Mandatory=$true)]
		[string[]]$ComputerName,
		[PSCredential]$credential,
		[string]$Path
	)

process
    {
        #$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
        #$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
        #$Computers       = Get-Content $LoadServerFile
        
        ForEach ($computer in $ComputerName)
        {
            Write-Verbose -Message "Connecting to $computer"
            If ($pscmdlet.ShouldProcess("$computer", "Stop IIS Service"))
            {
                If ($credential)
                {
                    Invoke-Command -ComputerName $computer -Credential $credential -Args $computer -ScriptBlock {
                        param($Invokecomputer)
                        If ((Get-Service -Name W3SVC -ErrorAction SilentlyContinue).Status -eq "Running")
                        {
                            cmd /c 'SC.EXE STOP W3SVC'
                        }
                    }
                }
                Else
                {
                    Invoke-Command -ComputerName $computer -Args $computer -ScriptBlock {
                        param($Invokecomputer)
                        If ((Get-Service -Name W3SVC -ErrorAction SilentlyContinue).Status -eq "Running")
                        {
                            cmd /c 'SC.EXE STOP W3SVC'
                        }
                    }
                }
            }
        }
    }
}

