extends Node

func _ready():
	print("Edit-only node freeing: ",get_parent().get_name(),"/",get_name())
	queue_free()
