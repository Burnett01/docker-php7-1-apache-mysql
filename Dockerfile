FROM php:7.1-apache

COPY config/php.ini /usr/local/etc/php/

# Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    mysql-client \
  	libjpeg-dev \
  	libpng12-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    git \
    zip \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd \
  && docker-php-ext-install zip \
  && docker-php-ext-install exif \
  && docker-php-ext-install mbstring \
  && docker-php-ext-install mcrypt \
  && docker-php-ext-install mysqli pdo pdo_mysql \
  && rm -rf /var/lib/apt/lists/*

# Imagick
RUN pecl install imagick \
  && docker-php-ext-enable imagick

# Composer & Craft CLI
RUN curl --silent --show-error https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer

ENV PATH "$PATH:~/.composer/vendor/bin"

# Go
RUN curl --insecure -O https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz \
  && tar -xvf go1.9.linux-amd64.tar.gz \
  && mv go /usr/local \
  && cp /usr/local/go/bin/go /usr/local/bin

# Mhsendmail
RUN go get github.com/mailhog/mhsendmail \
  && cp /root/go/bin/mhsendmail /usr/bin/mhsendmail

# Apache Extensions
RUN a2enmod headers rewrite expires deflate

CMD ["apache2-foreground"]
