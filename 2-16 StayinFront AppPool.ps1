$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'WEBServers.txt'
$Computers       = Get-Content $LoadServerFile

Import-Module WebAdministration

foreach ($computer in $Computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name managedRuntimeVersion -Value 'v2.0' }
    Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name Failure.RapidFailProtection -Value 'False' }
    Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name Recycling.PeriodicRestart.time -Value '00:00:00' }
    Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"} }
    Invoke-Command -Session $NewPSSession -ScriptBlock { Set-ItemProperty -Path IIS:\AppPools\StayinFront -Name Recycling.PeriodicRestart.privateMemory -Value 1200000 }
    Remove-PSSession -Session $NewPSSession
}
