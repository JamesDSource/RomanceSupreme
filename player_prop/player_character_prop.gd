tool
extends Spatial

export(String, "idleanimation", "sitting_pose") var animation setget set_animation

func set_animation(anim: String):
	animation = anim
	$AnimationPlayer.play(anim)
