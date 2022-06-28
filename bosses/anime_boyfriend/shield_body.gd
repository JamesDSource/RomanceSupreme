extends RigidBody
class_name ShieldBody

var released: bool = false
var on_hit: FuncRef = null

func release(on_hit_: FuncRef):
	on_hit = on_hit_
	$Life.start()
	released = true

func reset():
	released = false
	$CollisionShape.disabled = true

func _physics_process(delta):
	if released:
		global_transform.origin -= global_transform.basis.x.normalized()*40*delta

func _on_ShieldBody_body_entered(body):
	if released:
		if body.is_in_group("player1p"):
			body.damage(20, 5, global_transform.basis.z.normalized())
			on_hit.call_func()
			visible = false

func _on_Life_timeout():
	on_hit.call_func()
	visible = false
	$Life.stop()
