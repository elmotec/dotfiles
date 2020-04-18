Set-Alias vi nvim
Set-Alias gvi nvim-qt
Set-Alias which Get-Command

$Env:Path += ";$home\scripts"
$Env:Path += ';C:\Program Files\Git\bin\'
$Env:Path += ';C:\Users\jlecomte\AppData\Local\Programs\Python\Python38'
$Env:Path += ';C:\Program Files\WinMerge\'

# Turn on fzf at the command line.
Import-Module PSFzf -ArgumentList 'Ctrl+t', 'Alt+r' -Force

# Set the virual editor for subversion, git, ...
$Env:EDITOR="nvim.exe"

