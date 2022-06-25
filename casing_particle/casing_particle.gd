extends RigidBody

func _on_Timer_timeout():
	queue_free()
	remove_and_skip()
