# Utiliser l'image Nginx alpine comme base
# FROM nginx:1.21.3-alpine3.15
# Étape 1 : Construire libmodsecurity
FROM debian:bullseye as builder

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libtool \
    autoconf \
    automake \
    pkg-config \
    git \
    wget \
    cmake \
    libpcre3-dev \
    libxml2-dev \
    libyajl-dev \
    curl \
    libcurl4-openssl-dev \
    && apt-get clean

# Cloner le dépôt ModSecurity
RUN git clone --recursive https://github.com/SpiderLabs/ModSecurity /tmp/ModSecurity

# Compiler libmodsecurity
WORKDIR /tmp/ModSecurity
RUN ./build.sh && ./configure && make && make install

FROM nginx:1.27.3-alpine3.20-perl

# Installer les dépendances nécessaires pour compiler ModSecurity
RUN apk add --no-cache \
    gcc \
    libc-dev \
    make \
    pcre-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    curl-dev \
    yajl-dev \
    git \
    bash \
    && rm -rf /var/cache/apk/*
# Copier libmodsecurity depuis le builder
COPY --from=builder /usr/local/modsecurity /usr/local/modsecurity

# Cloner le connecteur ModSecurity pour Nginx
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /tmp/ModSecurity-nginx

# Compiler Nginx avec le connecteur
RUN cd /tmp/ModSecurity-nginx && \
    ./configure --with-compat --add-module=/tmp/ModSecurity-nginx && \
    make && make install

# Configurer ModSecurity
COPY modsecurity.conf /etc/nginx/modsecurity.conf
COPY modsec_rules/ /etc/nginx/modsec_rules/

# Configurer Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Exposer les ports HTTP/HTTPS
EXPOSE 80 443