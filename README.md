Requirements:
- http://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/

Run:
- RabbitMQ: docker run -d -e RABBITMQ_NODENAME=rabbitmq --name rabbitmq -p 15672:15672 -p 5672:5672 rabbitmq:3-management
- Webserver: docker run -it --rm -p 5000:5000 -v //c/Users/neonew/Documents/Programmieren/csgo-skinscreenshot/config.py:/usr/src/app/config.py:ro -v //c/Users/neonew/Documents/Programmieren/csgo-skinscreenshot/screenshots:/usr/src/app/screenshots --link rabbitmq:rabbitmq csgo-skinscreenshot-webserver
- CS:GO Server: docker run -it --rm -p 27015:27015/udp csgo-server-with-changeskin -ip 0.0.0.0 -console -usercon -insecure +game_type 0 +game_mode 1 +map de_vertigo
- Start CS:GO, connect to server
- Make sure "fullscreen windowed" mode is enabled
- CS:GO console is enabled. Console key is F9.
- cl_drawhud 0
- python csgo-skinscreenshot.py
