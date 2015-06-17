import csgo
import messagequeue
import pika
import screenshot

def takeScreenshot():
	csgo.focusCounterStrikeWindow()
	csgo.executeConsoleCommand("status")
	screenshot.saveScreenshot("Screenshot.jpg")

def callback(ch, method, properties, body):
	print ("Received ", body)
	takeScreenshot()
	ch.basic_ack(delivery_tag = method.delivery_tag)

connection = messagequeue.open('Hauptrechner')
channel = messagequeue.channel(connection, 'hello')
messagequeue.receive(channel, 'hello', callback)
channel.start_consuming()
