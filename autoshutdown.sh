#!/bin/bash
# autoshutdown.sh
# monitor a number of machines on the network
# and shutdown the local machine once none
# of the other machines is reachable anymore
#
# call via crontab:
# */5 * * * * /path/to/autoshutdown.sh
#

STATEFILE=/tmp/autoshutdown.state

. /etc/autoshutdown.cfg


function log {
        echo $1
        logger autoshutdown: $1
}

function is_machine_present {
        ping -c 1 -w 2 $1 2>&1 >/dev/null
        if [ $? -ne 0 ]; then
                echo "0"
        else
                echo "1"
        fi
}

function is_atleast_one_machine_present {
        isup="0"
        for host in $1; do
                isup=$(is_machine_present $host)
                if [[ $isup == "1" ]]; then
                        break;
                fi
        done

        echo $isup
}

function check {
        echo "checking monitored hosts"
        isup=$(is_atleast_one_machine_present "$MONITORED_HOSTS")
        if [[ $isup == "1" ]]; then
                LAST_CONTACT=$(date +%s)
                let DEADLINE=$LAST_CONTACT+$SHUTDOWN_DELAY_SECONDS
                log "found at least one host. new deadline: $DEADLINE"
        else
                log "no host alive"

                if [[ $(date +%s) > $DEADLINE ]]; then
                        log "shutting down"
                        rm -f $STATEFILE
                        shutdown -h now
                        exit
                fi
        fi
}

if [ ! -e $STATEFILE ]; then
        echo -n $(date +%s) > $STATEFILE
fi

LAST_CONTACT=$(cat $STATEFILE)
let DEADLINE=$LAST_CONTACT+$SHUTDOWN_DELAY_SECONDS

echo "deadline: $DEADLINE   time: $(date +%s)"

check

echo $LAST_CONTACT > $STATEFILE

