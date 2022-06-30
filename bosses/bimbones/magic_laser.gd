tool
extends RayCast

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var length: float = cast_to.length()
	if is_colliding():
		length = get_collision_point().distance_to(global_transform.origin)
		$MeshInstance.transform.origin = length*cast_to.normalized()
	else:
		$MeshInstance.transform.origin = cast_to/2
	
	$MeshInstance.mesh.mid_height = length
#	$MeshInstance.mesh.rings = min(20, length*5)

	if !Engine.editor_hint:
		var body: PhysicsBody = get_collider()
		if body != null and body.is_in_group("player1p"):
			body.damage(15, 30, global_transform.basis.z)
