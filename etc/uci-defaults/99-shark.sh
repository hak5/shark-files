#!/bin/sh
# Firstboot setup script for the Shark Jack by Hak5


# Change root password
echo -e "hak5shark\nhak5shark\n" | passwd

# Change the hostname
uci set system.@system[0].hostname=shark
uci commit system
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname

# Disable Telnet server
/etc/init.d/telnet disable
/etc/init.d/telnet stop

# Disable AutoSSH
/etc/init.d/autossh disable
/etc/init.d/autossh stop

# Disable SSH server
/etc/init.d/sshd disable
/etc/init.d/sshd stop

# Disable odhcpd
/etc/init.d/odhcpd disable
/etc/init.d/odhcpd stop

# Disable uHTTPd web server
/etc/init.d/uhttpd disable
/etc/init.d/uhttpd stop

# Enable Shark service
/etc/init.d/shark enable
/etc/init.d/shark start


# Ensure the script is deleted after execution
exit 0
