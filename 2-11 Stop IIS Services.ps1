$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

ForEach ($computer in $computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { If ((Get-Service -Name W3SVC).Status -eq "Started") { cmd /c 'SC.EXE STOP W3SVC' } }
    Remove-PSSession -Session $NewPSSessionZ
}
