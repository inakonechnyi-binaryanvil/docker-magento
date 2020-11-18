FROM nginx:1.19

COPY ./default.conf /etc/nginx/conf.d/default.conf

ARG MAGENTO_DOMAIN
COPY --from=paulczar/omgwtfssl /usr/local/bin/generate-certs /usr/local/bin/generate-certs
RUN mkdir -p /certs && \
    cd /certs && \
    SILENT="true" CA_EXPIRE="365" CA_SUBJECT="None" SSL_EXPIRE="365" SSL_SUBJECT=$MAGENTO_DOMAIN generate-certs

EXPOSE 443
VOLUME /var/www/html
WORKDIR /var/www/html
