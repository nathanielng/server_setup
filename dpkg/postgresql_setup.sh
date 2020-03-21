#!/bin/bash
sudo apt -y update
sudo apt -y install postgresql postgresql-contrib postgresql-server-dev-all

echo "----- Creating PostgreSQL database user -----"
sudo -u postgres createuser --superuser ${USER} -P

MY_IP_ADDR=`curl ifconfig.me`
PG_HBA_FILE="/etc/postgresql/10/main/pg_hba.conf"
PG_CONF_FILE="/etc/postgresql/10/main/postgresql.conf"

echo "----- IP Address Setup -----"
echo "sudo vi $PG_HBA_FILE"
echo "host	all	all	${MY_IP_ADDR}/32 md5"

echo "sudo vi $PG_CONF_FILE"
echo "listen_addresses = '{MY_IP_ADDR}'"

