#Action
$STActionExecute = "msiexec.exe"
$STActionArgument = "/qn /i C:\Temp\StayinFrontLanguageInstall\StayinFrontCRM-Languages.msi /l*vx C:\Temp\StayinFrontLanguages.txt"
$STAction  = New-ScheduledTaskAction -Execute $STActionExecute -Argument $STActionArgument

#Trigger
$TimeToStart = (Get-Date).AddSeconds(15)
$STTrigger = $trigger =  New-ScheduledTaskTrigger -Once -At $TimeToStart

#Task
$TaskName = "Install StayinFront CRM Languages"
$TaskUser = "NT AUTHORITY\SYSTEM"
Register-ScheduledTask -Action $STAction -Trigger $STTrigger -TaskName $TaskName -Description $TaskName -User $TaskUser -RunLevel Highest -Force
