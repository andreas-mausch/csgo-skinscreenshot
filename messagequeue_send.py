import messagequeue
import pika

connection = messagequeue.open('Hauptrechner')
channel = messagequeue.channel(connection, 'hello')
messagequeue.send(channel, 'hello', 'messagequeue_send.py')
connection.close()
