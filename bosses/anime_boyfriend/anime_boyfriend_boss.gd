extends Boss

enum State {
	FOLLOW,
	SPIN,
	BI_KICK,
	GUARD
}
var state = State.FOLLOW

var set_anim: String = "bikick"
var playing_anim: String = ""

func _process(_delta):
	if set_anim != playing_anim:
		$AnimationPlayer.play(set_anim)
		playing_anim = set_anim

func _physics_process(_delta):
	match state:
		State.FOLLOW:
			set_anim = "bikick"
		State.SPIN:
			pass
		State.BI_KICK:
			pass
		State.GUARD:
			pass

func close_all_hurt_boxes():
	var children = $animeboyfriend/Skeleton.get_children()
	for child in children:
		var hit_box = child.get_node_or_null("HitBox")
		if hit_box != null:
			hit_box.hurt_box_close()

func _on_hit(id, dmg):
	match id.strip_edges():
		"head":
			dmg *= 1.3
		"leg lower right", "leg upper right", "leg lower left", "leg upper left", "arm upper right", "arm lower right", "arm upper left", "arm lower left":
			dmg *= 0.9
		"foot right", "foot_left":
			dmg *= 0.85


func _on_hurt(id, player):
	match id.strip_edges():
		"foot right", "foot_left":
			player.damage(0, 20, global_transform.basis.z)
		"hand left", "hand right", "arm lower left", "arm lower right":
			player.damage(0, 20, global_transform.origin - player.global_transform.origin)
