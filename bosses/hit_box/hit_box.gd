extends Area
class_name HitBox

signal on_hit(id, dmg)
signal on_hurt(id, player)

export var id: String = ""

export var is_hit_box: bool = true

var player: Player1P = null
var is_hurt_box: bool = false

func _ready():
	if is_hit_box:
		add_to_group("hit box")

func shot(dmg: int):
	emit_signal("on_hit", id, dmg)

func hurt_box_open():
	is_hurt_box = true

	if player != null:
		emit_signal("on_hurt", id, player)

func hurt_box_close():
	is_hurt_box = false

func _on_HitBox_body_entered(body):
	if body.is_in_group("player1p"):
		player = body

		if is_hurt_box:
			emit_signal("on_hurt", id, player)

func _on_HitBox_body_exited(body):
	if player == body:
		player = null
