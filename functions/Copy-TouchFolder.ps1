$ReleasePath = "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease"
$PushPath = "C:\inetpub"

Copy-Item -Path $ReleasePath\Touch\ -Destination $PushPath\ -Recurse -Force
