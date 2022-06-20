extends Spatial

func _ready():
	pass #SequenceManager.start_seq("test", $CutsceneCameras.get_children(), funcref(self, "_on_sequence_finished"))

func _on_sequence_finished(custom_vars):
	print(custom_vars)
