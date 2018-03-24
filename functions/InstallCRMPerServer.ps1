#Action
$STActionExecute = "msiexec.exe"
$STActionArgument = "/qn /i C:\Temp\StayinFrontInstall\StayinFrontCRM-x64.msi INSTALL_SERVER=1 INSTALL_CLIENT=1 "
$STActionArgument += "INSTALL_APPSERVER=1 INSTALL_WORKFLOW=1 INSTALL_SYNCH=1 INSTALL_SYNCHSERVER=1 INSTALL_COMMSSERVER=1 "
$STActionArgument += "INSTALL_SYNCHHTTP=1 INSTALL_WEB=1 INSTALL_TOUCH=1 INSTALL_WTS=1 /l*vx C:\Temp\StayinFrontCRM-x64InstallLog.txt"
$STAction  = New-ScheduledTaskAction -Execute $STActionExecute -Argument $STActionArgument

#Trigger
$TimeToStart = (Get-Date).AddSeconds(15)
$STTrigger = $trigger =  New-ScheduledTaskTrigger -Once -At $TimeToStart

#Task
$TaskName = "Install StayinFront CRM"
$TaskUser = "NT AUTHORITY\SYSTEM"
Register-ScheduledTask -Action $STAction -Trigger $STTrigger -TaskName $TaskName -Description $TaskName -User $TaskUser -RunLevel Highest -Force
