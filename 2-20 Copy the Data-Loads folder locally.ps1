$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'ALLServersNoCitrix.txt'
$Computers       = Get-Content $LoadServerFile

New-Item "C:\Temp\DataLoadsScripts" -ItemType Directory
Copy-Item -Container "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease\Data-Loads" -Destination "C:\Temp\DataLoadsScripts\" -Recurse

cmd /c 'C:\Temp\DataLoadsScripts\Data-Loads\Script\Run Script.cmd'
cmd /c 'C:\Temp\DataLoadsScripts\Data-Loads\Script 2\Run Script.cmd'
cmd /c 'C:\Temp\DataLoadsScripts\Data-Loads\Script 3\Run Script.cmd'
cmd /c 'C:\Temp\DataLoadsScripts\Data-Loads\Workflow\UpdateSelectedWorkflow.cmd'
