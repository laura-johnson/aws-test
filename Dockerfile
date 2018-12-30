# Note: Your base image should contain all the PHP extensions required by your project.
FROM php:7.2-apache-stretch

# Set the project machine name here.
ENV PROJECT my-d7-project

# Copy the deployment artifact into place.
COPY . /var/www/$PROJECT

# Copy the Drupal container settings file into place.
COPY docker/settings.container.php /var/www/$PROJECT/docroot/sites/default/settings.container.php

# Set a custom docroot since BLT uses 'docroot'.
ENV APACHE_DOCUMENT_ROOT /var/www/$PROJECT/docroot
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set appropriate permissions on sites/default directory.
RUN chmod 665 /var/www/$PROJECT/docroot/sites/default

# Set appropriate permissions on public files directory.
RUN mkdir -p /var/www/$PROJECT/docroot/sites/default/files \
    && chown www-data:www-data /var/www/$PROJECT/docroot/sites/default/files

WORKDIR /var/www/$PROJECT