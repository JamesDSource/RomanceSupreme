extends KinematicBody
class_name SkellB

signal on_hit(dmg)

onready var anim_player1 = $AnimationPlayer
onready var anim_player2 = $AnimationPlayer2

var set_anim1: String = ""
var anim_playing1: String = ""

var set_anim2: String = ""
var anim_playing2: String = ""

func _process(delta):
	if set_anim1 != anim_playing1:
		if set_anim1 == "":
			anim_player1.stop()
		else:
			anim_player1.play(set_anim1)
		anim_playing1 = set_anim1

	if set_anim2 != anim_playing2:
		if set_anim2 == "":
			anim_player2.stop()
		else:
			anim_player2.play(set_anim2)
		anim_playing2 = set_anim2

func _on_hit(id, dmg):
	match id:
		"head":
			dmg *= 1.3
		"leg right", "leg right",  "arm upper right", "arm lower right", "arm upper left", "arm lower left":
			dmg *= 0.9
		"foot right", "foot left", "hand right", "hand left":
			dmg *= 0.85

	emit_signal("on_hit", dmg)

