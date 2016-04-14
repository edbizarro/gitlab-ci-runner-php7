FROM php:7
MAINTAINER Eduardo Bizarro <edbizarro@gmail.com>
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libbz2-dev \
    libcurl4-openssl-dev \
    libmcrypt-dev \
    php-pear \
    curl \
    git \
    unzip \
    zlib1g-dev \
    libxml2-dev \
    libssh2-1 \
    libssh2-1-dev \

  && rm -r /var/lib/apt/lists/*

# PHP Extensions
RUN docker-php-ext-install mcrypt zip xml mbstring curl json pdo_mysql tokenizer dev
  
  # Run xdebug installation.
RUN curl -L https://xdebug.org/files/xdebug-2.4.0rc4.tgz >> /usr/src/php/ext/xdebug.tgz && \
    tar -xf /usr/src/php/ext/xdebug.tgz -C /usr/src/php/ext/ && \
    rm /usr/src/php/ext/xdebug.tgz && \
    docker-php-ext-install xdebug-2.4.0RC4 && \
    docker-php-ext-install pcntl && \
    php -m
  
# Memory Limit
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini

# Time Zone
#RUN echo "date.timezone=Europe/Amsterdam" > $PHP_INI_DIR/conf.d/date_timezone.ini

VOLUME /root/composer

# Environmental Variables
ENV COMPOSER_HOME /root/composer

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    
RUN /usr/local/bin/composer global require hirak/prestissimo

# Goto temporary directory.
WORKDIR /tmp

# Run composer and phpunit installation.
RUN composer selfupdate && \
    composer require "phpunit/phpunit:^5.3" --prefer-dist --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit && \
    rm -rf /root/.composer/cache/*

RUN composer --version
