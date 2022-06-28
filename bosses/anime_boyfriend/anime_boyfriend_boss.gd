extends Boss

enum State {
	FOLLOW,
	SPIN,
	BI_KICK,
	GUARD
}
var state = State.FOLLOW
var last_attack = null

var set_anim: String = "idleanimation"
var playing_anim: String = ""

var player: Player1P
var last_player_pos

var nav: Navigation
var path_pos: int = -1
var path: PoolVector3Array = []

onready var arm_lower_left_hit_box: HitBox = $animeboyfriend/Skeleton/ArmLowerLeftAttachment/HitBox
onready var arm_upper_left_hit_box: HitBox = $animeboyfriend/Skeleton/ArmUpperLeftAttachment/HitBox
onready var hand_left_hit_box: HitBox = $animeboyfriend/Skeleton/HandLeftAttachment/HitBox

onready var arm_lower_right_hit_box: HitBox = $animeboyfriend/Skeleton/ArmLowerRightAttachment/HitBox
onready var arm_upper_right_hit_box: HitBox = $animeboyfriend/Skeleton/ArmUpperRightAttachment/HitBox
onready var hand_right_hit_box: HitBox = $animeboyfriend/Skeleton/HandRightAttachment/HitBox

const MAX_SPIN: float = 45.0
var spin: float = 0
var spin_velocity: Vector3
const SPIN_BOOST: float = 30.0
var spin_boosts_left: int

var spin_hurt_boxes_open = false
onready var spin_hurt_boxes = [
	arm_lower_left_hit_box,
	arm_upper_left_hit_box,
	hand_left_hit_box,
	arm_lower_right_hit_box,
	arm_upper_right_hit_box,
	hand_right_hit_box
]

enum BiKickState {
	JUMP,
	KICKING,
	LANDING
}
var bi_kick_state = BiKickState.JUMP

onready var shield_body: ShieldBody = $ShieldBody
onready var shield_pos = shield_body.transform
var guard_has_launched: bool = false

const IDEAL_DISTANCE: int = 10

func _ready():
	nav = get_tree().root.get_node("Arena/Navigation")
	shield_body.add_collision_exception_with(self)
	
	var players = get_tree().get_nodes_in_group("player1p")
	if players.size() > 0:
		player = players[0]
		last_player_pos = player.global_transform.origin

func _process(_delta):
	if set_anim != playing_anim:
		$AnimationPlayer.play(set_anim)
		playing_anim = set_anim

