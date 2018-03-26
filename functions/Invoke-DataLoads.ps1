function Invoke-DataLoads {
<#
    .SYNOPSIS
        Copies the CRM folder contents to the CRM folder on the server.
    .DESCRIPTION
        Copies the CRM folder contents to the CRM folder on the server.
    .PARAMETER ComputerName
        The target Server(s).
    .PARAMETER Credential
        Allows you to login to $ComputerName using alternative credentials.
    .PARAMETER ReleasePath
        Path where the release folder is kept.
    .PARAMETER PushPath
        Path where we are pushing the release to.
    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
    .EXAMPLE
        $Computers | Copy-CRM -ReleasePath "\\dcshare\Apps\Prod\Data\!CurrentRelease" -PushPath "C:\Program Files(x86)\CRM\Systems\Ours"
        
        Copies CRM folder to all computers for newest release.
    .NOTES
        Tags: CRM Copy
        
        Website: N/A
        Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
        License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
param
    (
    [parameter(Mandatory=$true)]
    [string]$ReleasePath
	)
process
    {
        $destinationFolder = "C:\Temp\DataLoads"
        
        if (Test-Path -path $destinationFolder)
        {
            Write-Verbose -Message "Removing Old Folder on $computer"
            if ($pscmdlet.ShouldProcess("$destinationfolder", "Remove Directory")) {Remove-Item $destinationFolder -Recurse}
        }
        Write-Verbose -Message "Creating DataLoads Package Folder on $computer"
        If ($pscmdlet.ShouldProcess("$destinationfolder", "Create Directory")) {New-Item $destinationFolder -ItemType Directory |out-null}

        Write-Verbose -Message "Copying DataLoads Files to $computer"
        If ($pscmdlet.ShouldProcess("Item: $ReleasePath Destination: $destinationFolder\", "Copy DataLoads"))
        {
            Copy-Item -Path "$ReleasePath\Data-Loads\" -Destination $destinationFolder\ -Recurse -Force
        }
        foreach ($runfile in (Get-ChildItem $destinationFolder\ -Filter ".cmd"))
        {
            $runfile = $runfile.FullPath
            $cmd = "cmd /c ""$runfile"" /y"
            cmd /c $cmd
        }
    }
}
