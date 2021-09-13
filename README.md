# Sourcemod plugin

The Sourcemod plugin will let you change your skin to any custom paint, float and seed.
It also lets you teleport to any point in the map.

Examples (type into game console):

```
# Arguments are: sm_changeskin weapon paint wear stattrak quality seed
sm_changeskin weapon_usp_silencer 415 0.0 0 0 0
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
docker build --file=csgo-server/Dockerfile --progress=plain --tag csgo-server-with-changeskin .
```

To start a CS:GO server:

```bash
docker run -it --rm -p 27015:27015/udp csgo-server-with-changeskin -ip 0.0.0.0 -console -usercon -insecure +game_type 0 +game_mode 1 +map de_vertigo
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

# Links

- https://www.unknowncheats.me/wiki/Counter_Strike_Global_Offensive:Skin_Changer
- https://forums.alliedmods.net/showthread.php?t=261263
- https://github.com/quasemago/CSGO_WeaponStickers/blob/master/addons/sourcemod/scripting/csgo_weaponstickers.sp
