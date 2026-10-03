# Instructions for msmtp

1. Install msmtp and sendmail bridge:

```
sudo apt install msmtp msmtp-mta
```

2. Define a config file in `$XDG_CONFIG_HOME/msmtp/config`

```
account <user>@gmail.com
host smtp.gmail.com
port 587
tls on
tls_starttls on
auth on
user <user>
passwordeval cat ${XDG_CONFIG_HOME:-$HOME/.config}/msmtp/password
from <user>
```

3. Add password to $XDG_CONFIG_HOME/msmtp/password

4. Make config and password files private

```
chmod 600 $XDG_CONFIG_HOME/msmtp/password $XDG_CONFIG_HOME/msmtp/config
```

5. Test

```
printf 'From: <user>@gmail.com\nTo: <recipient>\nSubject: msmtp test email\n\nThis is a test email.\n' | msmtp --account=<user>@gmail.com --read-recipient
```

