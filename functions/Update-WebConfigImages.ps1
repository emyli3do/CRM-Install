function Update-WebConfigImages {
<#
    .SYNOPSIS
        Copies the APK to the APK folder on the server.
        
    .DESCRIPTION
        Copies the APK to the APK folder on the server.
        
    .PARAMETER ComputerName
        The target Server(s).
    .PARAMETER ReleasePath
        Path where the release folder is kept.
        
    .PARAMETER PushPath
        Path where we are pushing the release to.
        
    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
        
    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
        
    .EXAMPLE
        $Computers | Copy-Model -ReleasePath "\\dcshare\Apps\Prod\Data\!CurrentRelease" -PushPath "C:\Program Files(x86)\CRM\Systems\Ours"
        
        Copies Model folder to all computers for newest release.
        
    .NOTES
        Tags: APK Copy
        
        Website: N/A
        Copyright: (C) Josh Simar, josh.simar@advantagesolutions.net
        License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param
    (
        [parameter(ValueFromPipeline,Mandatory=$true)]
		[string[]]$ComputerName,
		[parameter(Mandatory=$true)]
        [string]$ReleasePath,
        [ValidateSet("Prod","UAT","QA","Dev")]
        [string]$Environment,
	[string]$Setting
	)
process
    {
        $computer = $_
        
        Write-Verbose "Changing web.config on computer $computer"

        $destinationFolder = "\\$computer\C$\inetpub\Touch\TouchASM"
        $DestinationFile = "$DestinationFolder\web.config"
        
        $ReadFileName = "$ReleasePath\$Setting" + $Environment + ".txt"
        
        If (Test-Path $ReadFileName)
        {
            $FileEnvironment = Get-Content ($ReadFileName)
            Write-Verbose "Images Folder Located at: $FileEnvironment"

            $bLineToChange = 0
            $FileOriginal = Get-Content ($DestinationFile)
            $OnLine = 0
            
            $ModifyLine = "        <value>"
            $ModifyLine += $FileEnvironment
            $ModifyLine += "</value>"
            
            Foreach ($line in $FileOriginal)
                {
                    If ($line -ne "")
                    {
                        $OnLine += 1
                        If ($bLineToChange -eq 1)
                        {
                            [String[]]$FileModified +=  "$ModifyLine"
                            $bLineToChange = 0
                            
                            Write-Verbose "Line $OnLine Changed from $line to $ModifyLine"
                        }
                        Else
                        {
                            If ($line -like "*<setting name=`"$Setting`" serializeAs=`"String`">*")
                            {
                                $bLineToChange = 1
                            }
                            [String[]]$FileModified += "$line"
                        }
                    }
                }  

            Write-Verbose "Writing File with new content"
            Set-Content $DestinationFile $FileModified
	    
	    Clear-Variable -Name FileModified
        }
        Else
        {
            Write-Error -Message "Error: Images File not found." -Category InvalidArgument
        }
    }
}
