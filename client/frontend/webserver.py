import config
import csgo
import json
import messagequeue
import os
import requests
from flask import Flask, Response, request, send_from_directory, render_template
from flask_api import status

app = Flask(__name__)

def steamInventory(steamId):
	if config.alwaysUseOfflinePlayerItems:
		with open('steam/playeritems-76561198009699437.json', 'r') as f:
			readData = f.read()
			return json.loads(readData)
	else:
		return json.loads(requests.get(url="http://api.steampowered.com/IEconItems_730/GetPlayerItems/v0001/?key=" + config.steamApiKey + "&SteamID=" + steamId).text)

def steamSchema():
	if config.useOfflineSchema:
		with open('steam/csgo-schema.json', 'r') as f:
			readData = f.read()
			return json.loads(readData)
	else:
		return json.loads(requests.get(url="http://api.steampowered.com/IEconItems_730/GetSchema/v0002/?key=" + config.steamApiKey).text)

def findItemInSchema(defindex):
	schemaJson = steamSchema()
	for item in schemaJson["result"]["items"]:
		if item["defindex"] == defindex:
			return item
	return None

def findItemAttribute(item, defindex):
	for attribute in item["attributes"]:
		if attribute["defindex"] == defindex:
			return attribute;
	return None

@app.route('/<weapon>')
def index(weapon=None):
	paint = request.args.get("paint")
	float = request.args.get("float")
	seed = request.args.get("seed")
	view = request.args.get("view")
	return render_template("csgo-skinscreenshot.html", weapon=weapon, paint=paint, float=float, seed=seed, view=view)

@app.route('/inventory/<steamId>')
def inventory(steamId=None):
	inventoryJson = steamInventory(steamId)
	weapons = []
	for item in inventoryJson["result"]["items"]:
		itemSchema = findItemInSchema(item["defindex"])
		itemClass = itemSchema["name"]
		if itemClass.startswith("weapon_"):
			paint = findItemAttribute(item, 6)["float_value"]
			seed = findItemAttribute(item, 7)["float_value"]
			wear = findItemAttribute(item, 8)["float_value"]
			weapons.append({ "class": itemClass, "paint": paint, "seed": seed, "wear": wear })
	print(weapons)
	return render_template("inventory.html", weapons=weapons)

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
