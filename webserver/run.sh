#!/bin/bash
# ./webserver/run.sh --REBUILD rebuild --DB mysql --DBVERSION 5.6
DB=${DB:-mysql}
DBVERSION=${DBVERSION:-5.6}
REBUILD=${REBUILD:-}

# https://brianchildress.co/named-parameters-in-bash/
while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
done

if [[ $DB == "mysql" && $DBVERSION == "5.6" ]]; then
  echo 'Everything is fine. We use mysql 5.6. Please delete the mysql_data directory manually if the mysql version has changed and you run into an error.'
elif [[ $DB == "mysql" && $DBVERSION == "8" ]]; then
  echo 'Everything is fine. We use mysql 8. Please delete the mysql_data directory manually if the mysql version has changed and you run into an error.'
elif [[ $DB == "postgres" ]]; then
  echo 'Everything is fine. We use the latest version of postgres. If you entered a version number, it will be ignored.'
else
  echo 'Something is not OK. We support postgres or mysql. In the case of mysql, we support versions 5.6 and 8.'
  exit
fi

# Create the www directory as the current user. So all subdirs will inherit the permissions.
if [ ! -d $(dirname $0)/www ]; then
  mkdir $(dirname $0)/www
fi

# TODO Add changes to readme

# Start the dev server
DB=$DB REBUILD=$REBUILD DBVERSION=$DBVERSION docker-compose -f $(dirname $0)/docker-compose.yml up
