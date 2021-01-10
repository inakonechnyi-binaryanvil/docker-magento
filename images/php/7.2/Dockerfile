FROM php:7.2-fpm

RUN apt-get update && \
# ----------------------------- UTILITIES ----------------------------- #
    apt-get -y install bash-completion git vim curl zip \
# -------------------------- PHP EXTENSIONS --------------------------- #
                       libfreetype6-dev libjpeg62-turbo-dev libpng-dev libsodium-dev libxslt-dev libzip-dev && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install -j$(nproc) gd bcmath intl sodium xsl pdo_mysql soap zip sockets opcache && \
    pecl install xdebug-2.9.8 && \
# ------------------------------ CLEAN UP ----------------------------- #
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------- IONCUBE ----------------------------- #
RUN IONCUBE_LOADERS="ioncube_loaders_lin_`uname -m | tr _ -`.tar.gz" && \
    curl -OJL https://downloads.ioncube.com/loader_downloads/${IONCUBE_LOADERS} --silent && \
    tar -xzf ${IONCUBE_LOADERS} && \
    rm ${IONCUBE_LOADERS} && \
    mv "./ioncube/ioncube_loader_lin_`php-config --version | cut -d. -f1-2`.so" "`php-config --extension-dir`/ioncube.so" && \
    rm -rf ./ioncube && \
    docker-php-ext-enable ioncube

# ------------------------------ COMPOSER ----------------------------- #
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer

# ----------------------------- N98 MAGERUN --------------------------- #
RUN curl -JL https://files.magerun.net/n98-magerun2.phar -o /usr/local/bin/n98-magerun2 --silent && \
    curl -JL https://raw.githubusercontent.com/netz98/n98-magerun2/master/res/autocompletion/bash/n98-magerun2.phar.bash -o /etc/bash_completion.d/n98-magerun2 --silent && \
    chmod +x /usr/local/bin/n98-magerun2

# ----------------------------- PHP SETTINGS -------------------------- #
ARG MAGENTO_DEVELOPER_MODE
ARG MAGENTO_PHP_MEMORY_LIMIT
RUN if [ "$MAGENTO_DEVELOPER_MODE" = "0" ]; then \
        mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini; \
        rm $PHP_INI_DIR/php.ini-development; \
    else \
        mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini; \
        rm $PHP_INI_DIR/php.ini-production; \
    fi && \
    sed -i -e "s/memory_limit =.*/memory_limit = ${MAGENTO_PHP_MEMORY_LIMIT}/g" $PHP_INI_DIR/php.ini

# ------------------------------ USER SETUP --------------------------- #
ARG MAGENTO_USER
RUN useradd -m -s /bin/bash -u 1000 $MAGENTO_USER && \
    chown $MAGENTO_USER:$MAGENTO_USER -R /var/www && \
    sed -i -e "s/www-data/$MAGENTO_USER/g" /usr/local/etc/php-fpm.d/www.conf
USER $MAGENTO_USER
