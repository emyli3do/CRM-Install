$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

foreach ($computer in $Computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock {$ServiceNames = "AeWkfSvr","StayinFront.Watchdog.Monitor","AeSynch","StayinFront.MulticastHub","aeCommsE","AeServer","mmc","StayinFront.ServerMonitor","StayinFrontCRM"}
    Invoke-Command -Session $NewPSSession -ScriptBlock {foreach ($ServiceName in $ServiceNames) {Stop-Process -Name $ServiceName -Force -ErrorAction SilentlyContinue}}
    Remove-PSSession -Session $NewPSSession
}
