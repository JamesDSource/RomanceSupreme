extends KinematicBody
class_name Boss

export var boss_name: String = ""
export var hp_max: int = 300
export var hp: int = 300

func _ready():
	add_to_group("boss")
