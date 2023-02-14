#!/bin/bash
for sock in /var/run/mysqld/mysqld_33*.sock ;
do
echo $sock | awk -F/ '{print $NF}' > /tmp/socket 
socket=$(cat /tmp/socket) 
mysql -S $sock -e 'show master status;' > /tmp/masterstatus_$socket 
sed -i '1d' /tmp/masterstatus_$socket
done
