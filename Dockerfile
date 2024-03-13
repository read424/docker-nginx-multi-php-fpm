FROM php:7.4.0-fpm

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV TZ=America/Lima

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# define timezone
RUN echo $TZ > /etc/timezone
RUN /bin/echo -e "LANG=\"en_US.UTF-8\"" > /etc/default/local

# Instalar las dependencias necesarias para Composer
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libpq-dev \
    libzip-dev \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmagickwand-dev \
    wget \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libwebp-dev \
    libffi-dev \
    libonig-dev \
    curl \
    libcurl4 \
    libcurl4-openssl-dev \
    jpegoptim \
    pngquant \
    gifsicle \
    optipng \
    libmemcached-dev memcached \
    gcc make autoconf libc-dev pkg-config \
    locales zlib1g-dev \
    libssh2-1 libssh2-1-dev libxml2-dev libxml++2.6-dev \
    vim nano git \
    wkhtmltopdf \
    build-essential \
    zip xvfb openssl

RUN apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install gd

RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) zip

# mcrypt
#RUN pecl install mcrypt-1.0.3
RUN pecl install mcrypt-1.0.4
RUN pecl install ssh2-1.3.1
RUN pecl install imagick

RUN docker-php-ext-enable mcrypt
RUN docker-php-ext-enable imagick

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-configure ffi --with-ffi && docker-php-ext-install ffi

# Instalamos extensiones de PHP
RUN docker-php-ext-install zip 
RUN docker-php-ext-install sockets
RUN docker-php-ext-install exif 
RUN docker-php-ext-install pcntl 
RUN docker-php-ext-install pgsql pdo_pgsql 
RUN docker-php-ext-install xml
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install soap
RUN docker-php-ext-install iconv 
RUN docker-php-ext-install soap

RUN wget -O wkhtmltopdf.tar.xz https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar Jxvf wkhtmltopdf.tar.xz
RUN cp wkhtmltox/bin/wkhtmlto* /usr/bin/

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Cambiar nuevamente al usuario root
USER root

# clean image
RUN apt-get clean

EXPOSE 9000

# Iniciar el servicio PHP-FPM
CMD ["php-fpm"]