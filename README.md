Requirements:
- pip install Pillow
- pip install python3-pika
- pip install Flask
- http://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/
- CS:GO must be running and connected to a server with the sourcemod plugin sm_changeskin installed
- CS:GO console is enabled. Console key is F9.

Start:
- machine 1: start rabbitmq
- machine 1: start dedicated server with de_vertigo
- machine 2: python webservice.py
- machine 2: start csgo, connect to machine 1
- machine 2: cl_drawhud 0
- machine 2: python csgo-skinscreenshot.py
