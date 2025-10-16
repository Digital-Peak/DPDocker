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

# Install vscode debug configuration
if [ ! -d $root/.vscode ]; then
	sudo cp -rf $(dirname $0)/vscode $root/.vscode
	sudo chmod -R 777 $root/.vscode
	sed -i "s|{PATH}|$root|g" $root/.vscode/launch.json
fi

# Cleanup the namespace cache
if [ -f $root/administrator/cache/autoload_psr4.php ]; then
	rm -f $root/administrator/cache/autoload_psr4.php
fi

# Do some cleanup when rebuild is requested
if [ ! -z $rebuild ]; then
	echo "Cleaning the installed dependencies and configuration file"
	rm -rf $root/node_modules
	rm -rf $root/administrator/components/com_media/node_modules
	rm -rf $root/media
	rm -rf $root/libraries/vendor
	sudo rm -rf $root/configuration.php
fi

# Run composer
if [ ! -d $root/libraries/vendor ]; then
	echo "Installing PHP dependencies"
	composer install --quiet
fi

# Build the assets
if [ ! -d $root/media/vendor ]; then
	echo "Installing the assets (takes a while!)"
	mkdir -p $root/media/vendor
	npm ci &>/dev/null
fi

# Abort installatio when configuration file exists
if [ -f $root/configuration.php ]; then
	exit
fi

echo "Setting up Joomla"

# Enable htaccess
if [ ! -f $root/.htaccess ]; then
	cp $root/htaccess.txt $root/.htaccess
fi

echo "Waiting for database server"
while ! mysqladmin ping -u root -proot -h $dbHost --silent  > /dev/null; do
	sleep 4
done

# Define the db type
dbType="mysqli"
if [[ $dbHost == 'postgres'* ]]; then
	dbType="pgsql"
fi

# Clear existing mysql database
if [ $dbType == 'mysqli' ]; then
	mysql -u root -proot -h $dbHost -e "DROP DATABASE IF EXISTS $dbName"
	mysql -u root -proot -h $dbHost -e "CREATE DATABASE $dbName"
fi

# Clear existing pgsql database
if [ $dbType == 'pgsql' ]; then
	export PGPASSWORD=root

	# Clear existing connections
	psql -U root -h $dbHost -c "REVOKE CONNECT ON DATABASE $dbName FROM public" > /dev/null 2>&1
	psql -U root -h $dbHost -c "SELECT pid, pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$dbName' AND pid <> pg_backend_pid()" > /dev/null

	# Install joomla
	psql -U root -h $dbHost -c "DROP DATABASE IF EXISTS $dbName" > /dev/null
	psql -U root -h $dbHost -c "CREATE DATABASE $dbName" > /dev/null
fi

# Install Joomla
php -d error_reporting=1 $root/installation/joomla.php install -n --site-name="$site" --admin-user="Admin" --admin-username=admin --admin-password=adminadminadmin --admin-email=admin@example.com --db-type="$dbType" --db-host="$dbHost" --db-name="$dbName" --db-user=root --db-pass=root --db-prefix="j_"

# Set some parameters
php -d error_reporting=1 $root/cli/joomla.php config:set secret=XgrJSL137VSjPBVn error_reporting=maximum debug=true mailer=smtp smtphost=$smtpHost smtpport=1025 sef_rewrite=true lifetime=9999

# Setup the users in mysql
if [ $dbType == 'mysqli' ]; then
	mysql -u root -proot -h $dbHost -D $dbName -e "DELETE FROM j_users"
	mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_users (id, name, username, email, password, block, registerDate, params) VALUES(42, 'Admin', 'admin', 'admin@example.com', '\$2y\$10\$O.A8bZcuC6yFfgjzycqzku7LuG6zvBiozJcjXD4FP3bhJdvyKdtoG', 0, '2020-01-01 00:00:01', '{}')"
	mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('42', '8')"
	mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_users (id, name, username, email, password, block, registerDate, params) VALUES(43, 'Manager', 'manager', 'manager@example.com', '\$2y\$10\$GICucf86nqR95Jz0mGTPkej8Mvzll/DRdXVClsUOkzyIPl6XF.2hS', 0, '2020-01-01 00:00:01', '{}')"
	mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('43', '6')"
	mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_users (id, name, username, email, password, block, registerDate, params) VALUES(44, 'User', 'user', 'user@example.com', '\$2y\$10\$KesDwI5C.oMfZksWG7UHaOP.1TWf91HTZPOi143qx2Tvc/8.hJIU.', 0, '2020-01-01 00:00:01', '{}')"
	mysql -u root -proot -h $dbHost -D $dbName -e "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('44', '2')"
	mysql -u root -proot -h $dbHost -D $dbName -e "UPDATE j_extensions SET enabled = 0 WHERE name IN ('plg_quickicon_eos', 'plg_system_stats', 'plg_behaviour_compat') OR name LIKE '%guided%'"
fi

# Setup the users in postgres
if [ $dbType == 'pgsql' ]; then
	psql -U root -h $dbHost -d $dbName -c "DELETE FROM j_users" > /dev/null
	psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_users (id, name, username, email, password, block,  \"registerDate\", params) VALUES(42, 'Admin', 'admin', 'admin@example.com', '\$2y\$10\$O.A8bZcuC6yFfgjzycqzku7LuG6zvBiozJcjXD4FP3bhJdvyKdtoG', 0, '2020-01-01 00:00:00', '{}')" > /dev/null
	psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('42', '8')" > /dev/null
	psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_users (id, name, username, email, password, block,  \"registerDate\", params) VALUES(43, 'Manager', 'manager', 'manager@example.com', '\$2y\$10\$GICucf86nqR95Jz0mGTPkej8Mvzll/DRdXVClsUOkzyIPl6XF.2hS', 0, '2020-01-01 00:00:00', '{}')" > /dev/null
	psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('43', '6')" > /dev/null
	psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_users (id, name, username, email, password, block,  \"registerDate\", params) VALUES(44, 'User', 'user', 'user@example.com', '\$2y\$10\$KesDwI5C.oMfZksWG7UHaOP.1TWf91HTZPOi143qx2Tvc/8.hJIU.', 0, '2020-01-01 00:00:00', '{}')" > /dev/null
	psql -U root -h $dbHost -d $dbName -c "INSERT INTO j_user_usergroup_map (user_id, group_id) VALUES ('44', '2')" > /dev/null
	psql -U root -h $dbHost -d $dbName -c "UPDATE j_extensions SET enabled = 0 WHERE name IN ('plg_quickicon_eos', 'plg_system_stats', 'plg_behaviour_compat') OR name LIKE '%guided%'" > /dev/null
fi
