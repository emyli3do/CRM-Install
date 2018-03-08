$keepgoing = 0

While ($keepgoing -ne 1)
{
    If ($keepgoing -eq 2) {Write-Host "The only acceptable answers to the question are A, W or C. Please make one of these selections"}
    $keepgoing = 2
    $purpose = Read-Host "Are you installing this as an App Server (A) or an App/Web Server (W) or would you like to cancel out of the process completely (C) (A or W or C)?"
    If ($purpose -eq 'A') {$keepgoing = 1}
    If ($purpose -eq 'W') {$keepgoing = 1}
    If ($purpose -eq 'C') {$keepgoing = 1}
}

If ($purpose -eq 'C') {Exit}
If ($purpose -eq 'A') {Write-Host "You are installing an Application Server"}
If ($purpose -eq 'W') {Write-Host "You are installing an Application and Web Server"}

Read-Host "Press Enter to continue . . . "

$keepgoing = 0

While ($keepgoing -ne 1)
{
    If ($keepgoing -eq 2) {Write-Host "The only acceptable answers to the question are Dev, QA, UAT, Prod. Please make one of these selections"}
    $keepgoing = 2
    $purposeEnvironment = Read-Host "Which environment is this server for? (Dev, QA, UAT, Prod)?"
    If ($purposeEnvironment -eq 'Prod') {$keepgoing = 1}
    If ($purposeEnvironment -eq 'UAT') {$keepgoing = 1}
    If ($purposeEnvironment -eq 'QA') {$keepgoing = 1}
    If ($purposeEnvironment -eq 'Dev') {$keepgoing = 1}
}

Write-Host "Installing StayinFront MSI"
$InstallRunning = 1
cmd /c 'msiexec.exe /qn /i "C:\Temp\StayinFront\CRM_InstallFromHere-x64\StayinFrontCRM-x64.msi" INSTALL_SERVER=1 INSTALL_CLIENT=1 INSTALL_APPSERVER=1 INSTALL_WORKFLOW=1 INSTALL_SYNCH=1 INSTALL_SYNCHSERVER=1 INSTALL_COMMSSERVER=1 INSTALL_SYNCHHTTP=1 INSTALL_WEB=1 INSTALL_TOUCH=1 INSTALL_WTS=1 /l*vx C:\Temp\StayinFrontCRM-x64InstallLog.txt'

While ($InstallRunning -eq 1)
{
    $process = "msiexec.exe"
    $InstallRunning = 0
    ForEach ($CommandLine in Get-WmiObject Win32_Process -Filter "name = '$process'" | Select-Object CommandLine ){If ($CommandLine -like "*StayinFrontCRM-x64.msi*") {$InstallRunning = 1}}
}

Write-Host "StayinFront MSI Installed"
Read-Host "Press Enter to continue . . . "

Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    Installing StayinFront Setup                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    This step will require manual intervention                                                                       *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    When the dialog comes up hit Install                                                                             *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    After the dialog has focus again hit Close                                                                       *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
Read-Host "Press Enter to continue . . . "

$InstallRunning = 1
cmd /c 'C:\Temp\StayinFront\CRM_InstallFromHere-x64\Setup.exe'

While ($InstallRunning -eq 1)
{
    $process = "Setup.exe"
    $InstallRunning = 0
    ForEach ($CommandLine in Get-WmiObject Win32_Process -Filter "name = '$process'" | Select-Object CommandLine ){If ($CommandLine -like "*Setup.exe*") {$InstallRunning = 1}}
}

Write-Host "StayinFront Setup Installed"
Read-Host "Press Enter to continue . . . "

Write-Host "Installing StayinFront Languages MSI"
$InstallRunning = 1
cmd /c 'msiexec.exe /qn /i "C:\Temp\StayinFront\CRM_InstallFromHere-x64\StayinFrontCRM-Languages.msi" /l*vx C:\Temp\StayinFrontLanguages.txt'

