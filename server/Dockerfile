FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -yq build-essential curl wget unzip lib32gcc1 lib32stdc++6 && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --gid=1001 steam && useradd --uid=1001 --create-home --no-log-init -r --gid steam steam
USER steam
WORKDIR /home/steam/

# Steam
RUN mkdir -p steamcmd && \
    curl --silent http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xz -C steamcmd

# CS:GO
RUN mkdir -p csgo && \
    ./steamcmd/steamcmd.sh \
        +login anonymous \
        +force_install_dir /home/steam/csgo \
        +app_update 740 validate \
        +quit

# CS:GO Server config
COPY server.cfg /home/steam/csgo/csgo/cfg/server.cfg
COPY gamemode_competitive_server.cfg /home/steam/csgo/csgo/cfg/gamemode_competitive_server.cfg

# Metamod and Sourcemod
RUN wget --quiet https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1145-linux.tar.gz && \
    tar xf mmsource-*-linux.tar.gz -C ./csgo/csgo && \
    rm mmsource-*-linux.tar.gz && \
    wget --quiet https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6510-linux.tar.gz && \
    tar xf sourcemod-*-linux.tar.gz -C ./csgo/csgo && \
    rm sourcemod-*-linux.tar.gz

# PTaH Additional CS:GO Hooks and Natives
# https://github.com/komashchenko/PTaH
RUN wget --quiet https://ptah.zizt.ru/files/PTaH-V1.1.3-build20-linux.zip && \
    unzip PTaH-*-linux.zip -d ./csgo/csgo && \
    rm PTaH-*-linux.zip

# Disable FollowCSGOServerGuidelines
RUN sed -i 's/"FollowCSGOServerGuidelines"\t"yes"/"FollowCSGOServerGuidelines"\t"no"/' ./csgo/csgo/addons/sourcemod/configs/core.cfg

# Sourcemod plugins
COPY sourcemod-plugin/*.sp /home/steam/csgo/csgo/addons/sourcemod/scripting/

RUN /home/steam/csgo/csgo/addons/sourcemod/scripting/spcomp /home/steam/csgo/csgo/addons/sourcemod/scripting/sm_changeskin.sp -o /home/steam/csgo/csgo/addons/sourcemod/plugins/sm_changeskin.smx && \
    /home/steam/csgo/csgo/addons/sourcemod/scripting/spcomp /home/steam/csgo/csgo/addons/sourcemod/scripting/sm_sticker.sp -o /home/steam/csgo/csgo/addons/sourcemod/plugins/sm_sticker.smx

EXPOSE 27015
ENTRYPOINT ["./csgo/srcds_run"]
