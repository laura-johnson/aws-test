#!/bin/bash
#
# Artifact generator using a local Docker image.
#
# This script should be run from within the BLT project directory root. If it is
# run elsewhere, the project_dir should be updated accordingly.

name="artifactory"
project_dir="."

# Remove any existing "deploy/" directory.
printf "Removing any previously-existing deployment artifacts.\n"
rm -rf $project_dir/deploy/

# Start the build container.
printf "Starting the build container.\n"
docker run -d --name $name -v `pwd`/$project_dir:/deploy php:7.2-cli-stretch tail -f /dev/null

# Install dependencies.
docker exec $name bash -c "apt-get update && apt-get install -y gnupg unzip git libpng-dev libbz2-dev libmcrypt-dev"
docker exec $name bash -c "pecl install mcrypt-1.0.1 && docker-php-ext-enable mcrypt"
docker exec $name bash -c "docker-php-ext-install gd \
  && docker-php-ext-install bz2"

# Install Composer.
docker exec $name bash -c "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\" \
  && php composer-setup.php \
  && mv composer.phar /usr/local/bin/composer"

# Install dependencies.
docker exec $name bash -c "cd deploy && composer install"

# Destroy the build container.
docker rm -f $name