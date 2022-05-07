extends Node

var mouse_needed: int = 0

func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS)

func _process(delta):
	var mm = Input.get_mouse_mode()
	if(mm == Input.MOUSE_MODE_CAPTURED and mouse_needed > 0):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif(mm != Input.MOUSE_MODE_CAPTURED and mouse_needed == 0):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif(mouse_needed < 0):
		print("Mouse needed is " + str(mouse_needed) + ", that is not right")
