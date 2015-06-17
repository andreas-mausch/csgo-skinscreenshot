import csgo
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
	filename = csgo.screenshotFilename(weaponString, "playside")
	print(filename)
	return send_from_directory(".", filename)

if __name__ == '__main__':
	app.run(debug=True)