While ($InstallRunning -eq 1)
{
    $process = "msiexec.exe"
    $InstallRunning = 0
    ForEach ($CommandLine in Get-WmiObject Win32_Process -Filter "name = '$process'" | Select-Object CommandLine ){If ($CommandLine -like "*StayinFrontCRM-Languages.msi*") {$InstallRunning = 1}}
}

Write-Host "StayinFront Languages MSI Installed"
Read-Host "Press Enter to continue . . . "


Write-Host "Copy System Folder from install to new server"
robocopy "C:\Temp\StayinFront\Systems" "C:\Program Files (x86)\StayinFront\CRM\Systems" /E /log+:C:\Temp\SystemsFileCopy.txt
Write-Host "System Folder Copied"
Read-Host "Press Enter to continue . . . "

If ($purposeEnvironment -eq 'Prod') {$credname = "ASM\SIF.Service"}
If ($purposeEnvironment -eq 'UAT')  {$credname = "ASM\UAT.SIF.Service"}
If ($purposeEnvironment -eq 'QA')   {$credname = "ASM\QA.SIF.Service"}
If ($purposeEnvironment -eq 'Dev')  {$credname = "ASM\SIF.Service"}

$credential = Get-Credential -Message "Please enter in the password for $credname as it will be used to setup services and Web AppPools" -UserName $credname

Write-Host "Adding $credname as being able to login as a service"

$ChangeFrom = "SeServiceLogonRight = "
$ChangeTo = "SeServiceLogonRight = $credname,"
$fileName = "C:\Temp\SecPolExport.cfg"
secedit /export /cfg $filename | Out-Null
(Get-Content $fileName) -replace $ChangeFrom, $ChangeTo | Set-Content $fileName
#$NewContent | Out-File -FilePath $fileName -Encoding Default -Force
secedit /configure /db secedit.sdb /cfg $fileName | Out-Null
Remove-Item -Path $fileName

Write-Host "$credname service permissions added"
Read-Host "Press Enter to continue . . . "

$password = $credential.GetNetworkCredential().Password

Write-Host "Changing services to run properly"

If ($purposeEnvironment -eq 'Prod') {cmd /c 'sc config ActivElk obj="ASM\SIF.Service"' | Out-Null}
If ($purposeEnvironment -eq 'UAT')  {cmd /c 'sc config ActivElk obj="ASM\UAT.SIF.Service"' | Out-Null}
If ($purposeEnvironment -eq 'QA')   {cmd /c 'sc config ActivElk obj="ASM\QA.SIF.Service"' | Out-Null}
If ($purposeEnvironment -eq 'Dev')  {cmd /c 'sc config ActivElk obj="ASM\SIF.Service"' | Out-Null}

cmd /c 'sc config ActivElk start=auto' | Out-Null
cmd /c 'sc Stop   ActivElk' | Out-Null
cmd /c 'sc Start  ActivElk' | Out-Null

$params = @{
  "Namespace" = "root\CIMV2"
  "Class" = "Win32_Service"
  "Filter" = "DisplayName='StayinFront Application Server'"
}
$service = Get-WmiObject @params

$service.Change($null,
  $null,
  $null,
  $null,
  $null,
  $null,
  $null,
  $credential.GetNetworkCredential().Password,
  $null,
  $null,
  $null) | Out-Null

cmd /c 'sc config AeWorkflow start=disabled' | Out-Null
cmd /c 'sc Stop   AeWorkflow' | Out-Null

cmd /c 'sc config ActivElkComms start=disabled' | Out-Null
cmd /c 'sc Stop   ActivElkComms' | Out-Null

cmd /c 'sc config StayinFront.MulticastHub start=disabled' | Out-Null
cmd /c 'sc stop   StayinFront.MulticastHub' | Out-Null

cmd /c 'sc config ActivElkSynch start=disabled' | Out-Null
cmd /c 'sc stop   ActivElkSynch' | Out-Null

Write-Host "services settings complete"
Read-Host "Press Enter to continue . . . "

$file = Get-Item "C:\Program Files (x86)\StayinFront\CRM\StayinFront Manager.msc"
$file.IsReadOnly = $true

