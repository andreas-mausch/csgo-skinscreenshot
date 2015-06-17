import csgo
import messagequeue
import os.path
import pika
import screenshot
import time

def screenshotFilename(skin):
	return "screenshots/" + skin.replace(' ', '##') + ".png"

def takeScreenshot(skin):
	csgo.focusCounterStrikeWindow()
	csgo.executeConsoleCommand("sm_changeskin " + skin)
	time.sleep(5)
	csgo.sendKey(ord('F'))
	time.sleep(2)
	screenshot.saveScreenshot(screenshotFilename(skin))

def screenshotExists(skin):
	return os.path.isfile(screenshotFilename(skin))

def callback(ch, method, properties, body):
	skin = body.decode("utf-8")
	print ("Received ", skin)
	if not screenshotExists(skin):
		takeScreenshot(skin)
	ch.basic_ack(delivery_tag = method.delivery_tag)

connection = messagequeue.open('Hauptrechner')
channel = messagequeue.channel(connection, 'hello')
messagequeue.receive(channel, 'hello', callback)
channel.start_consuming()
