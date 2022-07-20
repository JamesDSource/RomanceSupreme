extends Spatial

var event_done: FuncRef = null

var glass_shatter_sound = preload("res://assets/sounds/cutscenes/smashing_glass.wav")

func _ready():
	if !Progress.played_opening_cutscene:
		SequenceManager.start_seq("scene1Wakeup", $InitialCutscene/Cameras.get_children(), funcref(self, "_on_sequence_finished1"), funcref(self, "_on_sequence_event"))
		$Player3P.visible = false
	else:
		$InitialCutscene/PlayerCharacterProp.visible = false

func _on_sequence_finished1():
	$Player3P.visible = true
	$InitialCutscene/PlayerCharacterProp.visible = false
	Progress.played_opening_cutscene = true

func _on_sequence_finished2():
	$BathroomCutscene/PlayerCharacterProp.visible = false
	Progress.taken_drugs = true
	Transition.to_scene("res://map/spooky_town.tscn", 2)

func _on_sequence_event(event: String,  done: FuncRef):
	match event:
		"open eyes":
			$AnimationPlayer.play("eye_open")
			event_done = done
		"bottle miss":
			$InitialCutscene/AudioStreamPlayer.stream = glass_shatter_sound
			$InitialCutscene/AudioStreamPlayer.play()
			done.call_func()
		"bottle hit":
			$AnimationPlayer.play("bloodied")
			done.call_func()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"eye_open":
			event_done.call_func()

func _on_BathroomCutsceneDetection_body_entered(body:Node):
	if body.is_in_group("player3p") and !Progress.taken_drugs:
			$BathroomCutscene/PlayerCharacterProp.visible = true
			SequenceManager.start_seq("scene3BathroomDeal", $BathroomCutscene/Cameras.get_children(), funcref(self, "_on_sequence_finished2"), funcref(self, "_on_sequence_event"))

