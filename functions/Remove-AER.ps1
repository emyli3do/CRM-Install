ForEach ($computer in $computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock { Get-ChildItem -Path 'C:\Program Files (x86)\StayinFront\CRM\' -Filter "*.aer" | Remove-Item }
    Remove-PSSession -Session $NewPSSession
}
