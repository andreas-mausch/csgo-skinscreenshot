FROM ubuntu:14.04
MAINTAINER Andreas Mausch <andreas.mausch@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update &&\
    apt-get install -yq curl lib32gcc1 wget &&\
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Steam
RUN mkdir -p /opt/steamcmd &&\
    cd /opt/steamcmd &&\
    curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -vxz

# CS:GO
RUN mkdir /opt/csgo &&\
    cd /opt/steamcmd &&\
    ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ../csgo \
        +app_update 740 validate \
        +quit

# Metamod and Sourcemod
RUN wget --quiet -P /opt/ http://sourcemod.gameconnect.net/files/mmsource-1.10.5-linux.tar.gz &&\
    tar xf /opt/mmsource-1.10.5-linux.tar.gz -C /opt/csgo/csgo &&\
    rm /opt/mmsource-1.10.5-linux.tar.gz &&\
    wget --quiet -P /opt/ http://sourcemod.gameconnect.net/files/sourcemod-1.7.2-linux.tar.gz &&\
    tar xf /opt/sourcemod-1.7.2-linux.tar.gz -C /opt/csgo/csgo &&\
    rm /opt/sourcemod-1.7.2-linux.tar.gz

ADD sm_changeskin.smx /opt/csgo/csgo/addons/sourcemod/plugins/sm_changeskin.smx
ADD server.cfg /opt/csgo/csgo/cfg/server.cfg
ADD gamemode_competitive_server.cfg /opt/csgo/csgo/cfg/gamemode_competitive_server.cfg

EXPOSE 27015
WORKDIR /opt/csgo
ENTRYPOINT ["./srcds_run"]
