$keepgoing = 0

While ($keepgoing -ne 1)
{
    If ($keepgoing -eq 2) {Write-Host "The only acceptable answers to the question are A, W or C. Please make one of these selections"}
    $keepgoing = 2
    $purpose = Read-Host "Are you installing this as an App Server (A) or an App/Web Server (W) or would you like to cancel out of the process completely (C) (A or W or C)?"
    If ($purpose -eq 'A') {$keepgoing = 1}
    If ($purpose -eq 'W') {$keepgoing = 1}
    If ($purpose -eq 'C') {$keepgoing = 1}
}

If ($purpose -eq 'C') {Exit}
If ($purpose -eq 'A') {Write-Host "You are installing an Application Server"}
If ($purpose -eq 'W') {Write-Host "You are installing an Application and Web Server"}

Read-Host "Press Enter to continue . . . "

If ($purpose -eq 'W') 
{
    Write-Host "Installing IIS"
    Install-WindowsFeature Web-Server -WarningAction SilentlyContinue
    Install-WindowsFeature Web-Net-Ext -WarningAction SilentlyContinue
    Install-WindowsFeature Web-Net-Ext45 -WarningAction SilentlyContinue
    Install-WindowsFeature Web-AppInit -WarningAction SilentlyContinue
    Install-WindowsFeature Web-ASP -WarningAction SilentlyContinue
    Install-WindowsFeature Web-Asp-Net -WarningAction SilentlyContinue
    Install-WindowsFeature Web-Asp-Net45 -WarningAction SilentlyContinue
    Install-WindowsFeature Web-CGI -WarningAction SilentlyContinue
    Install-WindowsFeature Web-Includes -WarningAction SilentlyContinue
    Install-WindowsFeature Web-WebSockets -WarningAction SilentlyContinue
    Install-WindowsFeature Web-Mgmt-Console -WarningAction SilentlyContinue
    Write-Host "IIS is now installed"
    Read-Host "Press Enter to continue . . . "
}

Write-Host "Creating folder structures needed for installation"
Read-Host "Press Enter to continue . . . "

If (Test-Path "C:\Temp")
{
    Write-Host "Temp Folder at root already created moving on to next step"
}
Else
{
    Write-Host "Creating Temp Folder at root"
    New-Item C:\Temp -type directory | Out-Null
    Write-Host "Temp Folder at root Created"
}

If (Test-Path "C:\Temp\StayinFront")
{
    Write-Host "StayinFront Folder at Temp already created moving on to next step"
}
Else
{
    Write-Host "Creating StayinFront Folder at Temp"
    New-Item C:\Temp\StayinFront -type directory | Out-Null
    Write-Host "StayinFront Folder at Temp Created"
}

If ($purpose -eq 'W') 
{
    Write-Host "Installing Chrome"
    (new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', 'c:/temp/chrome.exe');. c:/temp/chrome.exe /silent /install
    Write-Host "Chrome Installed"
}

Write-Host "Copying Files needed for installation"
Read-Host "Press Enter to continue . . . "

robocopy \\asm.lan\dcshare\app\sif\prod\data\release\iq-files "C:\Temp\StayinFront" /E /log+:C:\Temp\GoldenFileCopy.txt

Write-Host "Installing sqlncli pre-req"
Read-Host "Press Enter to continue . . . "

$InstallRunning = 1
cmd /c 'msiexec.exe /qn /i "C:\Temp\StayinFront\Pre-reqs\sqlncli.msi" IACCEPTSQLNCLILICENSETERMS=YES /l*vx C:\Temp\sqlncliInstallLog.txt'

While ($InstallRunning -eq 1)
{
    $process = "msiexec.exe"
    $InstallRunning = 0
    ForEach ($CommandLine in Get-WmiObject Win32_Process -Filter "name = '$process'" | Select-Object CommandLine ){If ($CommandLine -like "*sqlncli.msi*") {$InstallRunning = 1}}
}


Write-Host "sqlncli pre-req is now installed"
Write-Host "Installing MSODBC pre-req"
Read-Host "Press Enter to continue . . . "

$InstallRunning = 1
cmd /c 'msiexec.exe /qn /i "C:\Temp\StayinFront\Pre-reqs\msodbcsql.msi" IACCEPTMSODBCSQLLICENSETERMS=YES /l*vx C:\Temp\msodbcsqlInstallLog.txt'

While ($InstallRunning -eq 1)
{
    $process = "msiexec.exe"
    $InstallRunning = 0
    ForEach ($CommandLine in Get-WmiObject Win32_Process -Filter "name = '$process'" | Select-Object CommandLine ){If ($CommandLine -like "*msodbcsql.msi*") {$InstallRunning = 1}}
}

Write-Host "MSODBC pre-req is now installed"
Write-Host "Your server will now restart. After restart please run file #2 to complete installation"

pause
Restart-Computer -Force


