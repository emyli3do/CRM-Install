#Load the folder that has our script variables
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'

#Load our files that have our script variables
$LoadAppFile  = $LoadFolder + 'APPServers.txt'
$LoadWebFile  = $LoadFolder + 'WEBServers.txt'

#Place our files into variables for use later
$AppComputers    = Get-Content $LoadAppFile
$WebComputers    = Get-Content $LoadWebFile

foreach ($computer in $AppComputers)
{
    Set-Service -ComputerName $computer -Name ActivElk -StartupType Automatic
}

foreach ($computer in $AppComputers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession {Start-Service -Name ActivElk -WarningAction SilentlyContinue}
    Remove-PSSession -Session $NewPSSession
}

foreach ($computer in $WebComputers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock {Import-Module WebAdministration}
    Invoke-Command -Session $NewPSSession -ScriptBlock {Start-WebAppPool -Name "ASMTouch_AppPool"}
    Invoke-Command -Session $NewPSSession -ScriptBlock {Start-WebAppPool -Name "StayinFrontTouch_AppPool"}
    Remove-PSSession -Session $NewPSSession
}

