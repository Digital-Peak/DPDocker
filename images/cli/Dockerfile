FROM thecodingmachine/php:${PHP_VERSION}-v${GLOBAL_VERSION}-cli-node${NODE_VERSION}

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
RUN sudo apt-get install -y php-pear

# Install joomla tools to a specific directory to not clash with global composer console dependency
RUN composer require joomlatools/console -d /home/docker
