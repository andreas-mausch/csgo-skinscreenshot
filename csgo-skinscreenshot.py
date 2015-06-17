import csgo
import messagequeue
import os.path
import pika
import screenshot
import time

def screenshotFilename(skin, view):
	return "screenshots/" + skin.replace(' ', '##') + "###" + view + ".png"

def takeScreenshot(skin):
	csgo.focusCounterStrikeWindow()
	csgo.executeConsoleCommand("sm_teleport 74 384 11851 20 0 0")
	csgo.executeConsoleCommand("sm_changeskin " + skin)
	time.sleep(3)
	screenshot.saveScreenshot(screenshotFilename(skin, "ps"))
	csgo.sendKey(ord('F'))
	time.sleep(2)
	screenshot.saveScreenshot(screenshotFilename(skin, "inspect"))

def screenshotsExists(skin):
	return os.path.isfile(screenshotFilename(skin, "ps")) and os.path.isfile(screenshotFilename(skin, "inspect"))

def callback(ch, method, properties, body):
	skin = body.decode("utf-8")
	print ("Received ", skin)
	if not screenshotsExists(skin):
		takeScreenshot(skin)
	ch.basic_ack(delivery_tag = method.delivery_tag)

connection = messagequeue.open('Hauptrechner')
channel = messagequeue.channel(connection, 'hello')
messagequeue.receive(channel, 'hello', callback)
channel.start_consuming()
