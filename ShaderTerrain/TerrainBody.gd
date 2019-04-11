extends StaticBody

var registered_bodies={}
var osn : OpenSimplexNoise=null
var amp : float
export(int) var cell_radius=1

var dynshape : ConcavePolygonShape=null

func register_body(phyBody):
	# register a physics body for shape generation
	registered_bodies[phyBody]=true

func unregister_body(phyBody):
	# unregister a physics body for shape generation
	registered_bodies.erase(phyBody)

func set_heightmap(osn_in : OpenSimplexNoise, amp_in : float):
	osn=osn_in
	amp=amp_in

func _ready():
	for c in get_children():
		if c.get_name()=="dynShape":
			dynshape=c

func _physics_process(delta):
	var used={}
	var verts=PoolVector3Array()
	var lXZ=Vector2()
	var mCorner=Vector2()
	var pCorner=Vector2()
	var A=Vector2()
	var B=Vector2()
	var C=Vector2()
	var D=Vector2()
	var row
	var col
	for body in registered_bodies:
		lXZ.x=floor(body.translation.x)
		lXZ.y=floor(body.translation.z)
		row=-cell_radius
		col=-cell_radius
		while row<cell_radius:
			while col<cell_radius:
				mCorner.x=col
				pCorner.x=col+1
				mCorner.y=row
				pCorner.y=row+1
				# we only want to generate overlapping tris once
				if (not mCorner in used) and (not pCorner in used):
					A=Vector3(col  ,amp*osn.get_noise_2d(col  ,row  ),row  )
					B=Vector3(col+1,amp*osn.get_noise_2d(col+1,row  ),row  )
					C=Vector3(col  ,amp*osn.get_noise_2d(col  ,row+1),row+1)
					D=Vector3(col+1,amp*osn.get_noise_2d(col+1,row+1),row+1)
					verts.append(A)
					verts.append(C)
					verts.append(B)
					verts.append(B)
					verts.append(C)
					verts.append(D)
					used[mCorner]=true
					used[pCorner]=true
				col+=1
			row+=1
	dynshape.set_faces(verts)

