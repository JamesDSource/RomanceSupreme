extends Boss

enum State {
	FOLLOW,
	SPIN,
	BI_KICK,
	GUARD
}
var state = State.FOLLOW

var set_anim: String = "idleanimation"
var playing_anim: String = ""

var player: Player1P
var last_player_pos

var nav: Navigation
var path_pos: int = -1
var path: PoolVector3Array = []

const MAX_SPIN: float = 45.0
var spin: float = 0
var spin_velocity: Vector3

onready var arm_lower_left_hit_box: HitBox = $animeboyfriend/Skeleton/ArmLowerLeftAttachment/HitBox
onready var arm_upper_left_hit_box: HitBox = $animeboyfriend/Skeleton/ArmUpperLeftAttachment/HitBox
onready var hand_left_hit_box: HitBox = $animeboyfriend/Skeleton/HandLeftAttachment/HitBox

onready var arm_lower_right_hit_box: HitBox = $animeboyfriend/Skeleton/ArmLowerRightAttachment/HitBox
onready var arm_upper_right_hit_box: HitBox = $animeboyfriend/Skeleton/ArmUpperRightAttachment/HitBox
onready var hand_right_hit_box: HitBox = $animeboyfriend/Skeleton/HandRightAttachment/HitBox

var spin_hurt_boxes_open = false
onready var spin_hurt_boxes = [
	arm_lower_left_hit_box,
	arm_upper_left_hit_box,
	hand_left_hit_box,
	arm_lower_right_hit_box,
	arm_upper_right_hit_box,
	hand_right_hit_box
]

const IDEAL_DISTANCE: int = 10

func _ready():
	nav = get_tree().root.get_node("Arena/Navigation")
	
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
				spin = 0
				state = State.SPIN

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

			if abs(spin - MAX_SPIN) < 1 and !spin_hurt_boxes_open:
				for hurt_box in spin_hurt_boxes:
					hurt_box.hurt_box_open()
				spin_hurt_boxes_open = true
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
	
	hp -= dmg

func _on_hurt(id, player):
	print(id)
	match id.strip_edges():
		"foot right", "foot_left":
			player.damage(0, 20, global_transform.basis.z)
		"hand left", "hand right", "arm lower left", "arm lower right":
			var dif = global_transform.origin - player.global_transform.origin
			dif.y = 0
			player.damage(0, 20, -dif.normalized())
