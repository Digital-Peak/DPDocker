#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

# Setup root directory
root=$1
dbHost=$2
dbName=$3
site=$4
smtpHost=$5
rebuild=$6

# Change the working directory
cd $root
echo "Doing setup on $root"

if [ -f $root/libraries/autoload_psr4.php ]; then
	rm -f $root/libraries/autoload_psr4.php
fi

if [[ ! -d $root/libraries/vendor || ! -z $rebuild ]]; then
  echo "Installing PHP dependencies"
	rm -rf $root/libraries/vendor
	composer install --quiet
fi

# Run npm
if [ -f $root/package.json ]; then
  if [ ! -z $rebuild ]; then
    echo "Cleaning the assets"
    rm -rf $root/node_modules
    rm -rf $root/administrator/components/com_media/node_modules
    rm -rf $root/media
  fi
  if [ ! -d $root/media/vendor ]; then
    echo "Installing the assets (takes a while!)"
    npm ci &>/dev/null
  fi
fi

# Install Joomla when no configuration file is available
if [[ -f $root/configuration.php && -z $rebuild ]]; then
  exit
fi

echo "Setting up Joomla"

if [ ! -f $root/.htaccess ]; then
  cp $root/htaccess.txt $root/.htaccess
fi

# Setup configuration file
sudo cp $(dirname $0)/configuration.php $root/configuration.php
sed -i "s/{SITE}/$site/g" $root/configuration.php
sed -i "s/{DBHOST}/$dbHost/g" $root/configuration.php
sed -i "s/{DBNAME}/$dbName/g" $root/configuration.php
sed -i "s/{SMTPHOST}/$smtpHost/g" $root/configuration.php
sed -i "s/{PATH}/${root//\//\\/}/g" $root/configuration.php

# Define install folder
installFolder=$root/installation
if [ ! -d $installFolder ]; then
  installFolder=$root/_installation
fi

if [[ -z $dbHost || $dbHost == 'mysql'* ]]; then
  echo "Installing Joomla with mysql"
  sed -i "s/{DBDRIVER}/mysqli/g" $root/configuration.php

  # Install joomla
  mysql -u root -proot -h $dbHost -e "drop database if exists $dbName"
  mysql -u root -proot -h $dbHost -e "create database $dbName"

  if [ -f $installFolder/sql/mysql/joomla.sql ]; then
    sed "s/#_/j/g" $installFolder/sql/mysql/joomla.sql | mysql -u root -proot -h $dbHost -D $dbName
  else
    sed "s/#_/j/g" $installFolder/sql/mysql/base.sql | mysql -u root -proot -h $dbHost -D $dbName
    sed "s/#_/j/g" $installFolder/sql/mysql/extensions.sql | mysql -u root -proot -h $dbHost -D $dbName
    sed "s/#_/j/g" $installFolder/sql/mysql/supports.sql | mysql -u root -proot -h $dbHost -D $dbName
  fi

  mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_users (id, name, username, email, password, block, registerDate, params) VALUES(42, 'Admin', 'admin', 'admin@example.com', '\$2y\$10\$O.A8bZcuC6yFfgjzycqzku7LuG6zvBiozJcjXD4FP3bhJdvyKdtoG', 0, '2020-01-01 00:00:01', '{}')"
  mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('42', '8')"
  mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_users (id, name, username, email, password, block, registerDate, params) VALUES(43, 'Manager', 'manager', 'manager@example.com', '\$2y\$10\$GICucf86nqR95Jz0mGTPkej8Mvzll/DRdXVClsUOkzyIPl6XF.2hS', 0, '2020-01-01 00:00:01', '{}')"
  mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('43', '6')"
  mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_users (id, name, username, email, password, block, registerDate, params) VALUES(44, 'User', 'user', 'user@example.com', '\$2y\$10\$KesDwI5C.oMfZksWG7UHaOP.1TWf91HTZPOi143qx2Tvc/8.hJIU.', 0, '2020-01-01 00:00:01', '{}')"
  mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('44', '2')"
  mysql -u root -proot -h $dbHost -D $dbName -e "UPDATE j_extensions SET manifest_cache='{\"version\":\"3\"}'"
fi

if [[ $dbHost == 'postgres'* ]]; then
  echo "Installing Joomla with postgres"
  sed -i "s/{DBDRIVER}/pgsql/g" $root/configuration.php
  export PGPASSWORD=root

  # Clear existing connections
  psql -U root -h $dbHost -c "REVOKE CONNECT ON DATABASE $dbName FROM public" > /dev/null 2>&1
  psql -U root -h $dbHost -c "SELECT pid, pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$dbName' AND pid <> pg_backend_pid()" > /dev/null

  # Install joomla
  psql -U root -h $dbHost -c "drop database if exists $dbName" > /dev/null
  psql -U root -h $dbHost -c "create database $dbName" > /dev/null

  if [ -f $installFolder/sql/mysql/joomla.sql ]; then
    sed "s/#_/j/g" $installFolder/sql/postgresql/joomla.sql | psql -U root -h $dbHost -d $dbName > /dev/null
  else
    sed "s/#_/j/g" $installFolder/sql/postgresql/base.sql | psql -U root -h $dbHost -d $dbName > /dev/null
    sed "s/#_/j/g" $installFolder/sql/postgresql/extensions.sql | psql -U root -h $dbHost -d $dbName > /dev/null
    sed "s/#_/j/g" $installFolder/sql/postgresql/supports.sql | psql -U root -h $dbHost -d $dbName > /dev/null
  fi

  psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_users (id, name, username, email, password, block,  \"registerDate\", params) VALUES(42, 'Admin', 'admin', 'admin@example.com', '\$2y\$10\$O.A8bZcuC6yFfgjzycqzku7LuG6zvBiozJcjXD4FP3bhJdvyKdtoG', 0, '2020-01-01 00:00:00', '{}')" > /dev/null
  psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('42', '8')" > /dev/null
  psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_users (id, name, username, email, password, block,  \"registerDate\", params) VALUES(43, 'Manager', 'manager', 'manager@example.com', '\$2y\$10\$GICucf86nqR95Jz0mGTPkej8Mvzll/DRdXVClsUOkzyIPl6XF.2hS', 0, '2020-01-01 00:00:00', '{}')" > /dev/null
  psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('43', '6')" > /dev/null
  psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_users (id, name, username, email, password, block,  \"registerDate\", params) VALUES(44, 'User', 'user', 'user@example.com', '\$2y\$10\$KesDwI5C.oMfZksWG7UHaOP.1TWf91HTZPOi143qx2Tvc/8.hJIU.', 0, '2020-01-01 00:00:00', '{}')" > /dev/null
  psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('44', '2')" > /dev/null
  psql -U root -h $dbHost -d $dbName -c "UPDATE j_extensions SET manifest_cache='{\"version\":\"3\"}'" > /dev/null
fi
