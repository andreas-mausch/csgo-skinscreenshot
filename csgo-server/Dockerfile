FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -yq curl wget lib32gcc1 lib32stdc++6 && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Steam
RUN mkdir -p /opt/steamcmd && \
    cd /opt/steamcmd && \
    curl --silent http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -vxz

# CS:GO
RUN mkdir /opt/csgo && \
    cd /opt/steamcmd && \
    ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ../csgo \
        +app_update 740 validate \
        +quit

# Metamod and Sourcemod
RUN wget --quiet -P /opt/ https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1145-linux.tar.gz && \
    tar xf /opt/mmsource-*-linux.tar.gz -C /opt/csgo/csgo && \
    rm /opt/mmsource-*-linux.tar.gz && \
    wget --quiet -P /opt/ https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6510-linux.tar.gz && \
    tar xf /opt/sourcemod-*-linux.tar.gz -C /opt/csgo/csgo && \
    rm /opt/sourcemod-*-linux.tar.gz

# Change skin plugin
ADD sm_changeskin.sp /opt/csgo/csgo/addons/sourcemod/scripting/
RUN /opt/csgo/csgo/addons/sourcemod/scripting/spcomp /opt/csgo/csgo/addons/sourcemod/scripting/sm_changeskin.sp -o /opt/csgo/csgo/addons/sourcemod/plugins/sm_changeskin.smx

# CS:GO Server config
ADD server.cfg /opt/csgo/csgo/cfg/server.cfg
ADD gamemode_competitive_server.cfg /opt/csgo/csgo/cfg/gamemode_competitive_server.cfg

EXPOSE 27015
WORKDIR /opt/csgo
ENTRYPOINT ["./srcds_run"]
