extends Node

var loader: ResourceInteractiveLoader = null
var port: int = -1
var gui: Gui = null
const FADE_SPEED: float = 0.8

func _ready():
	pause_mode = PAUSE_MODE_PROCESS

func _process(delta):
	if loader != null:
		get_tree().paused = true
		gui.fade_screen.modulate.a = move_toward(gui.fade_screen.modulate.a, 1, delta*FADE_SPEED)
		var err = loader.poll()
		if abs(gui.fade_screen.modulate.a - 1) < 0.00001 and err == ERR_FILE_EOF:
			var scene = loader.get_resource()
			loader = null

			InputState.mouse_needed = 0
			get_tree().change_scene_to(scene)
			get_tree().paused = false
	elif gui != null and gui.fade_screen.modulate.a > 0:
		gui.fade_screen.modulate.a = move_toward(gui.fade_screen.modulate.a, 0, delta*FADE_SPEED)

func to_scene(scene: String, in_port: int):
	port = in_port
	loader = ResourceLoader.load_interactive(scene)
