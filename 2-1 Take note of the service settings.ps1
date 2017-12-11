$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

$services = @("AeWorkflow","Watchdog","ActivElkSynch","StayinFront.MulticastHub","ActivElkComms","ActivElk")
$ServiceStatuses = @()

ForEach ($computer in $computers)
{
    ForEach ($service in $services)
    {
        $objService = Get-WmiObject -Class WIN32_Service -ComputerName $computer -Filter "Name = '$service'"
        $ServiceStatuses += $objService | select PSComputerName, name, startname, startmode
    }
    
}

$ServiceStatuses | select PSComputerName, name, startname, startmode | Export-Csv \\NVSFTCTRLP01\C$\Temp\Service.csv -notype
$ServiceStatuses | Format-Table
