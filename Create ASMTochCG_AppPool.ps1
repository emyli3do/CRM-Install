$credential = Get-Credential -Message "Please enter in the password for ASM\SIF.Service as it will be used to setup services and Web AppPools" -UserName "ASM\SIF.Service"

Import-Module WebAdministration

#ASMTouchCG App Pool Settings    
New-Item -Path IIS:\AppPools\ASMTouchCG_AppPool
Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name managedRuntimeVersion -Value 'v4.0'
Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name managedPipelineMode -Value 'Integrated'

Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name enable32BitAppOnWin64 -Value 'False'
Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name queueLength -Value 4000

Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processModel.userName -Value 'SIF.Service@asm.lan'
Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processModel.password -Value $password
Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processModel.identityType -Value 3

Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processModel.idleTimeout -value ([TimeSpan]::FromMinutes(0))

Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name processmodel.ShutdownTimeLimit -Value 600
Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name Failure.RapidFailProtection -Value 'False'

Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name Recycling.PeriodicRestart.time -Value '00:00:00'
Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name Recycling.PeriodicRestart.schedule -Value @{value="3:30"}
Set-ItemProperty -Path IIS:\AppPools\ASMTouchCG_AppPool -Name Recycling.PeriodicRestart.privateMemory -Value 3200000


