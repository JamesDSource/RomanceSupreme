extends Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(delta):
	if(Input.is_action_just_pressed("pause")):
		get_tree().quit()
