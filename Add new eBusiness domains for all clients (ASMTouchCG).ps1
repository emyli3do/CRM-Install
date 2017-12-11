Copy-Item -Path "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease\ASMTouchCG.reg" "C:\Temp\ASMTouchCG.reg"

cmd /c 'REGEDIT.EXE /S C:\Temp\ASMTouchCG.reg'

Remove-Item "C:\Temp\ASMTouchCG.reg"
