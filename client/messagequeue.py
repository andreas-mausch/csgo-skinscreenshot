import config
import pika

def open(host):
	return pika.BlockingConnection(pika.ConnectionParameters(host))

def openChannel(connection, name):
	channel = connection.channel()
	channel.queue_declare(queue=name)
	return channel

def sendMessage(channel, routing_key, body):
	channel.basic_publish(exchange='', routing_key=routing_key, body=body)

def receiveMessage(channel, queue, callback):
	channel.basic_consume(callback, queue)

def send(body):
	connection = open(config.messagequeueHost)
	channel = openChannel(connection, config.messagequeueName)
	sendMessage(channel, config.messagequeueName, body)
	connection.close()

def start_consuming(callback):
	connection = open(config.messagequeueHost)
	channel = openChannel(connection, config.messagequeueName)
	receiveMessage(channel, config.messagequeueName, callback)
	channel.start_consuming()
