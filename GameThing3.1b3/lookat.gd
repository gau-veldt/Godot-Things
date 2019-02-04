extends Spatial

const T_S_U := Vector3(0,1,0)

onready var thePlayer:=$"../../dolly" as Spatial
onready var theCamera:=$"Camera" as Camera

var cam_updn_spd := 0.0
var cam_ltrt_spd := 0.0

func _ready():	
	pass # Replace with function body.


func _process(delta):
	theCamera.look_at(thePlayer.get_global_transform().origin,T_S_U)
