ForEach ($computer in $computers)
{
    If ($computer -ne $env:COMPUTERNAME)
    {
        Restart-Computer -ComputerName $computer -Force
    }
}
