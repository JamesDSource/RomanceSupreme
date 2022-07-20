extends StaticBody

var _prompt: String = "Talk"

func _ready():
	if Progress.confronted_anime_boy:
		queue_free()
	$AnimationPlayer.play("idleanimation")

func _on_interact():
	SequenceManager.start_seq("scene2Guy", get_tree().root.get_node("Spatial/Cameras").get_children(), funcref(self, "_on_sequence_finished"), funcref(self, "_on_sequence_event"))

func _on_sequence_finished():
	Progress.confronted_anime_boy = true
	queue_free()

func _on_sequence_event(event: String,  done: FuncRef):
	pass
