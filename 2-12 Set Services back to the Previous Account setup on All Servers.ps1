$bDebug = 0

$credential = Get-Credential -Message "Please enter in the password for ASM\SIF.Service as it will be used to setup services and Web AppPools" -UserName "ASM\SIF.Service"

$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'

$ServiceStatuses = Import-Csv '\\NVSFTCTRLP01\C$\Temp\Service.csv'

$Computers = Get-Content $LoadServerFile

$services = @("AeWorkflow","Watchdog","ActivElkSynch","StayinFront.MulticastHub","ActivElkComms","ActivElk")

ForEach ($computer in $computers)
{
    ForEach ($service in $services)
    {
        ForEach ($ServiceStatus in $ServiceStatuses)
        {
            If ($ServiceStatus.PSComputerName -eq $computer)
            {
                If ($ServiceStatus.name -eq $service)
                {
                    If ($ServiceStatus.startname -ne 'LocalSystem')
                    {
                        $params = @{
                          "Namespace" = "root\CIMV2"
                          "Class" = "Win32_Service"
                          "Filter" = "ServiceName='$service'"
                        }
                    
                        $WMIservice = Get-WmiObject @params -ComputerName $computer

                        $WMIservice.Change($null,
                          $null,
                          $null,
                          $null,
                          $null,
                          $null,
                          'ASM\SIF.Service',
                          $credential.GetNetworkCredential().Password,
                          $null,
                          $null,
                          $null) | Out-Null
                    }

                    If ($ServiceStatus.startmode -eq "Auto")
                    {
                        Set-Service -Name $service -ComputerName $computer -StartupType Automatic
                    }
                    Else
                    {
                        Set-Service -Name $service -ComputerName $computer -StartupType Disabled
                    }
                }
            }
        }   
    }
}
