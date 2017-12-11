$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

$ReleasePath = "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease"

ForEach ($computer in $computers)
{
    New-Item "\\$computer\C$\Temp\StayinFrontLanguageInstall" -ItemType Directory
    Copy-Item -Container "$ReleasePath\CRM_InstallFromHere-x64 12.2.2.168\StayinFrontCRM-Languages 13.0.0.1310.msi" -Destination "\\$computer\C$\Temp\StayinFrontLanguageInstall\" -Recurse
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { cmd /c 'msiexec.exe /qn /i "C:\Temp\StayinFrontLanguageInstall\StayinFrontCRM-Languages 13.0.0.1310.msi" /l*vx C:\Temp\StayinFrontLanguages.txt' }
    Remove-PSSession -Session $NewPSSession
}
