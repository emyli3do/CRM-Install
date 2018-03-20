$keepgoing = 0

While ($keepgoing -ne 1)
{
    If ($keepgoing -eq 2) {Write-Host "The only acceptable answers to the question are Dev, QA, UAT, Prod. Please make one of these selections"}
    $keepgoing = 2
    $purposeEnvironment = Read-Host "Which envionment is this server for? (Dev, QA, UAT, Prod)?"
    If ($purposeEnvironment -eq 'Prod') {$keepgoing = 1}
    If ($purposeEnvironment -eq 'UAT') {$keepgoing = 1}
    If ($purposeEnvironment -eq 'QA') {$keepgoing = 1}
    If ($purposeEnvironment -eq 'Dev') {$keepgoing = 1}
}

$ReadFileName = "\\asm.lan\dcshare\App\SIF\Prod\Data\!CurrentRelease\ImagesFolder" + $purposeEnvironment + ".txt"
$FileEnvironment = Get-Content ($ReadFileName)

$FilePath = "C:\inetpub\Touch\TouchASM\web.config"
$bLineToChange = 0
$FileOriginal = Get-Content ($FilePath)
[String[]] $FileModified = @()
Foreach ($line in $FileOriginal)
    {
        If ($bLineToChange -eq 1)
        {
            $FileModified +=  "        <value>" + $FileEnvironment + "</value>`n"
            $bLineToChange = 0
        }
        Else
        {
            If ($line -like "*<setting name=`"UploadedFilesPath`" serializeAs=`"String`">*")
            {
                $bLineToChange = 1
                $FileModified += "$line`n"
            }
            Else
            {
                $FileModified += "$line`n"
            }
        }
    }  

Set-Content $Filepath $FileModified

