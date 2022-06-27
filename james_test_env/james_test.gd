extends Spatial

func _ready():
	SequenceManager.start_seq("test_james", $CutsceneCameras.get_children(), funcref(self, "_on_sequence_finished"), funcref(self, "_on_sequence_event"))

func _on_sequence_finished(custom_vars):
	print(custom_vars)

func _on_sequence_event(event: String, custom_vars: Dictionary, done: FuncRef):
	print(event)
	done.call_func()
