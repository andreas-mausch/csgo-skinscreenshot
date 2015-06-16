import messagequeue
import pika

def callback(ch, method, properties, body):
	print ("Received ", body)
	ch.basic_ack(delivery_tag = method.delivery_tag)

connection = messagequeue.open('Hauptrechner')
channel = messagequeue.channel(connection, 'hello')
messagequeue.receive(channel, 'hello', callback)
connection.close()
