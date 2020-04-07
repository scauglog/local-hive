#!/bin/bash
#/usr/sbin/sshd
#start-dfs.sh

su - postgres -c "/usr/bin/postgres -D /var/lib/postgresql/data -p 5432 > /var/log/postgres.log 2>&1 &"
sleep 10
/etc/hive/bin/start-metastore &> /var/log/hive-meta.log &
tail -f /dev/null
