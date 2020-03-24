FROM thecodingmachine/php:7.4-v3-cli-node12

# Enable extensions
ENV PHP_EXTENSION_XDEBUG=1
ENV PHP_EXTENSION_GD=1
ENV PHP_EXTENSION_LDAP=1
ENV PHP_EXTENSION_GMP=1
ENV PHP_EXTENSION_PGSQL=1
ENV PHP_EXTENSION_PDO_PGSQL=1

# PHP ini variables
ENV PHP_INI_XDEBUG__PROFILER_ENABLE_TRIGGER=1
ENV PHP_INI_UPLOAD_MAX_FILESIZE=200M
ENV PHP_INI_POST_MAX_SIZE=200M

# Install
RUN sudo apt-get update
RUN sudo apt-get install -y mariadb-client
RUN sudo apt-get install -y postgresql-client
RUN sudo apt-get install -y graphviz python
RUN sudo apt-get install -y build-essential
RUN sudo apt-get install -y rsync

# Install joomla tools
RUN composer global require joomlatools/console
