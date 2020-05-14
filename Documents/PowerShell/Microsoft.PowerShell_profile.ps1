Set-Alias vi nvim
Set-Alias gvi nvim-qt
Set-Alias which Get-Command
Set-Alias unison "C:\ProgramData\chocolatey\bin\unison 2.48.4 text.exe"
Remove-Item alias:diff -force

$Env:Path += ";$home\scripts"
$Env:Path += ';C:\Program Files\Git\bin\'
$Env:Path += ';C:\Users\jlecomte\AppData\Local\Programs\Python\Python38'
$Env:Path += ';C:\Program Files\WinMerge\'

# Turn on fzf at the command line.
Import-Module PSFzf -ArgumentList 'Ctrl+t', 'Alt+r' -Force

# Set the virual editor for subversion, git, ...
$Env:EDITOR="nvim.exe"

# Set TMP variable to ram disk
$Env:TMP="R:\"
$Env:TEMP=$Env:TMP
$Env:TMPDIR=$Env:TMP

$VTSettings=$HOME + "\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
# imdisk -a -t vm -m R: -s 2Gb
