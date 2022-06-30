extends Boss

onready var skell_a: SkellA = $SkellA
onready var skell_b: SkellB = $SkellB
var phase: int = 0
var mounted: bool = false
var skell_a_available_to_mount: bool = false

var player: Player1P
var last_player_pos = null

enum SkellAState {
	FOLLOW,
	FIRE_BUBBLE,
	SWEEP,
	MOUNTING
}
var skell_a_state = SkellAState.FOLLOW
var skell_a_moving: bool = false

const SKELL_A_ATTACK_COOLDOWNS = [3.0, 2.0]
var skell_a_attack_cooldown_left: float = SKELL_A_ATTACK_COOLDOWNS[0]

var skell_a_path: PoolVector3Array
var skell_a_path_index: int = -1

enum SkellBState {
	FOLLOW,
	FIRE_BOLT,
	MOUNTING,
	MOUNTED,
	FIRE_BOLT_MOUNTED
}
var skell_b_state = SkellBState.FOLLOW
var skell_b_moving: bool = false

var skell_b_path: PoolVector3Array
var skell_b_path_index: int = -1

var skell_b_path_to_a: PoolVector3Array
var skell_b_path_to_a_index = -1
var skell_a_last_pos: Vector3

const SKELL_B_ATTACK_COOLDOWNS = [2.0, 0.5]
var skell_b_attack_cooldown_left: float = SKELL_A_ATTACK_COOLDOWNS[0]

var nav: Navigation

func _ready():
	nav = get_tree().root.get_node("Arena/Navigation")

	var players = get_tree().get_nodes_in_group("player1p")
	if players.size() > 0:
		player = players[0]
		last_player_pos = player.global_transform.origin

func _physics_process(delta):
	var player_pos = player.global_transform.origin
	if last_player_pos == null || last_player_pos.distance_squared_to(player_pos) > 2*2:
		skell_a_path = nav.get_simple_path(
			nav.get_closest_point(skell_a.global_transform.origin),
			nav.get_closest_point(player_pos))
		skell_a_path_index = 0

		skell_b_path = nav.get_simple_path(
			nav.get_closest_point(skell_b.global_transform.origin),
			nav.get_closest_point(player_pos))
		skell_b_path_index = 0

		last_player_pos = player_pos
	
	skell_a_state_machine(delta)
	skell_b_state_machine(delta)

func skell_a_state_machine(delta):
	var player_pos: Vector3 = player.global_transform.origin
	match skell_a_state:
		SkellAState.FOLLOW:
			if phase == 1 and !mounted:
				skell_a_state = SkellAState.MOUNTING
				return

			var dis_sqr: float = skell_a.global_transform.origin.distance_squared_to(player_pos)

			skell_a.set_anim1 = "armswing"
			if skell_a_moving:
				if dis_sqr < 5*5:
					skell_a_moving = false
				skell_a_path_index = follow_along_path(skell_a_path, skell_a_path_index, skell_a)
				skell_a.set_anim2 = "walk"
			else:
				if dis_sqr > 8*8:
					skell_a_moving = true

				var dir = (player_pos - skell_a.global_transform.origin).normalized()
				var dir_angle = atan2(-dir.x, -dir.z)
				skell_a.rotation.y = lerp_angle(skell_a.rotation.y, dir_angle, 0.3)

				skell_a.set_anim2 = "legsidle"

			if skell_a_attack_cooldown_left > 0:
				skell_a_attack_cooldown_left -= delta
			elif dis_sqr < 10*10:
				if phase == 0:
					skell_a_state = SkellAState.FIRE_BUBBLE
				elif phase == 1:
					var possible_states = [
						SkellAState.FIRE_BUBBLE,
						SkellAState.SWEEP
					]
					skell_a_state = possible_states[randi()%possible_states.size()]

				skell_a_attack_cooldown_left = SKELL_A_ATTACK_COOLDOWNS[phase]
		SkellAState.FIRE_BUBBLE:
			skell_a.set_anim1 = "spell1"
			skell_a.set_anim2 = "legsidle"

			if skell_a.anim_playing1 == "spell1" and !skell_a.anim_player1.is_playing():
				skell_a_state = SkellAState.FOLLOW
		SkellAState.SWEEP:
			skell_a.set_anim1 = "spell2"
			skell_a.set_anim2 = "legsidle"

			if skell_a.anim_playing1 == "spell2" and !skell_a.anim_player1.is_playing():
				skell_a_state = SkellAState.FOLLOW
		SkellAState.MOUNTING:
			if !skell_a_available_to_mount and !mounted:
				skell_a.set_anim1 = "getdown"
				skell_a.set_anim2 = ""

				if skell_a.anim_playing1 == "getdown" and !skell_a.anim_player1.is_playing():
					skell_a_available_to_mount = true
			elif mounted and skell_a.anim_playing1 == "getdown":
				skell_a.set_anim1 = "getup"
			elif skell_a.anim_playing1 == "getup" and !skell_a.anim_player1.is_playing():
				skell_a_state = SkellAState.FOLLOW

