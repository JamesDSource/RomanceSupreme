extends Node

func _ready():
	OS.window_fullscreen = true

func _process(delta):
	if(Input.is_action_just_pressed("pause")):
		get_tree().quit()
