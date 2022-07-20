tool
extends Spatial

export var is_open: bool setget set_is_open

func _ready():
	if not is_open:
		$AnimationPlayer.play("default_state")

func set_is_open(is_open_: bool):
	is_open = is_open_
	if is_open:
		$AnimationPlayer.play("doors_opening")
	else:
		$AnimationPlayer.play_backwards("doors_opening")
