import messagequeue
import pika
import sys

command = ' '.join(sys.argv[1:])

connection = messagequeue.open('Hauptrechner')
channel = messagequeue.channel(connection, 'hello')
messagequeue.send(channel, 'hello', command)
connection.close()
