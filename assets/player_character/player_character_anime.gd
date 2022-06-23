extends Spatial

const FOOTSTEP_DIR = "res://assets/sounds/footsteps"
var footsteps: Array = []

func _ready():
	footsteps = Resources.get_resources_in_dir(FOOTSTEP_DIR)	

func play_footstep():
	$FootstepPlayer.stream = footsteps[randi()%footsteps.size()]
	$FootstepPlayer.play()
