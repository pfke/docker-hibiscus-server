FROM alpine:3.7

# Enable this during development.
#RUN echo 'Acquire::http { Proxy "http://192.168.59.103:3142"; };' >> /etc/apt/apt.conf.d/01proxy

RUN apk update && apk upgrade
RUN apk add --no-cache bash
RUN apk add --no-cache openjdk8-jre-base
RUN apk add --no-cache postgresql-client

RUN apk add --no-cache wget unzip
RUN wget http://www.willuhn.de/products/hibiscus-server/releases/hibiscus-server-2.8.0.zip
RUN unzip hibiscus-server-*.zip -d / && rm hibiscus-server-*.zip

ADD wrap.sh /wrap/
ENTRYPOINT ["bash", "/wrap/wrap.sh"]

EXPOSE 8080
