FROM debian:buster-slim

RUN apt-get update && \
    apt-get -y --no-install-recommends install apache2 openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN a2enmod headers proxy proxy_fcgi rewrite ssl
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

ARG MAGENTO_DOMAIN
COPY --from=paulczar/omgwtfssl /usr/local/bin/generate-certs /usr/local/bin/generate-certs
RUN mkdir -p /certs && \
    cd /certs && \
    SILENT="true" CA_EXPIRE="365" CA_SUBJECT="None" SSL_EXPIRE="365" SSL_SUBJECT=$MAGENTO_DOMAIN generate-certs

ARG MAGENTO_USER
RUN useradd -m -s /bin/bash -u 1000 $MAGENTO_USER && \
    chown $MAGENTO_USER:$MAGENTO_USER -R /var/www && \
    sed -i -e "s/www-data/$MAGENTO_USER/g" /etc/apache2/envvars

EXPOSE 80 443
VOLUME /var/www/html
WORKDIR /var/www/html

CMD ["apache2ctl", "-DFOREGROUND"]
