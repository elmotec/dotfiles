Set-Alias vi nvim
Set-Alias gvi nvim-qt
Set-Alias which Get-Command

Add-PathVariable "$home\scripts"
Add-PathVariable 'C:\Program Files\Git\bin\'
Add-PathVariable 'C:\Users\jlecomte\AppData\Local\Programs\Python\Python38'
Add-PathVariable 'C:\Program Files\WinMerge\'

# Turn on fzf at the command line.
Import-Module PSFzf -ArgumentList 'Ctrl+t', 'Alt+r' -Force


