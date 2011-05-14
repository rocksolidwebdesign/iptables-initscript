#!/usr/bin/env bash

# flushing all the firewall rules... should this happen by default? 
# me thinks it's rude, so I'm commenting it out for now
#service iptables stop

# delete all the custom utility scripts like fw-up and fw-down
echo "Removing firewall toggle scripts from /usr/local/sbin"
find /usr/local/sbin -executable -type f -iname 'fw-*' -exec rm -rf "{}" +

# remove from the system startup items
echo "Removing system startup items from runlevels"
find /etc/rc*/*iptables -exec rm -rf "{}" +

# delete the service script
echo "Deleting the service script"
rm -rf /etc/init.d/iptables

echo "Deleting the config files"
rm -rf /etc/iptables
