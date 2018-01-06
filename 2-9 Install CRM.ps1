﻿$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

$ReleasePath = "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease"

ForEach ($computer in $computers)
{
    New-Item "\\$computer\C$\Temp\StayinFrontInstall" -ItemType Directory
    Copy-Item -Container "$ReleasePath\CRM_InstallFromHere-x64 12.2.2.168\StayinFrontCRM-x64.msi" -Destination "\\$computer\C$\Temp\StayinFrontInstall\" -Recurse
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { cmd /c 'msiexec.exe /qn /i "C:\Temp\StayinFrontInstall\StayinFrontCRM-x64.msi" INSTALL_SERVER=1 INSTALL_CLIENT=1 INSTALL_APPSERVER=1 INSTALL_WORKFLOW=1 INSTALL_SYNCH=1 INSTALL_SYNCHSERVER=1 INSTALL_COMMSSERVER=1 INSTALL_SYNCHHTTP=1 INSTALL_WEB=1 INSTALL_TOUCH=1 INSTALL_WTS=1 /l*vx C:\Temp\StayinFrontCRM-x64InstallLog.txt' }
    Remove-PSSession -Session $NewPSSession
}