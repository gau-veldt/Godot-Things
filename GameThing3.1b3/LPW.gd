extends TextureRect

signal lpw_in
signal lpw_out

onready var prog := get_node("prog") as ProgressBar

func _ready():
	pass

func onInAnim():
	emit_signal("lpw_in")

func onOutAnim():
	emit_signal("lpw_out")

func update_prog(current,total):
	prog.min_value=0.0
	prog.max_value=float(total)
	prog.value=float(current)
	prog.update()
