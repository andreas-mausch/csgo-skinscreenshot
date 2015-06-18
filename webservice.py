import config
import csgo
import messagequeue
import os
import urllib.request
from flask import Flask, Response, request, send_from_directory, render_template
from flask.ext.api import status

app = Flask(__name__)

@app.route('/<weapon>')
def index(weapon=None):
	paint = request.args.get("paint")
	float = request.args.get("float")
	seed = request.args.get("seed")
	view = request.args.get("view")
	return render_template("csgo-skinscreenshot.html", weapon=weapon, paint=paint, float=float, seed=seed, view=view)

@app.route('/inventory/<steamId>')
def inventory(steamId=None):
	return render_template("inventory.html", steamId=steamId)

@app.route('/steam/inventory/<steamId>')
def steamInventory(steamId=None):
	json = urllib.request.urlopen("http://api.steampowered.com/IEconItems_730/GetPlayerItems/v0001/?key=" + config.steamApiKey + "&SteamID=" + steamId).read()
	return Response(response=json, status=200, mimetype="application/json")

@app.route('/jquery-1.11.3.min.js')
def jquery():
	return send_from_directory("static", "jquery-1.11.3.min.js")

@app.route('/preloader.gif')
def preloader():
	return send_from_directory("static", "preloader.gif")

@app.route('/image/<weapon>')
def weapon(weapon=None):
	paint = request.args.get("paint")
	float = request.args.get("float")
	stattrak = -1
	quality = 2
	seed = request.args.get("seed")
	view = request.args.get("view")

	weaponString = weapon + " " + paint + " " + float + " " + str(stattrak) + " " + str(quality) + " " + seed
	filename = csgo.screenshotFilename(weaponString, view)
	if not os.path.isfile(filename):
		messagequeue.send(weaponString)
		return "queued", status.HTTP_202_ACCEPTED
	else:
		return send_from_directory(".", filename)

if __name__ == '__main__':
	app.run(host="0.0.0.0", debug=True)