Write-Host "Adding ASM System"
cmd /c 'REGEDIT.EXE /S C:\Temp\StayinFront\Pre-reqs\ASM.reg'
Write-Host "ASM System Added"
Read-Host "Press Enter to continue . . . "

Write-Host "Writing Connection Strings for environment"

If ($purposeEnvironment -eq "Prod") {cmd /c 'REGEDIT.EXE /S C:\Temp\StayinFront\Pre-reqs\ConnectionStringsProd.reg'}
If ($purposeEnvironment -eq "UAT")  {cmd /c 'REGEDIT.EXE /S C:\Temp\StayinFront\Pre-reqs\ConnectionStringsUAT.reg' }
If ($purposeEnvironment -eq "QA")   {cmd /c 'REGEDIT.EXE /S C:\Temp\StayinFront\Pre-reqs\ConnectionStringsQA.reg'  }
If ($purposeEnvironment -eq "Dev")  {cmd /c 'REGEDIT.EXE /S C:\Temp\StayinFront\Pre-reqs\ConnectionStringsDev.reg' }

Write-Host "Connection Strings for environment Written"
Read-Host "Press Enter to continue . . . "

Write-Host "Restarting StayinFront Application Server Service"
cmd /c 'sc Stop   ActivElk' | Out-Null
cmd /c 'sc Start  ActivElk' | Out-Null

Write-Host "StayinFront Application Server Service Restarted"
Read-Host "Press Enter to continue . . . "

Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    Please Add:                                                                                                      *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    •    License                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    •    Transaction Logging Password                                                                                *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    •    Key Allocators                                                                                              *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*    •    ODBC Password                                                                                               *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
cmd /c '"C:\Program Files (x86)\StayinFront\CRM\StayinFront Manager.msc"'

Read-Host "Press Enter to continue . . . "

$RegKeyAdded = 0

