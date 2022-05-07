extends Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.window_fullscreen = true

func _process(delta):
	if(Input.is_action_just_pressed("pause")):
		get_tree().quit()
