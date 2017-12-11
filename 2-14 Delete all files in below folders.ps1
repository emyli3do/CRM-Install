$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

foreach ($computer in $Computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { Remove-Item -Path C:\ProgramData\StayinFront\ServerModels\* }
    Invoke-Command -Session $NewPSSession -ScriptBlock { Remove-Item -Path C:\ProgramData\StayinFront\ClientModels\32\* }
    Invoke-Command -Session $NewPSSession -ScriptBlock { Remove-Item -Path C:\ProgramData\StayinFront\ClientModels\64\* }
    Remove-PSSession -Session $NewPSSession
}
