FROM ubuntu:20.04
LABEL maintainer="Danny Tsang <danny@tsang.uk>" \
      application="ttrss"

# Set timezone
ENV TZ="Europe/London"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## Environment variables ##
# PHP version used in file paths
ENV PHP_VERSION 7.4
# nginx web root directory
ENV WWW_ROOT /usr/share/nginx/html

# Update and upgrade distro
RUN DEBIAN_FRONTEND=noninteractive apt update && apt install \
  nginx \
  ssl-cert \
  php$PHP_VERSION \
  php$PHP_VERSION-fpm \
  php$PHP_VERSION-curl \
  php$PHP_VERSION-mysql \
  php$PHP_VERSION-gd \
  php$PHP_VERSION-cli \
  php$PHP_VERSION-json \
  php$PHP_VERSION-mbstring \
  php$PHP_VERSION-xml \
  php$PHP_VERSION-intl \
  supervisor \
  ntp \
  wget \
  unzip \
  git \
  -q -y && \
# Remove cache after install
  rm -rf /var/lib/apt/lists/*

# Add supervisord config to image
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    rm -f /etc/nginx/sites-available/default
COPY nginx/default /etc/nginx/sites-available/default

# PHP-FPM config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/$PHP_VERSION/fpm/php.ini && \
  sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10M/g" /etc/php/$PHP_VERSION/fpm/php.ini && \
  sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10M/g" /etc/php/$PHP_VERSION/fpm/php.ini && \
  sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/$PHP_VERSION/fpm/php-fpm.conf && \
  sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/$PHP_VERSION/fpm/pool.d/www.conf && \
  find /etc/php/$PHP_VERSION/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# Run PHP FPM to create necessary directories / files such as '/run/php/php$PHP_VERSION-fpm.sock'
RUN service php$PHP_VERSION-fpm start

# Copy TTRSS files
RUN rm $WWW_ROOT/*.*
RUN git clone https://git.tt-rss.org/fox/tt-rss.git $WWW_ROOT/ && \
    mv $WWW_ROOT/config.php-dist $WWW_ROOT/config.php

#QR code generator
RUN git clone https://github.com/jonrandoem/ttrss-qrcode.git && \
    mv ttrss-qrcode $WWW_ROOT/plugins/qrcodegen

# Add startup script and give it permission to execute
COPY docker/start.sh /startup.sh
RUN chown -R www-data:www-data $WWW_ROOT && chmod -R 775 $WWW_ROOT && chmod +x /startup.sh

# Expose port required
EXPOSE 80 443

## Create Volumes ##
VOLUME ["/config", "/usr/share/nginx/html", "/usr/share/nginx/html/feed-icons", "/usr/share/nginx/html/plugins"]

# Execute the apache daemon in the foreground so we can treat the container as an
# executeable and it wont immediately return.
CMD ["/startup.sh"]
