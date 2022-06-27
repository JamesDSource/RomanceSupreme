extends Spatial

func _ready():
	SequenceManager.start_seq("scene1Wakeup", $CutsceneCameras.get_children(), funcref(self, "_on_sequence_finished"))

func _on_sequence_finished(custom_vars):
	print(custom_vars)
