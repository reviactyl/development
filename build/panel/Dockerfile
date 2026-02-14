FROM debian:12-slim

LABEL maintainer="148823476+GunnableScum@users.noreply.github.com" \
	  description="Local development environment for Reviactyl Panel." \
	  org.opencontainers.image.source=https://github.com/reviactyl/development

ARG TARGETARCHI
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG PHP_VERSION=8.2

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PHP_VERSION=$PHP_VERSION \
    PHP=php$PHP_VERSION

USER root
RUN apt -y update \
    && apt -y --no-install-recommends install ca-certificates apt-transport-https software-properties-common \
      gnupg2 curl sudo locales nginx unzip git supervisor cron default-mysql-client  \
      iproute2 iputils-ping tar nano \
    && curl -sL https://deb.nodesource.com/setup_22.x | bash - \
    && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/sury-keyring.gpg] https://packages.sury.org/php/ bookworm main" | tee /etc/apt/sources.list.d/sury-php.list \
	&& apt -y update \
    && apt -y --no-install-recommends install nodejs \
      php8.2 \
	  php8.2-cli \
	  php8.2-common \
	  php8.2-gd \
	  php8.2-mysql \
	  php8.2-mbstring \
	  php8.2-bcmath \
	  php8.2-xml \
	  php8.2-fpm \
	  php8.2-curl \
	  php8.2-zip \
	  php8.2-xdebug \
	&& apt autoremove -y \
    && apt clean \
	&& rm -rf /var/cache/apt/archives /var/cache/debconf /var/lib/apt/lists

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && npm i -g pnpm \
    && rm -rf /etc/nginx/sites-enabled/* \
    && mkdir -p /var/run/php \
    && mkdir -p /var/www/html \
    && sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/$PHP_VERSION/fpm/php-fpm.conf \
    && useradd -m reviactyl \
    && usermod -a -g www-data -G sudo reviactyl \
    && echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/sudoers \
    && phpdismod xdebug \
    && rm -rf /tmp/*

COPY ./build/panel/php/99-pool.conf /etc/php/$PHP_VERSION/fpm/pool.d/99-pool.conf
COPY ./build/panel/php/99-reviactyl.ini /etc/php/$PHP_VERSION/shared.d/99-reviactyl.ini
COPY ./build/panel/configs/reviactyl.conf /etc/nginx/sites-available/reviactyl.conf

RUN (crontab -l 2>/dev/null; echo "* * * * * php /var/www/html/artisan schedule:run >> /dev/null 2>&1") | crontab - \
    && ln -s /etc/nginx/sites-available/reviactyl.conf /etc/nginx/sites-enabled/ \
    && ln -s /etc/php/$PHP_VERSION/shared.d/99-reviactyl.ini /etc/php/$PHP_VERSION/fpm/99-reviactyl.ini \
    && ln -s /etc/php/$PHP_VERSION/shared.d/99-reviactyl.ini /etc/php/$PHP_VERSION/cli/99-reviactyl.ini \
    && mv /etc/php/$PHP_VERSION/fpm/pool.d/www.conf /etc/php/$PHP_VERSION/fpm/pool.d/10-www.conf

COPY ./build/panel/configs/supervisor /etc/supervisor
COPY --chmod=700 ./build/panel/scripts/* /usr/local/bin

EXPOSE 80 8080
WORKDIR /var/www/html
ENTRYPOINT ["entrypoint"]
