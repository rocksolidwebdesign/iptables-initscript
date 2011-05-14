#!/usr/bin/env bash

# This script taken from
# http://rlworkman.net/conf/firewall/sshattacks

IPT=/sbin/iptables
$IPT -N FLYSPRAY

# This rule  checks the  source ip  of a packet  to see  if it's  in the
# BADGUY list, and if so, the packet is silently dropped.
$IPT -A INPUT -p tcp -m recent --rcheck --name BADGUY -j DROP

# This rule first  checks to see if  a packet's source ip is  in the SSH
# list,  and if  so, whether  it's seen  more than  six NEW  SYN packets
# within the last 45 seconds. If so, the NEW SYN packets are sent to the
# PERMBLOCK chain.
$IPT -A INPUT -p tcp --dport 22 --syn -m conntrack --ctstate NEW \
  -m recent \ --rcheck --hitcount 6 --name SSH --seconds 45 -j FLYSPRAY

# This rule  checks whether it's  seen more  than three NEW  SYN packets
# within the last 30 seconds. If so, the NEW SYN packets after the third
# (but less  than the sixth)  are rejected with  a TCP RST  packet. This
# should close the connection, so  innocent attempts to create more than
# three NEW connections within thirty seconds won't keep sending packets
# and find themselves in a permanent ban list.
$IPT -A INPUT -p tcp --dport 22 --syn -m conntrack --ctstate NEW \
  -m recent --update --hitcount 3 --name SSH --seconds 30 -j REJECT \
  --reject-with tcp-reset

# This rule places  all incoming NEW SYN ssh attempts  in the "SSH" list
# (well, obviously, the ones caught by  the earlier rules won't see this
# rule)
$IPT -A INPUT -p tcp --dport 22 --syn -m conntrack --ctstate NEW \
  -m recent --set --name SSH -j ACCEPT

# This rule  takes everything that  was sent  here from the  second rule
# above,  sets the  source address  in the  "BADGUY" list,  and silently
# drops the packet. If  you're the curious type, you can  add a LOG rule
# to see a record of all packets getting sent to this chain:
# $IPT -A PERMBLOCK -j LOG --log-prefix "SSH ATTACK:  "
$IPT -A FLYSPRAY -p tcp -m recent --set --name BADGUY -j DROP


# To summarize, this  setup will allow three NEW SYN  packets on port 22
# from any given ip address. After three packets within 30 seconds, that
# address will  have the connection  closed by  a TCP RST  response, and
# after  six packets  within 45  seconds, the  packets will  be silently
# dropped and the sender's ip address added to a permanent block list.
#
# Once a sender triggers the REJECT  rule, they will be required to wait
# however  many seconds  are specified  (30, in  this example)  to avoid
# resetting  the timer  and being  rejected again.  So long  as NEW  SYN
# packets  are  being  sent,  these  rules  will  keep  rejecting  them,
# incrementing the counter, and resetting the timer.
#
# Once a  sender ip  address is  added to the  "BADGUY" list,  they will
# always be dropped immediately per  the first rule above. However, bear
# in mind that  this is not *truly*  a *permanent* ban list  - the lists
# will be cleared by a reboot or an iptables rules flush.
#
# This should go without saying, but  I'm assuming that you have correct
# rules  in place  above  these  to ACCEPT  packets  in ESTABLISHED  and
# RELATED states,  and that  you place  a rule  to create  the PERMBLOCK
# chain before you actually try to jump to that chain.
#
# Finally,  see  man iptables  /recent  for  more information.  You  can
# add/remove addresses from the lists  manually, and there's quite a bit
# more helpful information on the manual page.
