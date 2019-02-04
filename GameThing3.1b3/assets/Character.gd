extends Spatial

const z2:=Vector2(0.0,0.0)
const z3:=Vector3(0.0,0.0,0.0)

onready var pRoot:=$".." as Area
onready var pFloor:=$"../../world/floor" as Spatial
onready var dolly:=$"dolly" as Spatial

export var mouseTurnDamp:=0.0125
export var mouseLookDamp:=0.5
export var mouseDZone:=0.01
export var mptrResetDly:=0.15

var vpCenter=z2

func _ready():
	var vpSize
	vpSize=OS.get_window_size()
	vpCenter=vpSize/2.0
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

var jtime:=0.0
var pSpeed:=3.0
var pTRate:=1.0
var cpos:=0.0
var vTerm:=-53
var vCur:=0.0
var grav:=-9.8
var floorHit=false
var netMove : Vector3
var bMove : Vector3
var aMove : Vector3
const noMove=1

var _spd:=z2
func _input(evt):
	if evt is InputEventMouseMotion:
		_spd=evt.get_speed()
	if evt is InputEventMouseButton:
		if evt.pressed:
			print(dolly.rotation_degrees)

var _pos:=z2
var _posC:=z2
var _spdV:=0.0
var _spdH:=0.0
var _turnM:=false
var _turnL:=false
var _turnR:=false
var _lookU:=false
var _lookD:=false
var _turnK:=false
var _mp_reset:=0.0
var _rx:=0.0
func _process(delta):
	_posC=get_viewport().get_mouse_position()
	if _posC==_pos:
		_spd=z2
		if _mp_reset==0.0:
			_mp_reset=mptrResetDly
	else:
		_mp_reset=0.0
	_pos=_posC
	_spdH=_spd.x
	_spdV=_spd.y
	
	if _mp_reset>0.0:
		_mp_reset=max(0.0,_mp_reset-delta)
		if _mp_reset==0.0:
			_pos=vpCenter
			_posC=vpCenter
			Input.warp_mouse_position(vpCenter)

	if Input.is_action_pressed("game_altmod") and \
	Input.is_action_pressed("game_quit"):
		get_tree().quit()

	_turnM=not Input.is_action_pressed("turn_camonly")
	_turnL=_spdH < (-mouseDZone)
	_turnR=_spdH > (mouseDZone)
	_lookU=_spdV > (mouseDZone)
	_lookD=_spdV < (-mouseDZone)
	_turnK=not (_turnL or _turnR)

	if _turnK:
		_turnL=Input.is_action_pressed("player_tleft")
		_turnR=Input.is_action_pressed("player_tright")
		if _turnM and (_turnL or _turnR):
			dolly.rotation.y=0.0
	else:
		if _turnM:
			pRoot.rotate_y(-delta*_spdH*mouseTurnDamp)
			dolly.rotation.y=0.0
			_turnL=false
			_turnR=false
		else:
			dolly.rotate_y(-delta*_spdH*mouseTurnDamp)
			_turnL=Input.is_action_pressed("player_tleft")
			_turnR=Input.is_action_pressed("player_tright")

	if _turnL:
		pRoot.rotate_y(delta*pTRate)
	if _turnR:
		pRoot.rotate_y(-delta*pTRate)

	if _lookU or _lookD:
		_rx=dolly.rotation_degrees.x
		_rx+=(-delta*_spdV*mouseLookDamp)
		_rx=min(_rx,70)
		_rx=max(_rx,-33)
		dolly.rotation_degrees.x=_rx

	bMove=pRoot.get_translation()
	
	if Input.is_action_pressed("player_frwd") and abs(vCur)<noMove:
		pRoot.translate(Vector3(0,0,1)*pSpeed*delta)
		for bonk in pRoot.get_overlapping_bodies():
			if bonk.get_parent()==pFloor:
				var spc=get_world().direct_space_state
				var pos=dolly.get_global_transform().origin
				var pos2=pos
				pos2.y-=10
				var hit=spc.intersect_ray(pos,pos2)
				if hit.has('position'):
					pos=hit.position
					pos2=pRoot.get_global_transform().origin
					pRoot.translation.y+=(pos.y-pos2.y)
					cpos=pRoot.get_translation().y
	if Input.is_action_pressed("player_rvrs") and abs(vCur)<noMove:
		pRoot.translate(Vector3(0,0,-1)*pSpeed*delta)
		for bonk in pRoot.get_overlapping_bodies():
			if bonk.get_parent()==pFloor:
				var spc=get_world().direct_space_state
				var pos=dolly.get_global_transform().origin
				var pos2=pos
				pos2.y-=10
				var hit=spc.intersect_ray(pos,pos2)
				if hit.has('position'):
					pos=hit.position
					pos2=pRoot.get_global_transform().origin
					pRoot.translation.y+=(pos.y-pos2.y)
					cpos=pRoot.get_translation().y

	if Input.is_action_pressed("player_sleft") and abs(vCur)<noMove:
		pRoot.translate(Vector3(1,0,0)*pSpeed*delta)
		for bonk in pRoot.get_overlapping_bodies():
			if bonk.get_parent()==pFloor:
				var spc=get_world().direct_space_state
				var pos=dolly.get_global_transform().origin
				var pos2=pos
				pos2.y-=10
				var hit=spc.intersect_ray(pos,pos2)
				if hit.has('position'):
					pos=hit.position
					pos2=pRoot.get_global_transform().origin
					pRoot.translation.y+=(pos.y-pos2.y)
					cpos=pRoot.get_translation().y
	if Input.is_action_pressed("player_sright") and abs(vCur)<noMove:
		pRoot.translate(Vector3(-1,0,0)*pSpeed*delta)
		for bonk in pRoot.get_overlapping_bodies():
			if bonk.get_parent()==pFloor:
				var spc=get_world().direct_space_state
				var pos=dolly.get_global_transform().origin
				var pos2=pos
				pos2.y-=10
				var hit=spc.intersect_ray(pos,pos2)
				if hit.has('position'):
					pos=hit.position
					pos2=pRoot.get_global_transform().origin
					pRoot.translation.y+=(pos.y-pos2.y)
					cpos=pRoot.get_translation().y

	aMove=pRoot.get_translation()

	if Input.is_action_just_pressed("player_jump") and abs(vCur)<noMove:
		jtime=0.375
		netMove=(aMove-bMove)/delta
	if jtime>0.0:
		jtime=max(0.0,jtime-delta)
		for bonk in pRoot.get_overlapping_bodies():
			if bonk.get_parent()==pFloor:
				var spc=get_world().direct_space_state
				var pos=dolly.get_global_transform().origin
				var pos2=pos
				pos2.y-=10
				var hit=spc.intersect_ray(pos,pos2)
				if hit.has('position'):
					pos=hit.position
					pos2=pRoot.get_global_transform().origin
					pRoot.translation.y+=.05+(pos.y-pos2.y)
		pRoot.translation.y+=9*delta
		cpos=pRoot.get_translation().y

func _physics_process(delta):
	cpos=pRoot.translation.y
	floorHit=false
	for bonk in pRoot.get_overlapping_bodies():
		if bonk.get_parent()==pFloor:
			floorHit=true
			if vCur<0.0:
				var spc=get_world().direct_space_state
				var pos=dolly.get_global_transform().origin
				var pos2=pos
				pos2.y-=10
				var hit=spc.intersect_ray(pos,pos2)
				if hit.has('position'):
					pos=hit.position
					pos2=pRoot.get_global_transform().origin
					pRoot.translation.y+=(pos.y-pos2.y)
					cpos=pRoot.get_translation().y
				netMove=Vector3(0.0,0.0,0.0)
				vCur=0.0
			break
	if not floorHit:
		vCur=max(vTerm,vCur+(delta*grav))
		cpos+=vCur*delta
		pRoot.translation.x+=netMove.x*delta
		pRoot.translation.z+=netMove.z*delta
	pRoot.translation.y=cpos
