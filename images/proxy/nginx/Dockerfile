FROM nginx:1.19

COPY ./default.conf /etc/nginx/conf.d/default.conf

ARG MAGENTO_DOMAIN
COPY --from=paulczar/omgwtfssl /usr/local/bin/generate-certs /usr/local/bin/generate-certs
RUN mkdir -p /certs && \
    cd /certs && \
    SILENT="true" CA_EXPIRE="365" CA_SUBJECT="None" SSL_EXPIRE="365" SSL_SUBJECT=$MAGENTO_DOMAIN generate-certs

ARG MAGENTO_USER
RUN useradd -m -s /bin/bash -u 1000 $MAGENTO_USER && \
    mkdir -p /var/www/html && \
    chown $MAGENTO_USER:$MAGENTO_USER -R /var/www && \
    sed -i -e "s/^user .*/user $MAGENTO_USER;/g" /etc/nginx/nginx.conf

EXPOSE 443
VOLUME /var/www/html
WORKDIR /var/www/html
