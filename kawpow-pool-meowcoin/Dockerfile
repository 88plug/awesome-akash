FROM ubuntu:24.04
RUN apt-get update ; apt-get dist-upgrade -yqq ; apt-get install -y git wget unzip
RUN wget https://github.com/JustAResearcher/Meowcoin/releases/download/Meow-v2.0.4/meowcoin-2.0.4-1733b19cc-x86_64-linux-gnu.tar.gz
RUN tar -zxvf meowcoin-2.0.4-1733b19cc-x86_64-linux-gnu.tar.gz
RUN mv /meowcoin-2.0.4-1733b19cc/bin/* /
RUN mkdir -p /root/.meowcoin

EXPOSE 9766

ENV PRIVATE_KEY=

COPY blocknotify /root/.meowcoin/blocknotify
COPY starter.sh /

ENTRYPOINT ["./starter.sh"]
