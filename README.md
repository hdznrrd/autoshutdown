# autoshutdown

Smart power saving for your home fileserver.

A simple shellscript to shut down a machine once a set of monitored machines is no longer reachable.

I've written this for a home fileserver that's woken up using wakeup-on-lan and automatically shuts down 15 minutes after the last known machine on the network isn't reachable anymore (ie. everyone went to bed).


## Installation
- Edit sample.cfg, rename to autoshutdown.cfg and place it in /etc
- Add cronjob to call autoshutdown.sh every couple of minutes
