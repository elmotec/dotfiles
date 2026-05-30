# ssh.bashrc

keys="id_ecdsa id_ed25519_github id_ed25519_gitlab"

# Enable SSO via keychain and ssh-agent.
[[ -f ${HOME}/.ssh/id_ecdsa ]] && eval $(keychain -q --eval --agents ssh $keys)

