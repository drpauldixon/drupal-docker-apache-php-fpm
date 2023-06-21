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
COPY apache2/mpm_event.conf /etc/apache2/mods-available/mpm_event.conf
RUN a2enmod proxy_fcgi
RUN a2enconf php-fpm
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
COPY supervisor/apache2.conf /etc/supervisor/conf.d/apache2.conf
COPY php/xx-info.php /opt/drupal/web/xx-info.php

# Environment variables that can be overridden at run time
ENV APACHE_mpm_event_start_servers=2 \
    APACHE_mpm_event_min_spare_threads=25 \
    APACHE_mpm_event_max_spare_threads=75 \
    APACHE_mpm_event_thread_limit=64 \
    APACHE_mpm_event_threads_per_child=25 \
    APACHE_mpm_event_max_request_workers=150 \
    APACHE_mpm_event_max_connections_per_child=0 \
    \
    PHP_fpm_pm=dynamic \
    PHP_fpm_pm_max_children=5 \
    PHP_fpm_pm_start_servers=2 \
    PHP_fpm_pm_min_spare_servers=1 \
    PHP_fpm_pm_max_spare_servers=3 \
    PHP_fpm_pm_process_idle_timeout=10s \
    PHP_fpm_pm_max_requests=0 \
    PHP_fpm_request_slowlog_timeout=0

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
