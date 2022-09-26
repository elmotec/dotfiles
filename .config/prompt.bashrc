# Prompt related functions and settings

if [ -f /etc/bash_completion.d/git-prompt ]; then
    . /etc/bash_completion.d/git-prompt
fi

. ~/.config/prompt-colors.sh

showcolors() {
    for x in {0..8}; do
        for i in {30..37}; do
            echo -ne "\e[$x;$i""m\\\e[$x;$i""m \e[0m ";
            for a in {40..47}; do
                echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0m ";
            done;
            echo -ne "\e[$x;$i""m${ColorNames[$(expr $i - 30)]}\e[0m ";
            echo;
        done;
    done;
    echo ""
}

__userhost() {
    echo -e "${Green}\u@\h${ResetColor}"
}

__workdir() {
    echo -e "${Cyan}\w${ResetColor}"
}

# Number of jobs running in the background controlled by this shell.
__job_status() {
    echo -e " ${BrightCyan}\j&${ResetColor}"
}

# Turn text to green if success otherwise red exit code.
__cmd_status() {
    rc=$?
    if [ $rc -eq 0 ]; then
        echo -e "\e[0;32m\n\$"
    else
        echo -e "\e[0;31m 💥 $rc\n\$"
    fi
}

export PROMPT_DIRTRIM=2  # shortern the path to 2 directory levels.

PS1="$(__userhost):$(__workdir)$(__job_status)\$(__git_ps1)\$(__cmd_status)${ResetColor} "
export PS1
