extends Area

export var in_port: int = 0
export var out_port: int = 0

var lock: bool = false

func _ready():
	if Transition.port == in_port:
		var player = get_tree().get_nodes_in_group("player3p")
		if player.size() > 0:
			lock = true
			player[0].global_transform.origin = global_transform.origin

func _on_Gate_body_entered(body):
	if !lock and body is Player3P:
		print("Gate entered")

func _on_Gate_body_exited(body):
	lock = false
