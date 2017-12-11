$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

ForEach ($computer in $computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { Get-ChildItem -Path 'C:\Program Files (x86)\StayinFront\CRM\' -Filter "*.aer" | Remove-Item }
    Remove-PSSession -Session $NewPSSession
}
