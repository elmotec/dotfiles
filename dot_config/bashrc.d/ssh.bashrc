# ssh.bashrc

# Look up all public ssh keys found in ~/.ssh
#keys=$(cd ~/.ssh && ls *.pub 2>/dev/null| sed 's|\.pub||g')

# Enable SSO via keychain and ssh-agent for those keys
# We are migrating to ed25519
keys="id_ecdsa id_ed25519"
[[ -n $keys ]] && eval $(keychain -q --eval --agents ssh $keys)

