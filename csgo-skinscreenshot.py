import config
import csgo
import messagequeue
import os.path
import pika
import screenshot
import time

def takeScreenshot(skin):
	csgo.focusCounterStrikeWindow()
	csgo.executeConsoleCommand("sm_teleport 74 384 11851 20 0 0")
	csgo.executeConsoleCommand("sm_changeskin " + skin)
	time.sleep(5)
	screenshot.saveScreenshot(csgo.screenshotFilename(skin, "playside"))
	csgo.sendKey(ord('F'))
	time.sleep(2)
	screenshot.saveScreenshot(csgo.screenshotFilename(skin, "inspect"))

def screenshotsExists(skin):
	return os.path.isfile(csgo.screenshotFilename(skin, "playside")) and os.path.isfile(csgo.screenshotFilename(skin, "inspect"))

def callback(ch, method, properties, body):
	skin = body.decode("utf-8")
	print ("Received ", skin)
	if not screenshotsExists(skin):
		takeScreenshot(skin)
	ch.basic_ack(delivery_tag = method.delivery_tag)

messagequeue.start_consuming(callback)
