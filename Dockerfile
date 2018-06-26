FROM ubuntu:16.04

# Enable this during development.
#RUN echo 'Acquire::http { Proxy "http://192.168.59.103:3142"; };' >> /etc/apt/apt.conf.d/01proxy

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install default-jre
RUN apt-get -y install postgresql-client
RUN apt-get -y install mariadb-client

RUN apt-get -y install wget unzip
RUN wget http://www.willuhn.de/products/hibiscus-server/releases/hibiscus-server-2.8.0.zip
RUN unzip hibiscus-server-*.zip -d / && rm hibiscus-server-*.zip

ADD wrap.sh /wrap/
ENTRYPOINT ["bash", "/wrap/wrap.sh"]

EXPOSE 8080
