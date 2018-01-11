function Start-IIS {
<#
	.SYNOPSIS
		Starts The World Wide Web Publishing Service (IIS)
	
	.DESCRIPTION
		Starts The World Wide Web Publishing Service (IIS)
	
	.PARAMETER ComputerName
		The target Server(s).
	
	.PARAMETER Credential
		Allows you to login to $ComputerName using alternative credentials.
			
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		$Computers | Start-IIS
		
		Starts IIS on all the servers that are in the $Computers array
	
	.NOTES
		Tags: Web IIS Start
		
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
            If ($pscmdlet.ShouldProcess("$computer", "Start IIS Service"))
            {
                If ($credential)
                {
                    Invoke-Command -ComputerName $computer -Credential $credential -Args $computer -ScriptBlock {
                        param($Invokecomputer)
                        If ((Get-Service -Name W3SVC -ErrorAction SilentlyContinue).Status -eq "Stopped")
                        {
                            cmd /c 'SC.EXE START W3SVC'
                        }
                    }
                }
                Else
                {
                    Invoke-Command -ComputerName $computer -Args $computer -ScriptBlock {
                        param($Invokecomputer)
                        If ((Get-Service -Name W3SVC -ErrorAction SilentlyContinue).Status -eq "Stopped")
                        {
                            cmd /c 'SC.EXE START W3SVC'
                        }
                    }
                }
            }
        }
    }
}
