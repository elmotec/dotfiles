# Aliases
Set-Alias vi nvim
Set-Alias gvi nvim-qt
Set-Alias which Get-Command
# Remove diff aliast because it conflicts with the command of the same name.
if (Test-Path alias::diff) {
    Remove-Item alias:diff -force
}
function ls_alias { wsl ls --color=auto -hF $args }
Set-Alias ls ls_alias -Option AllScope

# My PATH
$Env:Path += ";$home\scripts"
$Env:Path += ';C:\Program Files\Git\bin\'
$Env:Path += ';C:\Users\jlecomte\AppData\Local\Programs\Python\Python38'
$Env:Path += ';C:\Program Files\WinMerge\'

# Set the virual editor for subversion, git, ...
$Env:EDITOR="nvim.exe"

# Set TMP variable to ram disk
if (-Not (Test-Path "R:\")) {
    # If you need to create the virtual temp drive
    imdisk -a -t vm -m R: -s 2Gb
}
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

# Git directories will show helpful status (see prompt below).
Import-Module posh-git

# Fish like path shorterning.
# Credit https://www.reddit.com/r/PowerShell/comments/gpqct8/fishlike_prompt_that_autoshrinks_your_current/frpp3vo/
function prompt {
    $regex = [regex]::new("(([\\][^\\]{2})[^\\]+)(?=\\*\\)");
    $folder = $regex.replace($pwd,'$2')
    $GitPromptSettings.DefaultPromptPath = "PS $folder"
    $GitPromptSettings.DefaultPromptPath.ForegroundColor = 0x00FF00
    $prompt += & $GitPromptScriptBlock
    if ($prompt) { "$prompt" } else { "PS $folder" }
}

# Turn on fuzzy finder fzf at the command line.
Import-Module PSFzf -ArgumentList 'Ctrl+t', 'Alt+r' -Force

# Quickly cd to preferred directories.
Import-Module CDPath
Set-CDPath -Path ~,~\Documents,~\Documents\Github,~\Documents\Gitlab,~\Documents\Python

# Display import PS variables
echo "`$VTSettings=$VTSettings"
echo "`$PROFILE=$PROFILE"
echo ""
