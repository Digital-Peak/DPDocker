#!/bin/bash

if [ -z $1 ]; then
  echo "No pr set, please run the script with a pr number from https://github.com/joomla/joomla-cms/pulls!"
  exit 1
fi

# Setup root dir
root=/var/www/html/pr/$1

# Empty the install directory if rebuild is set
if [ ! -z $2 ]; then
  sudo rm -rf $root
fi

# Create the rood directory when ti doesn't exist
if [ ! -d $root ]; then
  mkdir -p $root
fi

cd $root

# Clone the repo if it doesn't exist
if [ ! -d /var/www/html/libraries ]; then
  git clone https://github.com/joomla/joomla-cms.git $root
fi

# Switch to the pr
git reset --hard
git branch -D pr-$1 &>/dev/null
git fetch origin pull/$1/head:pr-$1
git checkout pr-$1

# Run composer
if [ ! -z $2 ]; then
  rm -rf $root/libraries/vendor
fi
composer install

# Run npm
if [ -f $root/package.json ]; then
  if [ ! -z $2 ]; then
    npm ci
  else
    npm i
  fi
fi

echo "PR $1 is checked out and ready to test on http://localhost:8090/pr/$1!"
echo "Use mysql-pr as DB host and root/root as DB credentials!"
echo "PHPMyAdmin is available on http://localhost:8091!"
echo "Mailcatcher is available on http://localhost:8092, set 'mailcatcher-pr' as SMTP host in your joomla configuration!"
