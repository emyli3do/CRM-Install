$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

ForEach ($computer in $computers)
{
    Write-Host $computer
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { cmd /c "reg export HKLM\SOFTWARE\Wow6432Node\StayinFront C:\Temp\StayinFront.reg"
#    Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\StayinFront" -recurse
#    } | Export-CliXML \\NVSFTCTRLP01\C$\Temp\Registry\$computer.reg
    }
    Remove-PSSession -Session $NewPSSession
    Copy-Item -Path \\$computer\C$\Temp\StayinFront.reg -Destination C:\Temp\Registry\$computer.reg
}

