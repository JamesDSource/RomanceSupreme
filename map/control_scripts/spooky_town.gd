extends Spatial

func _ready():
	if !Progress.been_to_spooky_town:
		SequenceManager.start_seq("scene4HalloweenTown", $WelcomeCutscene/Cameras.get_children(), funcref(self, "_on_sequence_finished"), funcref(self, "_on_sequence_event"))
		$WelcomeCutscene/Ghosts.visible = true
		$WelcomeCutscene/Grungulus.visible = true

func _on_sequence_finished():
	Progress.been_to_spooky_town = true
	$WelcomeCutscene/Ghosts.visible = false
	$WelcomeCutscene/Grungulus.visible = false

func _on_sequence_event(event: String,  done: FuncRef):
	pass

