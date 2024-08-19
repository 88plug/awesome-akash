FROM ubuntu:22.04
RUN apt-get update ; apt-get dist-upgrade -yqq ; apt-get install -y git wget unzip
#RUN wget https://github.com/NeoxaChain/Neoxa/releases/download/v1.0.3/neoxad-linux64.zip
RUN wget https://github.com/NeoxaChain/Neoxa/releases/download/v5.1.1.4/neoxad-5.1.1.4-linux64.zip

RUN unzip neoxad-5.1.1.4-linux64.zip ; rm neoxad-5.1.1.4-linux64.zip
RUN pwd ; ls -la
RUN mkdir -p /root/.neoxa
RUN chmod +x neoxad neoxa-cli
EXPOSE 9766

COPY blocknotify /root/.neoxa/blocknotify

COPY starter.sh /

ENV PRIVATE_KEY=

ENTRYPOINT ["./starter.sh"]
