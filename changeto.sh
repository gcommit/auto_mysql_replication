#!/bin/bash
### BUILD CHANGE MASTER QUERY FOR SLAVEHOST ###
for sock in /var/run/mysqld/mysqld_33*.sock ;
do
echo $sock | awk -F/ '{print $NF}' > /tmp/socket && socket=$(cat /tmp/socket)
socket=${socket%.*}
declare POS=$(cat /tmp/masterstatus_$socket | awk '{print $2}')
declare FILE=$(cat /tmp/masterstatus_$socket | awk '{print $1}')
mysql -S $sock -e "CHANGE MASTER TO MASTER_HOST='$MASTERHOST', MASTER_USER='$USER', MASTER_PASSWORD='$PASSWORD', MASTER_LOG_FILE='$FILE', MASTER_LOG_POS=$POS,MASTER_PORT=$PORT;"

### FOR DEBUGGING UNCOMMENT  THE LINE ###
#echo $POS $FILE $USER $PASSWORD $MASTERHOST $sock

done
