extends Node

signal wakeup
signal loaded
signal loadprog(current,total)

onready var vp := get_node("/root") as Viewport
onready var sceneRoot := get_node("/root/main/loaded") as Node
onready var lpw := get_node("/root/main/LPW") as Control
onready var lpw_anim := get_node("LPW_anims") as AnimationPlayer

var loadCycle := false
var loadScn : ResourceInteractiveLoader = null
var newScn : PackedScene = null
var loadTotal := 0.0
var loadCur := 0.0
var snooze := 0.0

############################################################
#    Allows warning kills for specific identifiers in
#    specific methods rather than the entire script
#    (comment filter) or entire project (using project
#    warning settings).
############################################################
var _hk
func ignore(hk):
	_hk=hk
############################################################

############################################################
#    Periodic processing
#        - Processes background loading when loadCycle
#          is true and loadCycle will reset to disable
#          automatically when finished.
#            - emits a loaded signal when complete
#            - emits loadprog signal during loading as
#              a heartbeat to report loading progress
############################################################
var _rc:=0
func _process(delta):
	if loadCycle:
		_rc=loadScn.poll()
		if _rc==ERR_FILE_EOF:
			emit_signal("loadprog",100.0,100.0)
			loadCycle=false
			newScn=loadScn.get_resource()
			emit_signal("loaded")
		else:
			loadTotal=loadScn.get_stage_count()
			loadCur=loadScn.get_stage()
			emit_signal("loadprog",loadCur,loadTotal)
	if snooze>0.0:
		snooze-=delta
		if snooze<=0.0:
			snooze=0.0
			emit_signal("wakeup")
############################################################

############################################################
#    Interactive scene load
#        - Removes currently loaded scene
#        - Brings up a load progress scene during load
#        - Loads scene under loaded Node in master tree
#        - New Scene instanced and ready to go on exit
############################################################
func load_scene(path : String) -> void:
	# bring transition scene into view
	lpw.show()
	_hk=connect("loadprog",lpw,"update_prog")
	lpw_anim.play("in")
	yield(lpw,"lpw_in")

	# nuke currently loaded scene
	var chl := sceneRoot.get_children()
	for ch in chl:
		sceneRoot.remove_child(ch)
		ch.queue_free()

	# initialize load for new scene
	loadScn=ResourceLoader.load_interactive(path)
	loadCycle=true
	yield(self,"loaded")			# we wake up when load is done
	disconnect("loadprog",lpw,"update_prog")

	# Make scene official and place it into the game.
	# The loaded PackedScene is in newScn.
	var scnInst=newScn.instance()
	sceneRoot.add_child(scnInst)

	# hide transition scene
	lpw_anim.play("out")
	yield(lpw,"lpw_out")
	lpw.hide()

	# These will hang around and suck
	# memory so we clean their clocks
	loadScn=null
	newScn=null
############################################################

############################################################
#    Returns the game's master (root) viewport
############################################################
func get_viewport() -> Viewport:
	return vp
############################################################

############################################################
#    Returns the root where scenes are loaded
############################################################
func get_scene() -> Node:
	return sceneRoot
############################################################

############################################################
#    Initializer/constructor
############################################################
func _ready() -> void:
	snooze=2.0
	yield(self,"wakeup")
	load_scene("res://zone_0001.tscn")
############################################################
