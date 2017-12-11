$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

foreach ($computer in $Computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { $app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "StayinFront CRM language pack"} }
    Invoke-Command -Session $NewPSSession -ScriptBlock { $app.Uninstall() }
    Remove-PSSession -Session $NewPSSession
}
