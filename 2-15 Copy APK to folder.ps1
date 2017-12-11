$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'WEBServers.txt'
$Computers       = Get-Content $LoadServerFile

foreach ($computer in $Computers)
{
    Copy-Item -Path \\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease\APK\Prod\* -Destination \\$computer\C$\inetpub\StayinFrontTouch\ASMTouch\Install\ -Force
}
