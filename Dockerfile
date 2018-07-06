FROM alpine:3.7

ENV LANG=de_DE.UTF-8 \ 
    LANGUAGE=de_DE.UTF-8 \
    LC_CTYPE=de_DE.UTF-8 \
    LC_ALL=de_DE.UTF-8
RUN apk update && apk upgrade

RUN apk add --no-cache bash openjdk8 mariadb-client wget unzip
RUN ln -fs /usr/share/zoneinfo/GMT /etc/localtime

RUN wget -nv http://www.willuhn.de/products/hibiscus-server/releases/hibiscus-server-2.8.0.zip
RUN unzip hibiscus-server-*.zip -d / && rm hibiscus-server-*.zip
RUN mkdir /hibiscus-data

ADD wrap.sh /wrap/
ENTRYPOINT ["bash", "/wrap/wrap.sh"]

EXPOSE 8080
