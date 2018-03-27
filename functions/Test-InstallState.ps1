function Test-InstallState {
<#
	.SYNOPSIS
		Create the StayinFront AppPool with default settings
	
	.DESCRIPTION
		Create the StayinFront AppPool with default settings
	
	.PARAMETER ComputerName
		The target Server(s). Defaults to localhost.
	
	.PARAMETER SoftwareName
		The target software to look for.
		
	.EXAMPLE
		Test-InstallState -ComputerName Server1 -SoftwareName "My Software"
		
		Tests if "My Software" is installed on Server1
	
	.NOTES
		Tags: Software
		
		Website: N/A
		Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
		License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(ConfirmImpact = "None")]
	param (
		[parameter(ValueFromPipeline)][string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory=$true)][string[]]$SoftwareName
	)
	begin
    {
        $InstalledSoftware = @()
    }
	process
	{
        Write-Verbose "Connecting to $_"
        $TestInstallState = New-PSSession -ComputerName $_
	    $InstalledSoftware += Invoke-Command -Session $TestInstallState -ScriptBlock {param($SoftwareName)
            foreach ($Software in $SoftwareName)
            {
                Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where{$_.DisplayName -eq $Software}
            }
        } -ArgumentList $SoftwareName
        Write-Verbose "Disconnecting from $_"
        Remove-PSSession -Session $TestInstallState
    }
    end
    {
        $InstalledSoftware | Select-Object DisplayName, Publisher, InstallDate, PSComputerName | Format-Table
    }
}
