import config
import csgo
import messagequeue
import os
from flask import Flask, request, send_from_directory

app = Flask(__name__)

@app.route('/<weapon>')
def index(weapon=None):
	paint = request.args.get("paint")
	float = request.args.get("float")
	stattrak = -1
	quality = 2
	seed = request.args.get("seed")
	view = request.args.get("view")

	weaponString = weapon + " " + paint + " " + float + " " + str(stattrak) + " " + str(quality) + " " + seed
	filename = csgo.screenshotFilename(weaponString, view)
	if not os.path.isfile(filename):
		connection = messagequeue.open(config.messagequeueHost)
		channel = messagequeue.channel(connection, config.messagequeueName)
		messagequeue.send(channel, config.messagequeueName, weaponString)
		connection.close()
		return "queued"
	else:
		return send_from_directory(".", filename)

if __name__ == '__main__':
	app.run(host="0.0.0.0", debug=True)
