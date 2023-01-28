# Aliases

# No real need to use python 2
alias py=python3
alias vi=$EDITOR
alias apt='sudo apt'
alias bell='echo -e "\a"'
alias ..='cd ..'
alias ...='cd ../..'
alias k=true
alias grep='grep --color=auto'
alias cz='python3 -m commitizen'
alias reset-time='sudo hwclock --hctosys'
alias update-apt='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y'

# Alias for ls
alias ll='ls --color=auto -Fltrah'
alias ls='ls --color=none'

# Alias for git
alias gc='git commit -v'
alias gca='git commit --amend'
alias gcam='git commit --amend -m'
alias gcav='git commit --amend -v'
alias gcm='git commit -m'
alias gd='git diff'
alias gdt='git difftool'
alias gmt='git mergetool'
alias gp='git push'
alias gs='git status -s'

# Alias for docker
alias d='docker'
alias dc='docker-compose'

# Alias for common commands
alias h='history'
alias j='jobs -l'
alias p='ps -ef'
alias r='fc -s'
alias w='w -h'
alias x='exit'

# Copy/Paste in wsl
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  alias pbcopy='clip.exe'
  alias pbpaste='powershell.exe Get-Clipboard'
fi

# Set title of terminal
set-title() {
    echo -ne "\033]0;$@\007"
}
alias title=set-title

