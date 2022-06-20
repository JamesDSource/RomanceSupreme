extends Node

var port: int = -1

var transition_to: PackedScene = null
func to_scene(scene: PackedScene):
	scene = transition_to

func _process(delta):
	pass
