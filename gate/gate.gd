extends Area

export var in_port: int = 0
export var out_port: int = 0
export(String, FILE) var scene
export var spawn_point: NodePath

func _ready():
	print(Transition.port)
	if Transition.port == out_port:
		var player = get_tree().get_nodes_in_group("player3p")
		print(player)
		if player.size() > 0:
			player[0].global_transform.origin = get_node(spawn_point).global_transform.origin

func _on_Gate_body_entered(body):
	if body is Player3P:
		Transition.to_scene(scene, in_port)