While ($RegKeyAdded -ne 1)
{
    If ($RegKeyAdded -eq 2) {
        Stop-Process -Name "mmc" -ErrorAction SilentlyContinue
        cmd /c '"C:\Program Files (x86)\StayinFront\CRM\StayinFront Manager.msc"'

        Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*    You must add a license at this point                                                                             *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black

        Read-Host "Press Enter to continue . . . "
    }
    If (@(Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\Licenses").Count -gt 0) {$RegKeyAdded = 1}
    If ($RegKeyAdded -eq 0) {$RegKeyAdded = 2}

}

Write-Host "Confirmed License was added"

$RegKeyAdded = 0

While ($RegKeyAdded -ne 1)
{
    If ($RegKeyAdded -eq 2)
    {
        Stop-Process -Name "mmc" -ErrorAction SilentlyContinue
        cmd /c '"C:\Program Files (x86)\StayinFront\CRM\StayinFront Manager.msc"'

        Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*    You must add transaction logging password at this point                                                          *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host ""
        Read-Host "Press Enter to continue . . . "
    }

    If ((Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\Systems\ASM\Transaction logging")."sPWD") {$RegKeyAdded = 1}
    If ($RegKeyAdded -eq 0) {$RegKeyAdded = 2}
}

Write-Host "Transaction Logging Password Added"

$RegKeyAdded = 0
$looping = 0

While ($RegKeyAdded -ne 5)
{
    $RegKeyAdded = 0
    If ($looping -eq 1) {
        Stop-Process -Name "mmc" -ErrorAction SilentlyContinue
        cmd /c '"C:\Program Files (x86)\StayinFront\CRM\StayinFront Manager.msc"'

        Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*    You must add Key Allocators at this point                                                                        *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
        Read-Host "Press Enter to continue . . . "
        Write-Host ""
    }
    If (Test-Path "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\Systems\ASM\Key allocaters\GUID") {$RegKeyAdded += 1}
    If (Test-Path "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\Systems\ASM\Key allocaters\INT16") {$RegKeyAdded += 1}
    If (Test-Path "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\Systems\ASM\Key allocaters\INT32") {$RegKeyAdded += 1}
    If (Test-Path "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\Systems\ASM\Key allocaters\INT8") {$RegKeyAdded += 1}
    If (Test-Path "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\Systems\ASM\Key allocaters\SUID") {$RegKeyAdded += 1}

    If ($RegKeyAdded -ne 5) {$looping = 1}

}

Write-Host "Key Allocators Added"

$RegKeyAdded = 0

While ($RegKeyAdded -ne 1)
{
    If ($RegKeyAdded -eq 2) {
        Stop-Process -Name "mmc" -ErrorAction SilentlyContinue
        cmd /c '"C:\Program Files (x86)\StayinFront\CRM\StayinFront Manager.msc"'

        Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*    You must add ODBC Password at this point                                                                         *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "*                                                                                                                     *" -ForegroundColor Magenta -BackgroundColor Black
        Write-Host "***********************************************************************************************************************" -ForegroundColor Magenta -BackgroundColor Black
        Read-Host "Press Enter to continue . . . "
    }
    If ((Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\Systems\ASM\Data providers\ODBC")."sPWD") {$RegKeyAdded = 1}
    If ($RegKeyAdded -eq 0) {$RegKeyAdded = 2}

}

Stop-Process -Name "mmc" -ErrorAction SilentlyContinue

Write-Host "Password on ODBC Modified"

Write-Host "Registering ocx files"
Read-Host "Press Enter to continue . . . "
cmd /c 'Regsvr32 /s VE9Event.ocx'
cmd /c 'Regsvr32 /s VE9Gen.ocx'
cmd /c 'Regsvr32 /s MSCOMM32.ocx'

Write-Host "Ocx files Registered"

Write-Host "Restarting StayinFront Application Server Service"
Read-Host "Press Enter to continue . . . "
cmd /c 'sc Stop   ActivElk' | Out-Null
cmd /c 'sc Start  ActivElk' | Out-Null

Write-Host "StayinFront Application Server Service Restarted"

Write-Host "Deleting Registry Keys to ensure Citrix Works"
Read-Host "Press Enter to continue . . . "

cmd /c 'reg delete HKCR\Wow6432Node\AppID\{C8D13ACF-4DA7-11D2-9C74-00104BC85282} /v AccessPermission /f' 2>&1 | Out-Null
cmd /c 'reg delete HKCR\Wow6432Node\AppID\{C8D13ACF-4DA7-11D2-9C74-00104BC85282} /v LaunchPermission /f' 2>&1 | Out-Null

Write-Host "Registry Keys Deleted"
Write-Host "Install of Application Server Completed"
Read-Host "Press Enter to continue . . . "

If ($purpose -eq 'W') 
{
    Write-Host "This is a web server so we now move on to web installation"
    Write-Host "Copying Web Files"
    robocopy "C:\Temp\StayinFront\StayinFrontTouch" "C:\inetpub\StayinFrontTouch" /E /log+:C:\Temp\WebFileCopy.txt
    robocopy "C:\Temp\StayinFront\Touch" "C:\inetpub\Touch" /E /log+:C:\Temp\WebFileCopy.txt
    robocopy "C:\Temp\StayinFront\Pre-reqs\STEW" "C:\inetpub\wwwroot\STEW" /E /log+:C:\Temp\StewFileCopy.txt
    Write-Host "Web Files Copied"
    
    $ReadFileName = "C:\Temp\StayinFront\Pre-reqs\ImagesFolder" + $purposeEnvironment + ".txt"
    $FileEnvironment = Get-Content ($ReadFileName)
    Write-Host "Modifiying web.config file to have correct images folder for this environment"
    Read-Host "Press Enter to continue . . . "

    $FilePath = "C:\inetpub\StayinFrontTouch\ASMTouch\TouchASM\web.config"
    $bLineToChange = 0
    $FileOriginal = Get-Content ($FilePath)
    [String[]] $FileModified = @()
    Foreach ($line in $FileOriginal)
        {
            If ($bLineToChange -eq 1)
            {
                $FileModified +=  "        <value>" + $FileEnvironment + "</value>`n"
                $bLineToChange = 0
            }
            Else
            {
                If ($line -like "*<setting name=`"UploadedFilesPath`" serializeAs=`"String`">*")
                {
                    $bLineToChange = 1
                    $FileModified += "$line`n"
                }
                Else
                {
                    $FileModified += "$line`n"
                }
            }
        }  

    Set-Content $Filepath $FileModified
    
    $FilePath = "C:\inetpub\Touch\TouchASM\web.config"
    $bLineToChange = 0
    $FileOriginal = Get-Content ($FilePath)
    [String[]] $FileModified = @()
    Foreach ($line in $FileOriginal)
        {
            If ($bLineToChange -eq 1)
            {
                $FileModified +=  "        <value>" + $FileEnvironment + "</value>`n"
                $bLineToChange = 0
            }
            Else
            {
                If ($line -like "*<setting name=`"UploadedFilesPath`" serializeAs=`"String`">*")
                {
                    $bLineToChange = 1
                    $FileModified += "$line`n"
                }
                Else
                {
                    $FileModified += "$line`n"
                }
            }
        }  

    Set-Content $Filepath $FileModified
    
    Write-Host "Web.config file has correct images folder for this environment Modified"

    Import-Module WebAdministration

    Write-Host "Set Default App Pool Settings"
    Read-Host "Press Enter to continue . . . "
    Set-ItemProperty -Path IIS:\AppPools\DefaultAppPool -Name managedRuntimeVersion -Value 'v2.0'
    Set-ItemProperty -Path IIS:\AppPools\DefaultAppPool -Name enable32BitAppOnWin64 -Value 'False'
    Write-Host "Default App Pool Settings Set"

    Write-Host "Set Default Web Site Settings"
    Read-Host "Press Enter to continue . . . "
    Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/anonymousAuthentication -Name UserName -Value $credname -Location "Default Web Site"
    Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/anonymousAuthentication -Name Password -Value $password -Location "Default Web Site"
    Write-Host "Default Web Site Settings Set"

    Write-Host "Adding ISAPI filter"
    Read-Host "Press Enter to continue . . . "
 
    Write-Host "ISAPI filter Added"

    Write-Host "Setting up Handler Mappings"
    Read-Host "Press Enter to continue . . . "
    Set-WebConfiguration "/system.webServer/handlers/add[@name='ISAPI-dll']/@requireAccess" -Value "Execute"
    Set-WebConfiguration "/system.webServer/handlers/@AccessPolicy" -Value "Read, Script, Execute"

    Write-Host "Handler Mappings Setup"

    Write-Host "Setting Up Application Pools"
    Read-Host "Press Enter to continue . . . "

    #Default App Pool Settings
    Set-ItemProperty -Path IIS:\AppPools\DefaultAppPool -Name enable32BitAppOnWin64 -Value 'True'

    #ASMTouch App Pool Settings
    New-Item -Path IIS:\AppPools\ASMTouch_AppPool -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name managedRuntimeVersion -Value 'v2.0'
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name enable32BitAppOnWin64 -Value 'True'
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name managedPipelineMode -Value 'Classic'
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name queueLength -Value 4000
    
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name processModel.userName -Value $credname
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name processModel.password -Value $password
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name processModel.identityType -Value 3
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name processmodel.ShutdownTimeLimit -Value 600

    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name Failure.RapidFailProtection -Value 'False'

    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name Recycling.PeriodicRestart.time -Value '00:00:00'
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"}
    Set-ItemProperty -Path IIS:\AppPools\ASMTouch_AppPool -Name Recycling.PeriodicRestart.privateMemory -Value 1200000

    #ASMTouchCG App Pool Settings
    New-Item -Path IIS:\AppPools\ASMTouchCG_AppPool -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name managedRuntimeVersion -Value 'v4.0'
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name managedPipelineMode -Value 'Integrated'
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name enable32BitAppOnWin64 -Value 'False'
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name queueLength -Value 4000

    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processModel.userName -Value $credname
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processModel.password -Value $password
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processModel.identityType -Value 3
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processModel.idleTimeout -value ([TimeSpan]::FromMinutes(0))
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processmodel.ShutdownTimeLimit -Value 600
    
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name Failure.RapidFailProtection -Value 'False'

    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name Recycling.PeriodicRestart.time -Value '00:00:00'
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"}
    Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name Recycling.PeriodicRestart.privateMemory -Value 3200000

    #StayinFrontTouch App Pool Settings
    New-Item -Path IIS:\AppPools\StayinFrontTouch_AppPool -Force -ErrorAction SilentlyContinue
        #(General) Section
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name managedRuntimeVersion -Value 'v2.0'
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name enable32BitAppOnWin64 -Value 'True'
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name managedPipelineMode -Value 'Classic'
        #Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name queueLength -Value 1000
        
        #CPU Section

        #Process Model Section
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name processModel.userName -Value $credname
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name processModel.password -Value $password
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name processModel.identityType -Value 3
        #Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name processModel.idleTimeout -value ([TimeSpan]::FromMinutes(0))
        #Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name processmodel.ShutdownTimeLimit -Value 600
    

        #Process Orphaning Section

        #Rapid-Fail Protection Section
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name Failure.RapidFailProtection -Value 'False'

        #Recycling Section
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name Recycling.PeriodicRestart.time -Value '00:00:00'
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"}
        Set-ItemProperty -Path IIS:\AppPools\StayinFrontTouch_AppPool -Name Recycling.PeriodicRestart.privateMemory -Value 1500000

    #Presentation App Pool Settings
    New-Item -Path IIS:\AppPools\Presentation_AppPool -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path IIS:\AppPools\Presentation_AppPool -Name managedRuntimeVersion -Value 'v2.0'
    Set-ItemProperty -Path IIS:\AppPools\Presentation_AppPool -Name managedPipelineMode -Value 'Classic'

    Set-ItemProperty -Path IIS:\AppPools\Presentation_AppPool -Name enable32BitAppOnWin64 -Value 'True'
    Set-ItemProperty -Path IIS:\AppPools\Presentation_AppPool -Name processModel.userName -Value $credname
    Set-ItemProperty -Path IIS:\AppPools\Presentation_AppPool -Name processModel.password -Value $password
    Set-ItemProperty -Path IIS:\AppPools\Presentation_AppPool -Name processModel.identityType -Value 3

    Set-ItemProperty -Path IIS:\AppPools\Presentation_AppPool -Name Recycling.PeriodicRestart.time -Value '00:00:00'
    Set-ItemProperty -Path IIS:\AppPools\Presentation_AppPool -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"}

    #WinShell App Pool Settings
    New-Item -Path IIS:\AppPools\WinShell_AppPool -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name managedRuntimeVersion -Value 'v2.0'
    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name managedPipelineMode -Value 'Classic'

    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name enable32BitAppOnWin64 -Value 'True'
    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name processModel.userName -Value $credname
    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name processModel.password -Value $password
    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name processModel.identityType -Value 3

    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name Recycling.PeriodicRestart.time -Value '00:00:00'
    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"}
    Set-ItemProperty -Path IIS:\AppPools\WinShell_AppPool -Name Recycling.PeriodicRestart.privateMemory -Value 1200000

    #STEW App Pool Settings
    New-Item -Path IIS:\AppPools\STEW -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path IIS:\AppPools\STEW -Name managedRuntimeVersion -Value 'v4.0'
    Set-ItemProperty -Path IIS:\AppPools\STEW -Name managedPipelineMode -Value 'Integrated'

    Set-ItemProperty -Path IIS:\AppPools\STEW -Name processModel.userName -Value $credname
    Set-ItemProperty -Path IIS:\AppPools\STEW -Name processModel.password -Value $password
    Set-ItemProperty -Path IIS:\AppPools\STEW -Name processModel.identityType -Value 3

    Set-ItemProperty -Path IIS:\AppPools\STEW -Name Recycling.PeriodicRestart.time -Value '00:00:00'
    Set-ItemProperty -Path IIS:\AppPools\STEW -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"}

    Set-ItemProperty -Path IIS:\AppPools\STEW -Name enable32BitAppOnWin64 -Value 'True'
    
    Write-Host "Application Pools SetUp"

    Write-Host "Adding needed registry keys for eBusiness"
    Read-Host "Press Enter to continue . . . "
    cmd /c 'REGEDIT.EXE /S C:\Temp\StayinFront\Pre-reqs\Web.reg' | Out-Null
    Write-Host "Needed registry keys for eBusiness Added"

    Write-Host "Adding Web sites/applications"
    Read-Host "Press Enter to continue . . . "
    
    #Add ASMTouch Application
    If (!(Test-Path 'IIS:\Sites\Default Web Site\ASMTouch'))
    {
        New-Item 'IIS:\Sites\Default Web Site\ASMTouch' -physicalPath C:\inetpub\StayinFrontTouch\ASMTouch\TouchASM -type Application -applicationPool ASMTouch_AppPool
    }

    #Add ASMTouchCG Application
    If (!(Test-Path 'IIS:\Sites\Default Web Site\ASMTouchCG'))
    {
        New-Item 'IIS:\Sites\Default Web Site\ASMTouchCG' -physicalPath C:\inetpub\Touch\TouchASM -type Application -applicationPool ASMTouchCG_AppPool
    }
    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Location 'Default Web Site/ASMTouchCG' -Filter "system.webServer/asp" -Name "enableParentPaths" -Value "True"
    Set-WebConfiguration "/system.webServer/handlers/add[@name='ISAPI-dll']/@requireAccess" -Value "Execute" -PSPath "IIS:/sites/Default Web Site/ASMTouchCG"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'Default Web Site/ASMTouchCG' -filter "system.webServer/security/authentication/basicAuthentication" -name "enabled" -value "False"

    #Add ASMTouchLogin Application
    If (!(Test-Path 'IIS:\Sites\Default Web Site\ASMTouchLogin'))
    {
        New-Item 'IIS:\Sites\Default Web Site\ASMTouchLogin' -physicalPath C:\inetpub\StayinFrontTouch\ASMTouch\Login -type Application -applicationPool StayinFrontTouch_AppPool
    }
        Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Location 'Default Web Site/ASMTouchLogin' -Filter "system.webServer/asp" -Name "enableParentPaths" -Value "True"
    Set-WebConfiguration "/system.webServer/handlers/add[@name='ISAPI-dll']/@requireAccess" -Value "Execute" -PSPath "IIS:/sites/Default Web Site/ASMTouchLogin"
    
    #Add Presentation Application
    $ReadFileName = "C:\Temp\StayinFront\Pre-reqs\PresentationsFolder" + $purposeEnvironment + ".txt"
    $FileEnvironment = Get-Content ($ReadFileName)
    If (!(Test-Path 'IIS:\Sites\Default Web Site\Presentations'))
    {
        New-Item 'IIS:\Sites\Default Web Site\Presentations' -physicalPath $FileEnvironment -type Application -applicationPool Presentation_AppPool -Force
    }

    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Location 'Default Web Site/Presentations' -Filter "system.webServer/asp" -Name "enableParentPaths" -Value "True"
    Set-WebConfiguration "/system.webServer/handlers/add[@name='ISAPI-dll']/@requireAccess" -Value "Execute" -PSPath "IIS:/sites/Default Web Site/Presentations"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'Default Web Site/Presentations' -filter "system.webServer/security/authentication/basicAuthentication" -name "enabled" -value "False"

    #Add ASMWinShell Application
    $ReadFileName = "C:\Temp\StayinFront\Pre-reqs\ASMWinShellFolder" + $purposeEnvironment + ".txt"
    $FileEnvironment = Get-Content ($ReadFileName)
    If (!(Test-Path 'IIS:\Sites\Default Web Site\ASMWinShell'))
    {
        New-Item 'IIS:\Sites\Default Web Site\ASMWinShell' -physicalPath $FileEnvironment -type Application -applicationPool WinShell_AppPool -Force
    }

    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Location 'Default Web Site/ASMWinShell' -Filter "system.webServer/asp" -Name "enableParentPaths" -Value "True"
    Set-WebConfiguration "/system.webServer/handlers/add[@name='ISAPI-dll']/@requireAccess" -Value "Execute" -PSPath "IIS:/sites/Default Web Site/ASMWinShell"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'Default Web Site/ASMWinShell' -filter "system.webServer/security/authentication/basicAuthentication" -name "enabled" -value "True"

    #Add Install Application
    If (!(Test-Path 'IIS:\Sites\Default Web Site\Install'))
    {
        New-Item 'IIS:\Sites\Default Web Site\Install' -physicalPath C:\inetpub\StayinFrontTouch\ASMTouch\Install -type Application -applicationPool StayinFrontTouch_AppPool
    }

    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Location 'Default Web Site/Install' -Filter "system.webServer/asp" -Name "enableParentPaths" -Value "True"
    Set-WebConfiguration "/system.webServer/handlers/add[@name='ISAPI-dll']/@requireAccess" -Value "Execute" -PSPath "IIS:/sites/Default Web Site/Install"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'Default Web Site/Install' -filter "system.webServer/security/authentication/basicAuthentication" -name "enabled" -value "True"

    ConvertTo-WebApplication -PSPath "IIS:\Sites\Default Web Site\STEW" -ApplicationPool "STEW" -ErrorAction SilentlyContinue

    #Add STEW Application
    If (!(Test-Path 'IIS:\Sites\Default Web Site\STEW'))
    {
        New-Item 'IIS:\Sites\Default Web Site\STEW' -physicalPath C:\inetpub\wwwroot\STEW -type Application -applicationPool STEW
    }

    Set-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST" -Location 'Default Web Site/STEW' -Filter "system.webServer/asp" -Name "enableParentPaths" -Value "True"
    Set-WebConfiguration "/system.webServer/handlers/add[@name='ISAPI-dll']/@requireAccess" -Value "Execute" -PSPath "IIS:/sites/Default Web Site/STEW"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'Default Web Site/STEW' -filter "system.webServer/security/authentication/basicAuthentication" -name "enabled" -value "True"
    
    If (!(Get-WebVirtualDirectory -Name "ArtsApps"))
    {
        New-WebVirtualDirectory -Name "ArtsApps" -PhysicalPath "\\asm.lan\dcshare\App\SIF\Prod\Data\ARTS\website_ARTSAPPS" -Site "Default Web Site"
    }

    Write-Host "Web sites/applications Added"

    Write-Host "Add SRVC Password to ASMTouchCG\services domain in IIS" -ForegroundColor Magenta -BackgroundColor Black

    cmd /c '"C:\Windows\system32\inetsrv\InetMgr.exe"'
    Stop-Process -Name "InetMgr" -ErrorAction SilentlyContinue

    cmd /c '"C:\Windows\system32\inetsrv\InetMgr.exe"'

    Read-Host "Press Enter to continue . . . "

    $RegKeyAdded = 0

    While ($RegKeyAdded -ne 1)
    {
        If ($RegKeyAdded -eq 2)
        {
            Write-Host "You must add SRVC password at this point"
            Read-Host "Press Enter to continue . . . "
        }

        If ((Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\StayinFront\Active Elk\WebWorks\Domains\ASMTouchCG\Services")."Password") {$RegKeyAdded = 1}
        If ($RegKeyAdded -eq 0) {$RegKeyAdded = 2}
    }

    Write-Host "SRVC Password Added"

    cmd /c 'copy C:\Temp\StayinFront\Pre-reqs\iisstart.htm C:\inetpub\wwwroot\iisstart.htm' | Out-Null
    
    $FilePath = 'C:\inetpub\wwwroot\iisstart.htm'
    $FileOriginal = Get-Content ($FilePath)
    [String[]] $FileModified = @()
    Foreach ($line in $FileOriginal)
        {
            If ($line -like "*<SERVERNAME>*")
            {
                $FileModified += "$env:COMPUTERNAME"
            }
            Else
            {
                $FileModified += "$line`n"
            }
        }

    Set-Content $Filepath $FileModified
    
    Write-Host "iisstart.htm file has been modified for this environment and servername"

    Write-Host "Install of Web Server Completed"
    Read-Host "Press Enter to continue . . . "

}
