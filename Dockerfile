FROM php:7.2-apache

COPY src/scripts/docker-php-* /usr/local/bin/
RUN chmod 777 /usr/local/bin/docker-php-*

COPY php.ini /usr/local/etc/php/php.ini
RUN sed -E 's/(DocumentRoot \/var\/www\/html.*)/\1\n\tHttpProtocolOptions Unsafe/g' /etc/apache2/sites-available/000-default.conf > /tmp/000-default.conf
RUN cp /tmp/000-default.conf /etc/apache2/sites-available/
