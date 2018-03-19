function Install-CRMLanguagePack {
<#
       .SYNOPSIS
             Installs the CRM Language Pack
       
       .DESCRIPTION
             Installs the CRM Language Pack
       
       .PARAMETER ComputerName
             The target Servers. Defaults to localhost.
       
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
       [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
       param (
             [parameter(ValueFromPipeline)]$ComputerName = $env:COMPUTERNAME,
             [string]$Path
       )

process
    {
        #$bDebug = 0
        #$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
        #$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
        #$Computers = Get-Content $LoadServerFile
        $sourcefile = "$ReleasePath\StayinFrontCRM-x64 12.3.2.535\StayinFrontCRM-Languages 13.0.0.1738.msi"

        $ReleasePath = "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease"

        $jobscript = {
            Param($computer)
            
             Invoke-Command  -ScriptBlock { cmd /c 'msiexec.exe /qn /i "C:\Temp\StayinFrontLanguageInstall\StayinFrontCRM-Languages 13.0.0.1738.msi" /l*vx C:\Temp\StayinFrontLanguages.txt' }
        }
        
        ForEach ($computer in $ComputerName)
        {
            
            $destinationFolder = "\\$computer\C$\Temp\StayinFrontLanguageInstall"

            if (Test-Path -path $destinationFolder)
            {
                Write-Verbose -Message "Removing Old Folder on $computer"
                if ($pscmdlet.ShouldProcess("$destinationfolder", "Remove Directory")) {Remove-Item $destinationFolder -Recurse}
            }
            Write-Verbose -Message "Creating Install Package Folder on $computer"
            if ($pscmdlet.ShouldProcess("$destinationfolder", "Create Directory")) {New-Item $destinationFolder -ItemType Directory |out-null}

            Write-Verbose -Message "Copying Install Package to $computer"
            if ($pscmdlet.ShouldProcess("$destinationfolder", "Copy File $sourcefile")) {Copy-Item -Path $sourcefile -Destination $destinationFolder}
            Write-Verbose -Message "Connecting to $computer"
            Start-Job -ScriptBlock $jobscript -ArgumentList $computer
        }
    }
}

