ARG PHP_VERSION=8.4

FROM thecodingmachine/php:${PHP_VERSION}-v4-apache-node22

# Enable extensions
ENV PHP_EXTENSION_GD=1
ENV PHP_EXTENSION_GMP=1
ENV PHP_EXTENSION_INTL=1
ENV PHP_EXTENSION_IMAP=1
ENV PHP_EXTENSION_LDAP=1
ENV PHP_EXTENSION_PGSQL=1
ENV PHP_EXTENSION_PDO_PGSQL=1
ENV PHP_EXTENSION_PDO_SQLITE=1
ENV PHP_EXTENSION_SQLITE3=1
ENV PHP_EXTENSION_XDEBUG=1
ENV PHP_EXTENSION_BCMATH=1

# PHP ini variables
ENV PHP_INI_XDEBUG__MODE=coverage,debug,profile,trace
ENV PHP_INI_XDEBUG__START_WITH_REQUEST=trigger
ENV PHP_INI_UPLOAD_MAX_FILESIZE=200M
ENV PHP_INI_POST_MAX_SIZE=200M
ENV PHP_INI_OPCACHE__JIT=disable
ENV PHP_INI_OPCACHE__JIT_BUFFER_SIZE=0

# Install
RUN sudo apt-get update && sudo apt-get install -y \
	mariadb-client \
	postgresql-client \
	sqlite3 \
	graphviz python \
	build-essential \
	rsync \
	zip \
	unzip \
	php-pear

# Update NPM and install bun
RUN sudo npm update -g npm && sudo npm install -g bun

# Enable the apache ssl extensions
ENV APACHE_EXTENSION_DAV=1
ENV APACHE_EXTENSION_DAV_FS=1
ENV APACHE_EXTENSION_SOCACHE_SHMCB=1
ENV APACHE_EXTENSION_SSL=1

# Setup the keys
RUN mkdir /home/docker/keys
RUN sudo openssl req -new -newkey rsa:4096 -nodes -keyout /home/docker/keys/server.key -out /home/docker/keys/server.csr -subj "/CN=localhost"
RUN sudo openssl x509 -req -days 365 -in /home/docker/keys/server.csr -signkey /home/docker/keys/server.key -out /home/docker/keys/server.crt
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY 000-default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf
COPY webdav.user /etc/apache2/webdav.user
RUN mkdir -p -m 777 /var/www/html/webdav
