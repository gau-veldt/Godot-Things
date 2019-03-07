extends Node

export var regen_image=false
export(String) var world_seed
export var amplitude=1.0
export var stretch=801.0
export(int) var chunk_x
export(int) var chunk_y

var fps = 0
var frameCount = 0
var elapsed = 0.0
var fpsLen = 0.0
var fpsCnt = 0

var chunk_size=Vector2(801,801)

func h_to_color(v_in):
	var c=Color()
	var v=float(v_in)
	var pv
	v+=128.0
	c.b8=0
	pv=int(v)
	c.g8=pv
	v-=float(pv)
	pv=int(min(255.0,int(v*256.0)))
	c.r8=pv
	return c;

func _ready():
	if regen_image:
		var noisemaker := OpenSimplexNoise.new()
		noisemaker.seed=world_seed.hash()
		noisemaker.octaves=4
		noisemaker.period=stretch
		noisemaker.persistence=0.8
		var hval
		var testImg=Image.new()
		testImg.create(chunk_size.x,chunk_size.y,false,Image.FORMAT_RGBA8)
		testImg.lock()
		for row in range(801):
			for col in range(801):
				hval=amplitude*noisemaker.get_noise_2d(col,row)
				testImg.set_pixel(col,row,h_to_color(hval))
		testImg.unlock()
		testImg.save_png("res://testHeight.png")

func _process(delta):
	frameCount += 1
	elapsed += delta

	fpsCnt += 1
	fpsLen += delta
	if fpsLen>=1.0:
		fps=float(fpsCnt)/fpsLen
		fpsLen=0.0
		fpsCnt=0

func get_fps():
	return fps
