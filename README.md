# Running Drupal in an apache + php-fpm container

_in the spirit of fooling around and finding out_.

Here, we'll build a container image that will run Drupal via Apache and PHP-FPM running inside the same container.

Because we're running 2x processes in the container (apache2 and php-fpm), we need something to run as PID 1 (first process) which will manage those processes and respond to POSIX SIGNALs (see: https://dsa.cs.tsinghua.edu.cn/oj/static/unix_signal.html). The simplest way to do this is have `supervisor` run as PID 1 and let it manage the starting, stopping and restarting of the apache and php-fpm processes.

See: http://supervisord.org for more info.

For this use case, we won't restart either php-fpm or apache upon failure. Instead, we will rely on a container orchestrator to restart the container based on a health-check call to `/xx-fpm.ping` which will fail if either apache or php-fpm fail.

View the Dockerfile / config files for more details. We'll be using an official Drupal container image (`drupal:10.0.9-php8.2-fpm-bullseye` at the time of writing) as our base image.

## To build

Example using the version at time of writing:

```
docker build -t customdrupal:10.0.9-php8.2-apache-fpm-bullseye .
```

## To run

```
docker run --rm --name drupal -p 8080:80 customdrupal:10.0.9-php8.2-apache-fpm-bullseye
```

## Test

- Open http://localhost:8080/xx-info.php (php info)
- Open http://localhost:8080/xx-fpm.ping (fpm health-check)
- Open http://localhost:8080/xx-fpm.status (fpm status)
- Open http://localhost:8080/ (drupal site install)
