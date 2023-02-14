#!/bin/bash


### STANDARD VARS ###
MASTERHOST=host1
SLAVEHOST=host2
USER=replication
PASSWORD=mypassword
PORT=myport
#Change $PATH if you copied the files to a different folder
PATH=/tmp/mysql_repl

### PREPARE SQL STATEMENTS ###
echo "### PREPARE SQL STATEMENTS ###"
#Change the grants if you need more grants
echo "GRANT REPLICATION SLAVE ON *.* TO '$USER'@'%';flush privileges;" > $PATH/creategrant.sql
echo "CREATE USER IF NOT EXISTS '$USER'@'%' IDENTIFIED BY '$PASSWORD'; flush privileges;" > $PATH/createuser.sql

### COPY SQL FILES TO HOSTS ###
echo "### COPY SQL FILES TO HOSTS ###"
scp $PATH/creategrant.sql root@$MASTERHOST:/tmp/creategrant.sql
scp $PATH/createuser.sql root@$MASTERHOST:/tmp/createuser.sql
scp $PATH/createuser.sql root@$SLAVEHOST:/tmp/createuser.sql
scp /Users/mgebert/Documents/Scripts/mysql_repl/changeto.sh root@$SLAVEHOST:/tmp/changeto.sh
scp /Users/mgebert/Documents/Scripts/mysql_repl/masterstatus.sh root@$MASTERHOST:/tmp/masterstatus.sh
ssh root@$MASTERHOST "chmod +x /tmp/createuser.sql /tmp/creategrant.sql"
ssh root@$MASTERHOST "chmod +x /tmp/masterstatus.sh"
ssh root@$SLAVEHOST "chmod +x /tmp/createuser.sql /tmp/changeto.sh"
ssh root@$SLAVEHOST "chmod +x /tmp/changeto.sh"
ssh root@$SLAVEHOST "sed -i -e '2i'MASTERHOST=$MASTERHOST'   '$1'\' /tmp/changeto.sh"
ssh root@$SLAVEHOST "sed -i -e '2i'PASSWORD=$PASSWORD'   '$1'\' /tmp/changeto.sh"
ssh root@$SLAVEHOST "sed -i -e '2i'USER=$USER'   '$1'\' /tmp/changeto.sh"

### RUN SQL FILES ON HOSTS ###
echo "### RUN SQL FILES ON HOSTS ###"
ssh root@$MASTERHOST "for sock in /var/run/mysqld/mysqld_33*.sock ; do echo \$sock && mysql -S \$sock < /tmp/createuser.sql; done"
ssh root@$MASTERHOST "for sock in /var/run/mysqld/mysqld_33*.sock ; do echo \$sock && mysql -S \$sock < /tmp/creategrant.sql; done"
ssh root@$SLAVEHOST "for sock in /var/run/mysqld/mysqld_33*.sock ; do echo \$sock && mysql -S \$sock < /tmp/createuser.sql; done"

### SAFE MASTER STATUS TO FILE ###
echo "### SAFE MASTER STATUS TO FILE ###"
ssh root@$MASTERHOST "/tmp/masterstatus.sh"

### COPY FILES TO SLAVE HOST ###
echo "### COPY FILES TO SLAVE HOST ###"
scp root@$MASTERHOST:/tmp/masterstatus_mysql* /tmp
scp /tmp/masterstatus_mysql* root@$SLAVEHOST:/tmp

### RUN CHANGE MASTER QUERY ###
echo "### RUN CHANGE MASTER QUERY ###"
ssh root@$SLAVEHOST "/tmp/changeto.sh"
