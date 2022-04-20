FROM php:8.1.4-apache-buster

# Instalacion de librerias
RUN apt-get update
RUN apt-get install -y unzip
RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libjpeg62-turbo-dev
RUN apt-get install -y libmcrypt-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y libaio1
RUN apt-get install -y libbz2-dev
RUN apt-get install -y libssl-dev
RUN apt-get install -y libgmp-dev
RUN apt-get install -y libldap2-dev
RUN apt-get install -y mariadb-client
RUN apt-get install -y librecode0
RUN apt-get install -y librecode-dev
RUN apt-get install -y libxslt-dev 

# intl
RUN docker-php-ext-configure intl --enable-intl \
 && docker-php-ext-install -j$(nproc) \
     iconv \
     intl

# images
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
 && docker-php-ext-install -j$(nproc) exif gd

# Instalacion de SOAP
RUN rm /etc/apt/preferences.d/no-debian-php
RUN apt-get update -y \
  && apt-get install -y \
     libxml2-dev \
     php-soap \
  && apt-get clean -y \
  && docker-php-ext-install soap

# Configuraciones adicionales
COPY docker-php.conf /etc/apache2/conf-enabled/docker-php.conf
COPY pm-custom.ini /usr/local/etc/php/conf.d/pm-custom.ini
ADD www/ /var/www/html/

RUN printf "log_errors = On \nerror_log = /dev/stderr\n" > /usr/local/etc/php/conf.d/php-logs.ini
RUN a2enmod rewrite
RUN a2enmod headers

# Oracle instantclient - OCI
ADD instantclient/instantclient-basiclite-linux.x64-12.2.0.1.0.zip /tmp/
ADD instantclient/instantclient-sdk-linux.x64-12.2.0.1.0.zip /tmp/

RUN unzip /tmp/instantclient-basiclite-linux.x64-12.2.0.1.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_12_2 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/libocci.so.12.1 /usr/local/instantclient/libocci.so

ENV LD_LIBRARY_PATH=/usr/local/instantclient
RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8

RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient
RUN docker-php-ext-install pdo_oci
RUN docker-php-ext-enable oci8

# Librerias adicionales PHP
RUN docker-php-ext-install bz2
RUN docker-php-ext-install exif
RUN docker-php-ext-install ftp
RUN docker-php-ext-install gettext

RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
RUN docker-php-ext-install gmp

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-install ldap

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install shmop
RUN docker-php-ext-install soap
RUN docker-php-ext-install sockets
RUN docker-php-ext-install xsl

RUN apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

# Configuracion Apache
RUN ln -s /etc/apache2/mods-available/ssl.load  /etc/apache2/mods-enabled/ssl.load


EXPOSE 80 443
