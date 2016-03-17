FROM phusion/baseimage
MAINTAINER Li Fei "lifei.vip@outlook.com"
RUN sed -i 's/archive\.ubuntu\.com/mirrors.aliyun.com/' /etc/apt/sources.list && \
    sed -i 's/deb-src/# deb-src/' /etc/apt/sources.list && \
    apt-get update && apt-get upgrade -y && apt-get clean

RUN apt-get install -y build-essential curl

# ffmpeg
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:mc3man/trusty-media
RUN apt-get update
RUN apt-get install -y ffmpeg

# nginx dependencies
RUN apt-get install -y libpcre3-dev zlib1g-dev libssl-dev

ENV RTMP_VERSION 1.1.7
ENV RTMP_URL https://github.com/arut/nginx-rtmp-module/archive/v${RTMP_VERSION}.tar.gz
ENV NGINX_VERSION 1.9.12
ENV NGINX_URL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

RUN curl -fSL ${RTMP_URL} | tar zx -C /tmp
RUN curl -fSL ${NGINX_URL} | tar zx -C /tmp

# compile nginx
RUN cd /tmp/nginx-${NGINX_VERSION} && \
    ./configure --add-module=/tmp/nginx-rtmp-module-${RTMP_VERSION} && \
    make && make install

RUN rm -rf /etc/service/sshd /etc/service/cron \
    /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN apt-get purge -y cron openssh-server openssh-client && apt-get clean

ADD nginx.conf /usr/local/nginx/conf/nginx.conf
ADD stat.xls /usr/local/nginx/html/stat.xls
ADD nginx_run /etc/service/nginx/run
RUN chmod a+x /etc/service/nginx/run
RUN mkdir -p /data/hls
