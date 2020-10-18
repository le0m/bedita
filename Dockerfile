FROM chialab/php:5.6-apache
MAINTAINER dev@chialab.it

# Install MySQL client, to wait for DB on startup
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y mysql-client

# Install PHP gettext extension
RUN install-php-extensions gettext

# Create Apache virtual host
COPY docker/apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN sed -i -e 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf

# Copy BEdita
COPY . /var/www/bedita

# Set file permissions
RUN chown -R www-data:www-data /var/www/bedita \
    && chmod -R 777 /var/www/bedita/bedita-app/tmp \
    && chmod -R 777 /var/www/bedita/bedita-app/webroot/files

# Copy entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Configure healthcheck
#HEALTHCHECK --interval=30s --timeout=3s --start-period=1m \
#    CMD curl -f http://localhost/status || exit 1

# Setup user and workdir, expose port and volume
USER www-data:www-data
WORKDIR /var/www/bedita
EXPOSE 8080
VOLUME ["/var/www/bedita/bedita-app/webroot/files"]

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
