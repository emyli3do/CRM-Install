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
