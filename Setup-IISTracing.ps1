
#Load the folder that has our script variables
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'

#Load our files that have our script variables
$LoadWebFile  = $LoadFolder + 'WEBServers.txt'
$WebComputers    = Get-Content $LoadWebFile

ForEach ($WebComputer in $WebComputers)
{
    $NewPSSession = New-PSSession -ComputerName $WebComputer
    Invoke-Command -Session $NewPSSession -ScriptBlock {Install-WindowsFeature Web-Http-Tracing}
    Invoke-Command -Session $NewPSSession -ScriptBlock {cmd /c "C:\Windows\system32\inetsrv\appcmd.exe set site ""Default Web Site"" -traceFailedRequestsLogging.enabled:""true"" /commit:apphost"}
    Invoke-Command -Session $NewPSSession -ScriptBlock {cmd /c "C:\Windows\system32\inetsrv\appcmd.exe set config ""Default Web Site"" -section:system.webServer/tracing/traceFailedRequests /-""[path='*']""" | Out-NULL}
    Invoke-Command -Session $NewPSSession -ScriptBlock {cmd /c "C:\Windows\system32\inetsrv\appcmd.exe set config ""Default Web Site"" -section:system.webServer/tracing/traceFailedRequests /+""[path='*']"""}
    Invoke-Command -Session $NewPSSession -ScriptBlock {cmd /c "C:\Windows\system32\inetsrv\appcmd.exe set config ""Default Web Site"" -section:system.webServer/tracing/traceFailedRequests /+""[path='*'].traceAreas.[provider='ASP',verbosity='Verbose']"""}
    Invoke-Command -Session $NewPSSession -ScriptBlock {cmd /c "C:\Windows\system32\inetsrv\appcmd.exe set config ""Default Web Site"" -section:system.webServer/tracing/traceFailedRequests /+""[path='*'].traceAreas.[provider='ASPNET',areas='Infrastructure,Module,Page,AppServices',verbosity='Verbose']"""}
    Invoke-Command -Session $NewPSSession -ScriptBlock {cmd /c "C:\Windows\system32\inetsrv\appcmd.exe set config ""Default Web Site"" -section:system.webServer/tracing/traceFailedRequests /+""[path='*'].traceAreas.[provider='ISAPI Extension',verbosity='Verbose']"""}
    Invoke-Command -Session $NewPSSession -ScriptBlock {cmd /c "C:\Windows\system32\inetsrv\appcmd.exe set config ""Default Web Site"" -section:system.webServer/tracing/traceFailedRequests /+""[path='*'].traceAreas.[provider='WWW Server',areas='Authentication,Security,Filter,StaticFile,CGI,Compression,Cache,RequestNotifications,Module,FastCGI,WebSocket',verbosity='Verbose']"""}
    Invoke-Command -Session $NewPSSession -ScriptBlock {cmd /c "C:\Windows\system32\inetsrv\appcmd.exe set config ""Default Web Site"" -section:system.webServer/tracing/traceFailedRequests /[path='*'].failureDefinitions.statusCodes:""401.4"""}
    Remove-PSSession -Session $NewPSSession
    Start-Sleep -Seconds 10 
}
