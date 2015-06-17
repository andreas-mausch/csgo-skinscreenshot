import csgo
import messagequeue
import pika
import screenshot
import time

def takeScreenshot(skin):
	csgo.focusCounterStrikeWindow()
	csgo.executeConsoleCommand("sm_changeskin " + skin)
	time.sleep(5)
	csgo.sendKey(ord('F'))
	time.sleep(2)
	screenshot.saveScreenshot("Screenshot.png")

def callback(ch, method, properties, body):
	string = body.decode("utf-8")
	print ("Received ", string)
	takeScreenshot(string)
	ch.basic_ack(delivery_tag = method.delivery_tag)

connection = messagequeue.open('Hauptrechner')
channel = messagequeue.channel(connection, 'hello')
messagequeue.receive(channel, 'hello', callback)
channel.start_consuming()
