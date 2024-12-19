# Utiliser l'image Nginx alpine comme base
FROM nginx:1.21.3-alpine

# Installer les dépendances pour ModSecurity
RUN apk add --no-cache \
    libmodsecurity \
    nginx-mod-http-modsecurity \
    && rm -rf /var/cache/apk/*

# Copier les fichiers de configuration ModSecurity
COPY modsec_rules/ /etc/nginx/modsec_rules/
COPY modsecurity.conf /etc/nginx/modsecurity.conf

# Configurer ModSecurity
RUN echo "modsecurity on;" >> /etc/nginx/nginx.conf \
    && echo "modsecurity_rules_file /etc/nginx/modsecurity.conf;" >> /etc/nginx/nginx.conf
