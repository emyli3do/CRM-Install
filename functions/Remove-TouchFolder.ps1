
ForEach ($computer in $computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { Remove-Item –Path "C:\Program Files (x86)\StayinFront\Touch" -Recurse -ErrorAction SilentlyContinue }
    Remove-PSSession -Session $NewPSSession
}
