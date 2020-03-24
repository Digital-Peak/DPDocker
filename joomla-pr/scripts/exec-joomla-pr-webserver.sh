#!/bin/bash

if [ -z $1 ]; then
  echo "No pr set, please run the script with a pr number from https://github.com/joomla/joomla-cms/pulls!"
  exit 1
fi

# Clone the repo if it doesn't exist for cache
if [ ! -d /var/www/html/pr/cache ]; then
  echo "Building cache"
  git clone https://github.com/joomla/joomla-cms.git /var/www/html/pr/cache
fi

# Setup root dir
root=/var/www/html/pr/$1

# Empty the install directory if rebuild is set
if [ ! -z $3 ]; then
  echo "Cleaning install folder"
  sudo rm -rf $root
fi

# Create the root directory when it doesn't exist
if [ ! -d $root ]; then
  echo "Copy files from /var/www/html/pr/cache"
  mkdir -p $root
  cp -a /var/www/html/pr/cache/. $root
fi

cd $root

# Switch to the pr
echo "Switching to pr code"
git reset --hard &>/dev/null
git branch -D pr-$1 &>/dev/null
git fetch origin pull/$1/head:pr-$1 &>/dev/null
git checkout pr-$1 &>/dev/null

/var/www/html/Projects/DPDocker/webserver/scripts/install-joomla.sh $root $2-pr pr_$1 "Joomla PR $1" mailcatcher-pr $3

echo -e "\e[32mPR $1 is checked out and ready to test on http://localhost:8090/pr/$1!"
echo -e "\e[32mYou can log in with admin/admin!"
echo -e "\e[32mPHPMyAdmin is available on http://localhost:8091!"
echo -e "\e[32mpgAdmin is available on http://localhost:8092, credentials are admin@example.com/root!"
echo -e "\e[32mMailcatcher is available on http://localhost:8093!"
