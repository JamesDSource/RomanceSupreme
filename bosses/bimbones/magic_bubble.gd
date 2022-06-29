extends Area

var single_sound_player = preload("res://single_sound_player/single_sound_player.tscn")

var dir: Vector3 = Vector3.ZERO
var speed: float = 8.0
var player: Player1P

func _ready():
	scale.x = 0
	scale.y = 0
	scale.z = 0

	var players = get_tree().get_nodes_in_group("player1p")
	if players.size() > 0: 
		player = players[0]

func _process(delta):
	var player_pos = player.global_transform.origin
	player_pos.y += 2
	if dir != Vector3.ZERO:
		global_transform.origin += dir*speed*delta

		var ideal = (player_pos - global_transform.origin).normalized()
		dir = dir.move_toward(ideal, delta*2).normalized()
	else:
		scale = scale.move_toward(Vector3(1, 1, 1), delta)
		if scale.x == 1:
			dir = (player_pos - global_transform.origin).normalized()
			$Life.start()

func _on_Life_timeout():
	queue_free()

func _on_MagicBubble_body_entered(body):
	if body == player:
		player.damage(30, 20, dir)
		queue_free()
	elif body is StaticBody:
		queue_free()
