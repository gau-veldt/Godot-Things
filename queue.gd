
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

var queue=[]

#
# implements a very simple queue class
#
# if the queue class is instanced on a global autoload object
# it may serve as a message passing mechanism across scenes
#

func enqueue(name, body):
	var msg={}
	msg["name"]=name
	msg["body"]=body
	queue.append(msg)

func message_waiting():
	if queue.size()>0:
		return true
	else:
		return false

func get_message():
	var msg=queue[0]
	queue.remove(0)
	return msg

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	enqueue("foo","oof")
	enqueue("bar","rab")
	enqueue("baz","zab")
	var msg
	while message_waiting():
		print("message waiting... get it:")
		msg=get_message()
		print("  message name=",msg["name"]," body=",msg["body"])
