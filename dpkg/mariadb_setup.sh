#!/bin/bash
sudo apt -y update
sudo apt -y install mariadb-server

echo "----- Checking MariaDB status -----"
echo "sudo systemctl status mariadb"
sudo systemctl status mariadb
if [ "$?" -ne 0 ]; then
    echo "MariaDB was not installed correctly"
    exit 1
fi

echo
echo "Version info:"
mysql -V

MY_IP_ADDR=`curl ifconfig.me`
echo
echo "IP Address: $MY_IP_ADDR"

echo
echo "----- Starting MySQL Secure Installation -----"
sudo mysql_secure_installation
if [ "$?" -eq 0 ]; then
    echo
    echo "You may now log in to MariaDB using:"
    echo "mysql -u root -p"
fi
