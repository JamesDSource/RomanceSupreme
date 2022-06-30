extends Boss

enum State {
	FOLLOW,
	CHARGE_OVERHEAD_SWING,
	OVERHEAD_SWING,
	HORIZONTAL_SWING,
	KICK
}
var state = State.FOLLOW

var is_axeup: bool = false

var player: Player1P
var last_player_pos

onready var anim_player1 = $AnimationPlayer
onready var anim_player2 = $AnimationPlayer2

var set_anim1: String = ""
var anim_playing1: String = ""
var set_anim2: String = ""
var anim_playing2: String = ""

const OVERHEAD_CHARGE_COOLDOWN: float = 6.0
var overhead_charge_cooldown_left: float = OVERHEAD_CHARGE_COOLDOWN

var nav: Navigation
var path_pos: int = -1
var path: PoolVector3Array = []

func _ready():
	var players = get_tree().get_nodes_in_group("player1p")
	if players.size() > 0:
		player = players[0]
	
	nav = get_tree().root.get_node("Arena/Navigation")

func _process(delta):
	if set_anim1 != anim_playing1:
		if set_anim1 == "":
			anim_player1.stop()
		else:
			anim_player1.play(set_anim1)
		anim_playing1 = set_anim1

	if set_anim2 != anim_playing2:
		if set_anim2 == "":
			anim_player2.stop()
		else:
			anim_player2.play(set_anim2)
		anim_playing2 = set_anim2

func _physics_process(delta):
	var player_pos = player.global_transform.origin
	var dis_sqr = player_pos.distance_squared_to(global_transform.origin)

	match state:
		State.FOLLOW:
			set_anim1 = "armswing"
			set_anim2 = "walk"
			follow_player(5)

			if overhead_charge_cooldown_left > 0:
				overhead_charge_cooldown_left -= delta
			elif dis_sqr > 6*6:
				state = State.CHARGE_OVERHEAD_SWING
				overhead_charge_cooldown_left = OVERHEAD_CHARGE_COOLDOWN
			
			if dis_sqr <= 1*1:
				var possible_attacks = [
					State.HORIZONTAL_SWING,
					State.KICK
				]

				state = possible_attacks[randi()%possible_attacks.size()]

				match state:
					State.CHARGE_OVERHEAD_SWING:
						is_axeup = false
						$ChargeTimer.start()

		State.CHARGE_OVERHEAD_SWING:
			if is_axeup:
				set_anim1 = "chargingoverhead"
				set_anim2 = "walk"
				follow_player(9)
				if dis_sqr < 2*2:
					state = State.OVERHEAD_SWING
			else:
				set_anim1 = "axeup"
				set_anim2 = ""

		State.OVERHEAD_SWING:
			set_anim1 = "overheadswing"
			set_anim2 = ""
		State.HORIZONTAL_SWING:
			set_anim1 = "swing"
			set_anim2 = ""
		State.KICK:
			set_anim1 = "kick"
			set_anim2 = ""

func follow_player(speed: float):
	var player_pos = player.global_transform.origin

	if path_pos == -1 || last_player_pos.distance_squared_to(player_pos) > 2*2:
		path = nav.get_simple_path(

			nav.get_closest_point(global_transform.origin), 
			nav.get_closest_point(player_pos))
		path_pos = 0
		last_player_pos = player_pos

	if path.size() > path_pos:
		var next_point: Vector3 = path[path_pos]
		next_point.y = global_transform.origin.y

		if global_transform.origin.distance_squared_to(next_point) < 0.2*0.2:
			path_pos += 1
		else:
			var dir = (next_point - global_transform.origin).normalized()
			var dir_angle = atan2(dir.x, dir.z)

			rotation.y = lerp_angle(rotation.y, dir_angle, 0.3)
			
			move_and_slide(dir*speed, Vector3.UP)

func _on_hit(id, dmg):
	if state == State.CHARGE_OVERHEAD_SWING:
		dmg *= 0.5

	match id:
		_:
			pass

	hp -= dmg

func _on_hurt(id, player):
	match state:
		State.OVERHEAD_SWING:
			player.damage(40, 20, global_transform.basis.z)
		State.HORIZONTAL_SWING:
			player.damage(25, 15, global_transform.basis.z)
		State.KICK:
			player.damage(10, 30, global_transform.basis.z)

func _on_AnimationPlayer_animation_finished(anim_name:String):
	match anim_name:
		"axeup":
			is_axeup = true
		"overheadswing":
			if state == State.OVERHEAD_SWING:
				state= State.FOLLOW
		"swing":
			if state == State.HORIZONTAL_SWING:
				state= State.FOLLOW
		"kick":
			if state == State.KICK:
				state= State.FOLLOW

func _on_ChargeTimer_timeout():
	if state == State.CHARGE_OVERHEAD_SWING:
		state = State.OVERHEAD_SWING
