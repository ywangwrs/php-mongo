FROM php:8.3.14-apache

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
    libssl-dev \
    wget \
    vim \
    ffmpeg \
    unzip \
    python3-pip \
    mutt gpgsm gnupg-agent \
 && DEBIAN_FRONTEND=noninteractive apt-get --yes --assume-yes install cyrus-common \
 && apt-get clean

# Install mysql and mongodb
# Reference: https://github.com/dwinurhadia/docker-apache-php-mysql-mongo/blob/main/docker/php/Dockerfile
RUN docker-php-ext-install pdo pdo_mysql mysqli \
 && apt-get install -y autoconf pkg-config libssl-dev \
 && pecl install mongodb \
 && echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

# Python3, google-api-python-client and pyshorteners
RUN rm /usr/lib/python3.11/EXTERNALLY-MANAGED \
 && pip3 install \
    google-api-python-client \
    google_auth_oauthlib \
    pyshorteners \
    pymongo \
    pandas

# youtube-dl
RUN wget https://github.com/yt-dlp/yt-dlp/releases/download/2024.11.18/yt-dlp_linux -O /usr/bin/youtube-dl \
 && chmod 755 /usr/bin/youtube-dl

RUN mkdir /var/www/.mutt \
 && chmod 777 /var/log

COPY colors /var/www/.mutt/
COPY .muttrc /var/www/
COPY .htaccess /var/www/html/
RUN chown -R www-data:www-data /var/www/.mutt /var/www/.muttrc

WORKDIR /var/www/html

COPY index.php .

RUN mkdir -p /data/src /data/discuz /data/share \
    && ln -s /data/src/forum . \
    && ln -s /data/src/ottawa . \
    && ln -s /data/discuz . \
    && ln -s /data/discuz upload \
    && ln -s /data/share .
