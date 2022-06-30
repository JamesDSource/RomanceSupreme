extends KinematicBody
class_name SkellB

signal on_hit(dmg)

var magic_bolt = preload("res://bosses/bimbones/magic_bolt.tscn")

onready var tip_of_wand = $"skell-b/Skeleton/HandRightAttachment/TipOfWand"
onready var anim_player1 = $AnimationPlayer
onready var anim_player2 = $AnimationPlayer2

var set_anim1: String = ""
var anim_playing1: String = ""

var set_anim2: String = ""
var anim_playing2: String = ""

func _process(_delta):
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

func fire_magic_bolt():
	var bolt = magic_bolt.instance()
	get_tree().root.add_child(bolt)

	bolt.global_transform.origin = tip_of_wand.global_transform.origin

	var players = get_tree().get_nodes_in_group("player1p")
	if players.size() > 0:
		var player_pos = players[0].global_transform.origin
		player_pos.y += 1
		bolt.look_at(player_pos, Vector3.DOWN)
		bolt.transform.basis.z *= -1
