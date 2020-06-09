FROM mvilchis/laravel-base:v1.0

USER root

# Copy existing application directory contents
COPY ./project/ /var/www

# Copy existing application directory permissions
COPY --chown=www:www ./project /var/www

RUN chmod -R 777 /var/www/

# Install dependencies
RUN php artisan config:cache

USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
