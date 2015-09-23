# vim:set ft=dockerfile:
FROM phusion/baseimage
MAINTAINER Tom Coonen <tom@creacoon.nl>

CMD ["/sbin/my_init"]

WORKDIR /tmp

# Install Nginx
RUN apt-get update && apt-get install -y python-software-properties
RUN add-apt-repository ppa:nginx/stable
RUN apt-get update && apt-get install -y nginx

# Apply Nginx configuration
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/laravel /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel && \
    rm /etc/nginx/sites-enabled/default

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# RUN mkdir -p /etc/service/nginx
# ADD start.sh /etc/service/nginx/run
# RUN chmod +x /etc/service/nginx/run

# Nginx startup script
ADD config/nginx-start.sh /opt/bin/nginx-start.sh
RUN chmod u=rwx /opt/bin/nginx-start.sh

RUN mkdir -p /data
VOLUME ["/data"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PORTS
EXPOSE 80
EXPOSE 443

WORKDIR /opt/bin
ENTRYPOINT ["/opt/bin/nginx-start.sh"]