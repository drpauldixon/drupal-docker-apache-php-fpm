# docker build -t customdrupal:10.0.9-php8.2-apache-fpm-bullseye .
FROM drupal:10.0.9-php8.2-fpm-bullseye
RUN apt-get update && apt-get install -y \
    apache2 \
    supervisor \
    less \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && mkdir /var/run/apache2 /var/lock/apache2

COPY php/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY apache2/apache2.conf /etc/apache2/apache2.conf
COPY apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache2/php-fpm.conf /etc/apache2/conf-available/php-fpm.conf
RUN a2enmod proxy_fcgi
RUN a2enconf php-fpm
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
COPY supervisor/apache2.conf /etc/supervisor/conf.d/apache2.conf
COPY php/xx-info.php /opt/drupal/web/xx-info.php

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
