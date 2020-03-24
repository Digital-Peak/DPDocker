#!/bin/bash

if [ ! -d /var/www/html/Projects/$1 ]; then
	exit
fi

# Setup root directory
root=/var/www/html/$1;
if [ ! -d $root ]; then
	ln -s /var/www/html/Projects/$1 $root
fi

./install-joomla.sh $root $2 $1 "Joomla $1" mailcatcher $3