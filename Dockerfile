# Utiliser l'image Nginx alpine comme base
# FROM nginx:1.21.3-alpine3.15
FROM nginx:1.27.3-alpine3.20-perl

# Installer les dépendances nécessaires pour compiler ModSecurity
RUN apk add --no-cache \
    gcc \
    g++ \
    make \
    libtool \
    automake \
    curl \
    bash \
    pcre-dev \
    zlib-dev \
    libxml2-dev \
    libxslt-dev \
    git \
    linux-headers \
    && rm -rf /var/cache/apk/*
    # Télécharger et compiler ModSecurity
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity.git /tmp/ModSecurity \
    && cd /tmp/ModSecurity \
    && git submodule init \
    && git submodule update \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && rm -rf /tmp/ModSecurity
    # Télécharger et compiler le module Nginx pour ModSecurity
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /tmp/ModSecurity-nginx \
    && cd /tmp/ModSecurity-nginx \
    && git submodule init \
    && git submodule update \
    && cp -r /tmp/ModSecurity-nginx/modsecurity.conf-recommended /etc/nginx/modsec_includes \
    && cd /tmp/ModSecurity-nginx \
    && make \
    && make install \
    && cd / \
    && rm -rf /tmp/ModSecurity-nginx

# Copier les fichiers de configuration ModSecurity
COPY modsec_rules/ /etc/nginx/modsec_rules/
COPY modsecurity.conf /etc/nginx/modsecurity.conf

# Configurer ModSecurity
RUN echo "modsecurity on;" >> /etc/nginx/nginx.conf \
    && echo "modsecurity_rules_file /etc/nginx/modsecurity.conf;" >> /etc/nginx/nginx.conf
# Exposer les ports Nginx
EXPOSE 80 443

# Lancer Nginx en mode avant-plan
CMD ["nginx", "-g", "daemon off;"]