# ssh.bashrc

if grep -qi microsoft /proc/version && [[ -d /mnt/c/Users/jlecomte/.ssh ]]; then
    mkdir -p ~/.ssh
    rsync -rlt --chmod=D700,F600 \
        /mnt/c/Users/jlecomte/.ssh/ ~/.ssh/
    chmod 644 ~/.ssh/*.pub 2>/dev/null || true
fi

# Look up all public ssh keys found in ~/.ssh
#keys=$(cd ~/.ssh && ls *.pub 2>/dev/null| sed 's|\.pub||g')

# Enable SSO via keychain and ssh-agent for those keys
keys="id_ecdsa"
[[ -n $keys ]] && eval $(keychain -q --eval --agents ssh $keys)

