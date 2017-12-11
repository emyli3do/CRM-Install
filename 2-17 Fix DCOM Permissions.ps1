$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

ForEach ($computer in $computers)
{
    New-Item "\\$computer\C$\Temp\FixDCOMpermissions" -ItemType Directory
    Copy-Item -Container "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease\DCOM Bat\Fix DCOM permissions.bat" -Destination "\\$computer\C$\Temp\FixDCOMpermissions\" -Recurse
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { cmd /c 'C:\Temp\FixDCOMpermissions\Fix DCOM permissions.bat' }
    Remove-PSSession -Session $NewPSSession
}
