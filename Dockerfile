FROM php:7.4-apache

RUN apt update && apt upgrade -y
RUN apt install -y \
  default-mysql-client \
  zlib1g-dev \
  libpng-dev \
  libjpeg-dev \
  libfreetype-dev
RUN docker-php-ext-install mysqli && \
  docker-php-ext-enable mysqli && \
  docker-php-ext-configure gd --with-freetype --with-jpeg && \
  docker-php-ext-install gd
RUN apt clean

RUN mkdir -p /var/www/testlink

WORKDIR /var/www/testlink

COPY . .
COPY ./docker/php.ini-production /usr/local/etc/php/conf.d/php.ini

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data
RUN chown -R www-data:www-data /var/www/testlink
RUN rm -rf docker
ENV APACHE_DOCUMENT_ROOT=/var/www/testlink
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2ensite default-ssl
RUN a2enmod ssl

EXPOSE 80 443
CMD ["apache2ctl", "-D", "FOREGROUND"]
