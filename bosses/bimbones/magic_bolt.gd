extends Area

var speed: float = 20.0

func _process(delta):
	speed = move_toward(speed, 1, 10*delta)
	global_transform.origin += speed*global_transform.basis.z*delta

func _on_MagicBolt_body_entered(body):
	if body.is_in_group("player1p"):
		body.damage(10, 10, global_transform.basis.z)
		queue_free()
	elif body is StaticBody:
		queue_free()

func _on_Life_timeout():
	queue_free()
