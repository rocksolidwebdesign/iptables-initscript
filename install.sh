#!/usr/bin/env bash

echo "Installing the toggle scripts like fw-up and fw-down."
find . -executable -type f -iname 'fw-*' -exec cp "{}" /usr/local/sbin \;

echo "Installing the init script"
cp init_script.sh /etc/init.d/iptables

echo "Enabling the firewall on boot."
update-rc.d iptables defaults

echo "Installing the rules files"
mkdir -p /etc/iptables
find . -iname '*.rules' -exec cp "{}" /etc/iptables \;

# should this happen by default?
# it seems presumptuous and also
# not in scope for the currently
# intended audience
#service iptables start
