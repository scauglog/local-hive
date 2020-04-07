#!/bin/bash
/usr/sbin/sshd
start-dfs.sh

su - postgres -c "/usr/bin/postgres -D /var/lib/pgsql/data -p 5432 > /var/log/postgres.log 2>&1 &"
hive --service metastore &> /var/log/hive-meta.log &
hive --service hiveserver2 &> /var/log/hive-server.log &
tail -f /dev/null
