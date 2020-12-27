ARG PHP_VERSION=7.4
ARG GLOBAL_VERSION=3
ARG NODE_VERSION=12

FROM thecodingmachine/php:${PHP_VERSION}-v${GLOBAL_VERSION}-apache-node${NODE_VERSION}

# Enable extensions
ENV PHP_EXTENSION_XDEBUG=1
ENV PHP_EXTENSION_GD=1
ENV PHP_EXTENSION_LDAP=1
ENV PHP_EXTENSION_GMP=1
ENV PHP_EXTENSION_PGSQL=1
ENV PHP_EXTENSION_PDO_PGSQL=1

# PHP ini variables
ENV PHP_INI_XDEBUG__PROFILER_ENABLE_TRIGGER=1
ENV PHP_INI_XDEBUG__MODE=profil
ENV PHP_INI_XDEBUG__START_WITH_REQUEST=trigger
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

# Install webgrind
RUN git clone https://github.com/jokkedk/webgrind /var/www/html/wg

# Enable the apache ssl extensions
ENV APACHE_EXTENSION_SOCACHE_SHMCB=1
ENV APACHE_EXTENSION_SSL=1

# Setup the keys
RUN mkdir /home/docker/keys
RUN openssl req -new -newkey rsa:4096 -nodes -keyout /home/docker/keys/server.key -out /home/docker/keys/server.csr -subj "/CN=localhost"
RUN openssl x509 -req -days 365 -in /home/docker/keys/server.csr -signkey /home/docker/keys/server.key -out /home/docker/keys/server.crt
COPY 000-default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf
