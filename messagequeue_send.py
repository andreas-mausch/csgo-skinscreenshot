import config
import messagequeue
import pika
import sys

command = ' '.join(sys.argv[1:])

connection = messagequeue.open(config.messagequeueHost)
channel = messagequeue.channel(connection, config.messagequeueName)
messagequeue.send(channel, config.messagequeueName, command)
connection.close()
