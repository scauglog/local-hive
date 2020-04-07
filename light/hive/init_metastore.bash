#!/bin/bash
/usr/bin/postgres -D /var/lib/postgresql/data -p 5432 > /var/log/postgres.log 2>&1 &
sleep 10
psql -c "CREATE USER hiveuser WITH PASSWORD 'mypassword';"
psql -c "CREATE DATABASE metastore;"
export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/
export PATH=/etc/hadoop/bin:$PATH
export METASTORE_HOME=/etc/hive
export HADOOP_HOME=/etc/hadoop
/etc/hive/bin/schematool -dbType postgres -initSchema