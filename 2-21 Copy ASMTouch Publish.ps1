$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'WebServers.txt'
$Computers       = Get-Content $LoadServerFile

ForEach ($computer in $computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { Copy-Item -Path 'C:\inetpub\StayinFrontTouch\ASMTouch\TouchASM\ASMTouch.publish.xml' -Destination C:\inetpub\Touch\TouchASM\ASMTouchCG.publish.xml -ErrorAction SilentlyContinue }
}