func skell_b_state_machine(delta):
	var player_pos: Vector3 = player.global_transform.origin
	match skell_b_state:
		SkellBState.FOLLOW:
			if phase == 1 and !mounted:
				skell_b_state = SkellBState.MOUNTING
				return

			var dis_sqr: float = skell_b.global_transform.origin.distance_squared_to(player_pos)

			skell_b.set_anim1 = "armswing"
			if skell_b_moving:
				if dis_sqr < 2*2:
					skell_b_moving = false
				skell_b_path_index = follow_along_path(skell_b_path, skell_b_path_index, skell_b)
				skell_b.set_anim2 = "walk"
			else:
				if dis_sqr > 3*3:
					skell_b_moving = true

				var dir = (player_pos - skell_b.global_transform.origin).normalized()
				var dir_angle = atan2(-dir.x, -dir.z)
				skell_b.rotation.y = lerp_angle(skell_b.rotation.y, dir_angle, 0.3)

				skell_b.set_anim2 = "legsidle"

			print(skell_b_attack_cooldown_left)
			if skell_b_attack_cooldown_left > 0:
				skell_b_attack_cooldown_left -= delta
			elif dis_sqr < 5*5:
				skell_b_state = SkellBState.FIRE_BOLT
				skell_b_attack_cooldown_left = SKELL_B_ATTACK_COOLDOWNS[0]
		SkellBState.FIRE_BOLT:
			skell_b.set_anim1 = "spell1"
			skell_b.set_anim2 = "legsidle"

			if skell_b.anim_playing1 == "spell1" and !skell_b.anim_player1.is_playing():
				skell_b_state = SkellBState.FOLLOW
		SkellBState.MOUNTING:
			var dis_sqr: float = skell_a.global_transform.origin.distance_squared_to(skell_b.global_transform.origin)
			skell_b.set_anim1 = "armswing"
			if dis_sqr > 1:
				skell_b.set_anim2 = "walk"

				if skell_b_path_to_a_index == -1 or skell_a_last_pos.distance_squared_to(skell_a.global_transform.origin) > 1:
					skell_b_path_to_a = nav.get_simple_path(
						nav.get_closest_point(skell_b.global_transform.origin),
						nav.get_closest_point(skell_a.global_transform.origin))
					skell_b_path_to_a_index = 0
					skell_a_last_pos = skell_a.global_transform.origin

				skell_b_path_to_a_index = follow_along_path(skell_b_path_to_a, skell_b_path_to_a_index, skell_b)
			else:
				skell_b.set_anim2 = "legsidle"
				if skell_a_available_to_mount:
					mounted = true
					skell_a.add_collision_exception_with(skell_b)
					skell_b.add_collision_exception_with(skell_a)
					skell_b_state = SkellBState.MOUNTED
		SkellBState.MOUNTED:
			skell_b.global_transform.origin = skell_a.mount.global_transform.origin
			skell_b.rotation = skell_a.rotation
			skell_b.set_anim1 = "armswing"
			skell_b.set_anim2 = "mounted"

			if skell_b_attack_cooldown_left > 0:
				skell_b_attack_cooldown_left -= delta
			else:
				skell_b_state = SkellBState.FIRE_BOLT_MOUNTED
				skell_b_attack_cooldown_left = SKELL_B_ATTACK_COOLDOWNS[1]
		SkellBState.FIRE_BOLT_MOUNTED:
			skell_b.global_transform.origin = skell_a.mount.global_transform.origin
			skell_b.rotation = skell_a.rotation
			skell_b.set_anim1 = "spell1"
			skell_b.set_anim2 = "mounted"

			if skell_b.anim_playing1 == "spell1" and !skell_b.anim_player1.is_playing():
				skell_b_state = SkellBState.MOUNTED


func follow_along_path(path: PoolVector3Array, path_pos: int, entity: KinematicBody) -> int:
	var pos = entity.global_transform.origin
	if path.size() > path_pos and path_pos >= 0:
		var next_point: Vector3 = path[path_pos]
		next_point.y = pos.y

		if pos.distance_squared_to(next_point) < 1:
			path_pos += 1
		else:
			var dir = (next_point - pos).normalized()
			var dir_angle = atan2(-dir.x, -dir.z)

			entity.rotation.y = lerp_angle(entity.rotation.y, dir_angle, 0.3)
			entity.move_and_slide(dir*8, Vector3.UP)
	return path_pos

func _on_hit(dmg):
	if skell_b_state == SkellBState.MOUNTING and skell_a_state == SkellAState.MOUNTING:
		dmg *= .1
	hp -= dmg
	
	if phase == 0 and hp < hp_max/2.0:
		phase = 1
