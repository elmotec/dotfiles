# Aliases
Set-Alias vi nvim
Set-Alias gvi nvim-qt
Set-Alias which Get-Command
Set-Alias unison "C:\ProgramData\chocolatey\bin\unison 2.48.4 text.exe"
# Remove diff aliast because it conflicts with the command of the same name.
if (Test-Path alias::diff) {
    Remove-Item alias:diff -force
}

# My PATH
$Env:Path += ";$home\scripts"
$Env:Path += ';C:\Program Files\Git\bin\'
$Env:Path += ';C:\Users\jlecomte\AppData\Local\Programs\Python\Python38'
$Env:Path += ';C:\Program Files\WinMerge\'

# Set the virual editor for subversion, git, ...
$Env:EDITOR="nvim.exe"

# Set TMP variable to ram disk if available
# imdisk -a -t vm -m R: -s 2Gb
if (Test-Path "R:\") {
    $Env:TMP="R:\"
}
else {
    $Env:TMP=$HOME + "\tmp"
}
$Env:TEMP=$Env:TMP
$Env:TMPDIR=$Env:TMP

# Quick access to terminal settings because .json is associated to Visual Studio.
$VTSettings=$HOME + "\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Fish like path shorterning.
# Credit https://www.reddit.com/r/PowerShell/comments/gpqct8/fishlike_prompt_that_autoshrinks_your_current/frpp3vo/
function prompt {
    $regex = [regex]::new("(([\\][^\\])[^\\]+)(?=\\*\\)");
    $folder = $regex.replace($pwd,'$2')
    "PS $folder>"
}

# Turn on fuzzy finder fzf at the command line.
Import-Module PSFzf -ArgumentList 'Ctrl+t', 'Alt+r' -Force

# Quickly cd to preferred directories.
Import-Module CDPath
Set-CDPath -Path ~,~\Documents\Github,~\Documents\Gitlab,~\Documents\Python


