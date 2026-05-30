# ssh.bashrc

# Look up all public ssh keys found in ~/.ssh
keys=$(cd ~/.ssh && ls *.pub | sed 's|\.pub||g' 2> /dev/null)

# Enable SSO via keychain and ssh-agent for those keys
[[ -n $keys ]] && eval $(keychain -q --eval --agents ssh $keys)

