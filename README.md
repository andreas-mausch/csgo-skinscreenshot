![PlantUML sequence diagram](https://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/andreas-mausch/csgo-skinscreenshot/master/sequence.plantuml)

# Sourcemod plugin

The Sourcemod plugin will let you change your skin to any custom paint, float and seed.
It also lets you teleport to any point in the map.

Note: float and wear is the same.

## Stattrak values

The value can either be the amount of kills or -1 for non-stattrak weapons.

## Quality values

The field can have the following values:

- 0: Normal
- 1: Genuine
- 2: Vintage
- 3: Unusual
- 4: Unique
- 5: Community
- 6: Developer
- 7: Self-Made
- 8: Customized
- 9: Strange
- 10: Completed
- 11: Haunted
- 12: Tournament

> Defines the quality of this weapon. Qualities 4 and 11 are the same as 0.  
> Knives always use quality 3 which makes the "★" appear.

Examples (type into game console):

```
# Arguments are: sm_changeskin weapon paint wear stattrak quality seed
sm_changeskin weapon_usp_silencer 415 0.0 -1 0 0
# Arguments are: sm_teleport (x, y, z) (viewangle x, y, z)
sm_teleport -1548 -339 195 0 104 0
```

# CS:GO Server (with Sourcemod plugin)

**WARNING**: This server sets FollowCSGOServerGuidelines to *No*.
Only run this if you know what you are doing.

> Per http://blog.counter-strike.net/index.php/server_guidelines/, certain plugin  
> functionality will trigger all of the game server owner's Game Server Login Tokens (GSLTs)  
> to get banned when executed on a Counter-Strike: Global Offensive game server.

The docker image will run a custom CS:GO server at port 27015 UDP (the default).
The Sourcemod plugin will be copied and compiled as part of the `docker build`.

To build the image, run this:

```bash
docker build --progress=plain --tag csgo-server-with-changeskin ./server/
```

To start a CS:GO server:

```bash
docker run -it --rm -p 27015:27015/udp -p 27015:27015/tcp csgo-server-with-changeskin -ip 0.0.0.0 -console -usercon -insecure +game_type 0 +game_mode 1 +map de_vertigo
```

Get a shell:

```bash
docker run -it --rm --entrypoint bash csgo-server-with-changeskin
```

# CS:GO Client

In order to connect to the server, do this:

- Set video mode to *Fullscreen Windowed*
- Enable Developer Console
- Set console key to *F9*
- For better screenshots, set *cl_drawhud 0*

Now, connect to the server (replace IP with your server IP):

```
password 123456; connect 192.168.178.49
```

# RabbitMQ

The web frontend will produce messages, which screenshots are to be taken next.

The Python script on client site will consume those messages and take screenshots to the file system.

```bash
docker run -it --rm -e RABBITMQ_NODENAME=rabbitmq --name rabbitmq -p 15672:15672 -p 5672:5672 rabbitmq:3-management
```

# Web Frontend

```bash
docker build --file=./client/frontend/Dockerfile --tag csgo-skinscreenshot-webfrontend ./client/
docker run -it --rm -p 5000:5000 csgo-skinscreenshot-webfrontend
```

# Client-side scripts

These scripts are meant to be executed on the same machine the CS:GO Windows client runs.

```
cd ./client/csgo/
python csgo-skinscreenshot.py
```

# Links

- Schema: https://raw.githubusercontent.com/SteamDatabase/SteamTracking/b5cba7a22ab899d6d423380cff21cec707b7c947/ItemSchema/CounterStrikeGlobalOffensive.json
- List of paint kits: https://raw.githubusercontent.com/SteamDatabase/GameTracking-CSGO/master/csgo/scripts/items/items_game.txt
- https://www.unknowncheats.me/wiki/Counter_Strike_Global_Offensive:Skin_Changer
- https://forums.alliedmods.net/showthread.php?t=261263
- https://github.com/quasemago/CSGO_WeaponStickers/blob/master/addons/sourcemod/scripting/csgo_weaponstickers.sp
