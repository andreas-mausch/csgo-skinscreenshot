import config
import messagequeue
import pika

def callback(ch, method, properties, body):
	print ("Received ", body)
	ch.basic_ack(delivery_tag = method.delivery_tag)

connection = messagequeue.open(config.messagequeueHost)
channel = messagequeue.channel(connection, config.messagequeueName)
messagequeue.receive(channel, config.messagequeueName, callback)
channel.start_consuming()
