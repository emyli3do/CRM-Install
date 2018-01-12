ForEach ($computer in $ComputerName)
    {
        $NewPSSession = New-PSSession -ComputerName $computer
        Invoke-Command -Session $NewPSSession -ScriptBlock { 
            Import-Module WebAdministration
            $apppools = Get-ChildItem –Path IIS:\AppPools
            foreach ($apppool in $apppools)
            {
                $apppoolname = $apppool.Name
                $currentreset = (Get-ItemProperty -Path "IIS:\AppPools\$apppoolname" -Name Recycling.PeriodicRestart.schedule.Collection).value 
                If ($_ -eq "3:30:00")
                {
                    Set-ItemProperty -Path IIS:\AppPools\$apppoolname -Name Recycling.PeriodicRestart.schedule -Value @{value="1:45"}
                }
            }

        }
	    Remove-PSSession -Session $NewPSSession
    }

