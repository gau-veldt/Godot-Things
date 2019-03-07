extends Label

onready var vp=get_viewport()
var root

func _ready():
	for ch in vp.get_children():
		if ch.get_name()=="Project":
			root=ch

func _process(delta):
	text="FPS: "+str(root.get_fps())
