#!/bin/sh
#
### BEGIN INIT INFO
# Provides:          iptables
# Required-Start:    $syslog
# Required-Stop:     $syslog
# Should-Start:      $local_fs $network
# Should-Stop:       $local_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop the default iptables firewall
# Description:       Manage the iptables firewall using the rules files in /etc/iptables
### END INIT INFO

. /lib/lsb/init-functions

fwbindir="/usr/local/sbin"
up="$fwbindir/fw-up"
down="$fwbindir/fw-down"
save="$fwbindir/fw-save"
resave="$fwbindir/fw-resave"
restore="$fwbindir/fw-restore"
lock="$fwbindir/fw-lock"

[ -s "$up" ] || exit 0
[ -s "$down" ] || exit 0
[ -s "$save" ] || exit 0
[ -s "$resave" ] || exit 0
[ -s "$restore" ] || exit 0
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

start()   { log_cmd_with_status "$up"      "Starting $service_name..."; }
stop()    { log_cmd_with_status "$down"    "Stopping $service_name..."; }
save()    { log_cmd_with_status "$save"    "Saving backup $service_name..."; }
resave()  { log_cmd_with_status "$resave"  "Saving backup with reset packet counts for $service_name..."; }
restore() { log_cmd_with_status "$restore" "Loading $service_name rules from backup..."; }
lock()    { log_cmd_with_status "$lock"    "Pretending to lock $service_name..."; }

# See how we were called.
case "$1" in
    start)
        if [ -s /etc/iptables/saved.rules ]; then
            restore
        else
            start
        fi
        ;;
    stop)
        save
        stop
        ;;
    restart)
        save
        restore
        ;;
    save)
        save
        ;;
    reset)
        resave
        ;;
    force-reload)
        start
        resave
        ;;
    lock)
        lock
        ;;
    status)
        log_warning_msg "Firewall rules in iptables.\n$(/sbin/iptables -vL)"
        ;;
    *)
        log_success_msg "Usage: iptables {start|stop|restart|save|reset|force-reload|lock|status}"
        exit 1
esac
