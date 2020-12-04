extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text=get_child(0).MySpecialVar+" "+get_child(1).MySpecialVar


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
