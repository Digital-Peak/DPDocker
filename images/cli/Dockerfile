ARG PHP_VERSION=8.2

FROM thecodingmachine/php:${PHP_VERSION}-v4-cli-node18

# Enable extensions
ENV PHP_EXTENSION_GD=1
ENV PHP_EXTENSION_GMP=1
ENV PHP_EXTENSION_INTL=1
ENV PHP_EXTENSION_LDAP=1
ENV PHP_EXTENSION_PGSQL=1
ENV PHP_EXTENSION_PDO_PGSQL=1
ENV PHP_EXTENSION_PDO_SQLITE=1
ENV PHP_EXTENSION_SQLITE3=1
ENV PHP_EXTENSION_XDEBUG=1

# PHP ini variables
ENV PHP_INI_XDEBUG__MODE=coverage,debug,profile,trace
ENV PHP_INI_XDEBUG__START_WITH_REQUEST=trigger
ENV PHP_INI_UPLOAD_MAX_FILESIZE=200M
ENV PHP_INI_POST_MAX_SIZE=200M

# Install
RUN sudo apt-get update
RUN sudo apt-get install -y mariadb-client
RUN sudo apt-get install -y postgresql-client
RUN sudo apt-get install -y sqlite3
RUN sudo apt-get install -y graphviz python
RUN sudo apt-get install -y build-essential
RUN sudo apt-get install -y rsync
RUN sudo apt-get install -y zip
RUN sudo apt-get install -y unzip
RUN sudo apt-get install -y php-pear

# Memory profiles
RUN sudo apt-get install -y libjudy-dev
RUN sudo apt-get install -y php-dev
RUN sudo pecl install memprof
ENV MEMPROF_PROFILE=dump_on_limit

RUN sudo npm install -g bun
