import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.queue_declare(queue='hello')

def send(routing_key, body):
	channel.basic_publish(exchange='', routing_key=routing_key, body=body)

def receive():
	channel.basic_consume(callback, queue='hello')

def callback(ch, method, properties, body):
	print ("Received ", body)
	ch.basic_ack(delivery_tag = method.delivery_tag)

send('hello', 'Hallo World 1')
send('hello', 'Hallo World 2')
send('hello', 'Hallo World 3')
receive()
connection.close()
