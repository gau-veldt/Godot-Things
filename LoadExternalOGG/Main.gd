extends Control

var bgm : AudioStreamOGGVorbis = null
var where : String = ""

onready var player=$Player as AudioStreamPlayer
onready var fsDlg=$FileSelect as FileDialog
onready var chgBtn=$ChangeSong as Button
onready var quitBtn=$ForceQuit as Button

# Open the file chooser
func open_dialog():
	chgBtn.hide()
	fsDlg.popup_centered()

# Dialog was cancelled
func cancelled():
	fsDlg.hide()
	if where=="":
		get_tree().quit()
	else:
		chgBtn.show()

# quit button
func quit_now():
	get_tree().quit()

# Play background song
func change_bgm(newFile:String):
	fsDlg.hide()
	chgBtn.show()
	where=newFile
	bgm=kludge_loader(where) as AudioStreamOGGVorbis 
	if player.playing: player.stop()
	player.stream=bgm
	player.play()

func kludge_loader(arg_path) -> AudioStreamOGGVorbis:
	var f:=File.new()
	f.open(arg_path,f.READ)
	var blob:=f.get_buffer(f.get_len())
	var audio:=AudioStreamOGGVorbis.new()
	audio.data=blob
	f.close()
	return audio

# Called when the node enters the scene tree for the first time.
func _ready():
	chgBtn.hide()
	quitBtn.connect("pressed",self,"quit_now")

	fsDlg.clear_filters()
	fsDlg.add_filter("*.OGG ; Vorbis (OGG) Audio")

	fsDlg.connect("file_selected",self,"change_bgm")
	fsDlg.get_cancel().connect("pressed",self,"cancelled")
	chgBtn.connect("pressed",self,"open_dialog")

	if where=="":
		fsDlg.popup_centered()
	else:
		chgBtn.show()