$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

foreach ($computer in $Computers)
{
    $ReleasePath = "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease"
    $PushPath = "\\$computer\C$\Program Files(x86)\StayinFront\CRM\Systems\ASM"

    Copy-Item -Path "$ReleasePath\Model\" -Destination $PushPath\ -Recurse -Force
}
