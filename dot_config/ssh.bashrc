# ssh.bashrc

# Enable SSO via keychain and ssh-agent.
[[ -f ${HOME}/.ssh/id_ecdsa ]] && eval $(keychain -q --eval --agents ssh id_ecdsa)

