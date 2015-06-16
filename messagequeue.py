import pika

def open(host):
	return pika.BlockingConnection(pika.ConnectionParameters(host))

def channel(connection, name):
	channel = connection.channel()
	channel.queue_declare(queue=name)
	return channel

def send(channel, routing_key, body):
	channel.basic_publish(exchange='', routing_key=routing_key, body=body)

def receive(channel, queue, callback):
	channel.basic_consume(callback, queue)
