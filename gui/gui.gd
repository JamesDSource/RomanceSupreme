extends ViewportContainer
class_name Gui

onready var fade_screen = $FadeScreen

func _ready():
	Transition.gui = self
	$FadeScreen/Loading/AnimationPlayer.play("loading")
