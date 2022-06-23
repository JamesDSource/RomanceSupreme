tool
extends Control
class_name Crosshair

export var seperation: float = 10 setget set_seperation

func set_seperation(sep):
	seperation = sep
	if get_node_or_null("NeedleUp") != null:
		$NeedleUp.position.y = seperation
		$NeedleDown.position.y = -seperation
		$NeedleRight.position.x = -seperation
		$NeedleLeft.position.x = seperation
