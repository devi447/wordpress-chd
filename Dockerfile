# Base image: PHP 8.2 with Apache
FROM php:8.2-apache

# Install required PHP extensions for WordPress
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev \
    mariadb-client unzip git vim \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip mysqli pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module (needed for WordPress permalinks)
RUN a2enmod rewrite

# Set Apache ServerName to suppress warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy all WordPress files except wp-config.php
COPY . /var/www/html/
RUN rm -f /var/www/html/wp-config.php

# Create uploads directory and set ownership
RUN mkdir -p /var/www/html/wp-content/uploads \
    && chown -R www-data:www-data /var/www/html/wp-content/uploads

# Set ownership for all WordPress files
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 777 /var/www/html/wp-content/uploads

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
