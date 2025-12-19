ARG PHP_VERSION=8.4

FROM thecodingmachine/php:${PHP_VERSION}-v5-cli-node24

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
	rsync \
	zip \
	unzip \
	jq \
	php-pear

# Update NPM
RUN npm config set update-notifier false
RUN sudo npm update -g npm
