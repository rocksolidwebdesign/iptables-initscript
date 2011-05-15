#!/bin/sh
#
### BEGIN INIT INFO
# Provides:          iptables
# Required-Start:    mountkernfs $local_fs
# Required-Stop:     $local_fs
# Should-Start:      $local_fs $network
# Should-Stop:       $local_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop the default iptables firewall
# Description:       Manage the iptables firewall using the rules files in /etc/iptables/*.rules
### END INIT INFO

. /lib/lsb/init-functions

fwbindir="/usr/local/sbin"
up="$fwbindir/fw-up"
down="$fwbindir/fw-down"
lock="$fwbindir/fw-lock"

[ -s "$up" ] || exit 0
[ -s "$down" ] || exit 0
[ -s "$lock" ] || exit 0

service_name="iptables"

log_cmd_with_status() {
    command="$1"
    message="$2"

    log_begin_msg "$2"
    "$command" > /dev/null
    command_status=$?
    if [ $command_status -eq 0 ]; then
        log_end_msg 0
    else
        log_end_msg 1
    fi
    return $command_status
}

start()   { log_cmd_with_status "$up"      "Loading $service_name..."; return $?; }
stop()    { log_cmd_with_status "$down"    "Disabling $service_name..."; return $?; }
lock()    { log_cmd_with_status "$lock"    "Pretending to lock $service_name..."; return $?; }

# See how we were called.
case "$1" in
    start|restart|force-reload)
        stop
        start
        command_return_val=$?
        ;;
    stop)
        stop
        command_return_val=$?
        ;;
    lock)
        lock
        command_return_val=$?
        ;;
    status)
        log_warning_msg "Firewall rules in iptables.\n$(/sbin/iptables -vL)"
        command_return_val=$?
        ;;
    *)
        log_success_msg "Usage: iptables {start|stop|restart|save|reset|force-reload|lock|status}"
        exit 1
esac
exit $command_return_val
