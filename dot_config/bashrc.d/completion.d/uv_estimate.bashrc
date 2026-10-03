_uv_with_estimate_completion() {
    if [[ ${COMP_WORDS[1]} == run &&
          ${COMP_WORDS[2]} == estimate &&
          $COMP_CWORD -ge 3 ]]; then
        local -a saved_words=("${COMP_WORDS[@]}")
        local saved_cword=$COMP_CWORD

        COMP_WORDS=(estimate "${saved_words[@]:3}")
        COMP_CWORD=$((saved_cword - 2))
        COMPREPLY=()
        _estimate_completion "$HOME/dev/estimate/.venv/bin/estimate"

        COMP_WORDS=("${saved_words[@]}")
        COMP_CWORD=$saved_cword
    else
        _uv "$@"
    fi
}
complete -o nosort -F _uv_with_estimate_completion uv