func _physics_process(_delta):
	match state:
		State.FOLLOW:
			var player_pos: Vector3 = player.global_transform.origin
			var distance_squared = global_transform.origin.distance_squared_to(player_pos)
			
			if distance_squared < IDEAL_DISTANCE*IDEAL_DISTANCE:
				var choosen_state = -1

				while choosen_state == -1:
					var possible_states = [
						State.SPIN,
						State.BI_KICK,
						State.GUARD
					]
					var i = randi()%possible_states.size()
					var rand_state = possible_states[i]
					if rand_state != last_attack:
						last_attack = rand_state
						choosen_state = rand_state

				match choosen_state:
					State.SPIN:
						spin = 0
						state = State.SPIN
						spin_boosts_left = 2 + randi()%4
					State.BI_KICK:
						state = State.BI_KICK
						bi_kick_state = BiKickState.JUMP
					State.GUARD:
						state = State.GUARD
						guard_has_launched = false
				return

			if path_pos == -1 || last_player_pos.distance_squared_to(player_pos) > 2*2:
				path = nav.get_simple_path(
					nav.get_closest_point(global_transform.origin), 
					nav.get_closest_point(player_pos))
				path_pos = 0
				last_player_pos = player_pos

			if path.size() > path_pos:
				var next_point: Vector3 = path[path_pos]
				next_point.y = global_transform.origin.y

				if global_transform.origin.distance_squared_to(next_point) < 1:
					path_pos += 1
				else:
					var dir = (next_point - global_transform.origin).normalized()
					var dir_angle = atan2(dir.x, dir.z)

					rotation.y = lerp_angle(rotation.y, dir_angle, 0.3)
					
					move_and_slide(dir*8, Vector3.UP)
			else:
				path_pos = -1

			set_anim = "runanim"
		State.SPIN:
			set_anim = "spinattack"

			spin = min(MAX_SPIN, lerp(spin, MAX_SPIN, 0.05))
			rotation_degrees.y += spin

			if abs(spin - MAX_SPIN) < 1:
				if !spin_hurt_boxes_open:
					for hurt_box in spin_hurt_boxes:
						hurt_box.hurt_box_open()
					spin_hurt_boxes_open = true

				if spin_velocity.length_squared() < 0.1*0.1:
					if spin_boosts_left == 0:
						spin_velocity = Vector3.ZERO
						for hurt_box in spin_hurt_boxes:
							hurt_box.hurt_box_close()
						spin_hurt_boxes_open = false

						state = State.FOLLOW
						return

					spin_boosts_left -= 1
					var player_pos: Vector3 = player.global_transform.origin
					spin_velocity += (player_pos - global_transform.origin).normalized()*SPIN_BOOST

				spin_velocity = move_and_slide(spin_velocity, Vector3.UP)
				spin_velocity = spin_velocity.move_toward(Vector3.ZERO, 0.4)
		State.BI_KICK:
			match bi_kick_state:
				BiKickState.JUMP:
					var dir = (player.global_transform.origin - global_transform.origin).normalized()
					var dir_angle = atan2(dir.x, dir.z)
					rotation.y = lerp_angle(rotation.y, dir_angle, 0.4)

					set_anim = "bikickjump"
					if playing_anim == "bikickjump" and !$AnimationPlayer.is_playing():
						bi_kick_state = BiKickState.KICKING
						$BiKickTimer.start()
				BiKickState.KICKING:
					set_anim = "bikick"
					move_and_slide(global_transform.basis.z.normalized()*20)
				BiKickState.LANDING:
					set_anim = "bikickland"
					if playing_anim == "bikickland" and !$AnimationPlayer.is_playing():
						state = State.FOLLOW
		State.GUARD:
			set_anim = "guard"
			if !$ShieldAnimPlayer.is_playing():
				if !guard_has_launched:
					$ShieldAnimPlayer.play("shieldcharge")
					guard_has_launched = true

			var dir = (player.global_transform.origin - global_transform.origin).normalized()
			var dir_angle = atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, dir_angle, 0.4)

func close_all_hurt_boxes():
	var children = $animeboyfriend/Skeleton.get_children()
	for child in children:
		var hit_box = child.get_node_or_null("HitBox")
		if hit_box != null:
			hit_box.hurt_box_close()
	
func launch_shield():
	var pos = shield_body.global_transform
	remove_child(shield_body)
	get_tree().root.add_child(shield_body)
	shield_body.global_transform = pos
	
	shield_body.release(funcref(self, "on_shield_hit"))

func on_shield_hit():
	shield_body.get_parent().remove_child(shield_body)
	add_child(shield_body)
	shield_body.transform = shield_pos
	shield_body.reset()
	
	state = State.FOLLOW

func _on_hit(id, dmg):
	match id.strip_edges():
		"head":
			dmg *= 1.3
		"leg lower right", "leg upper right", "leg lower left", "leg upper left", "arm upper right", "arm lower right", "arm upper left", "arm lower left":
			dmg *= 0.9
		"foot right", "foot_left":
			dmg *= 0.85
	
	hp -= dmg

func _on_hurt(id, player):
	print(id)
	match id.strip_edges():
		"foot right", "foot_left":
			player.damage(20, 20, global_transform.basis.z)
		"hand left", "hand right", "arm lower left", "arm lower right":
			var dif = global_transform.origin - player.global_transform.origin
			dif.y = 0
			player.damage(10, 20, -dif.normalized())

func _on_BiKickTimer_timeout():
	if bi_kick_state == BiKickState.KICKING:
		bi_kick_state = BiKickState.LANDING
