extends KinematicBody
class_name Player1P

const SPEED = 6.0
const ACCELERATION = 0.8
const JUMP_VELOCITY = 4.5

var is_dead: bool = false

var jump_buffer: int = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

onready var camera_pivot_h: Spatial = $CameraPivotH
onready var camera_pivot_v: Spatial = $CameraPivotH/CameraPivotV
var camera_verticle_rot: float = 0

onready var crosshair: Crosshair = $CameraPivotH/CameraPivotV/Camera/HUD/Crosshair
const IDLE_CROSSHAIR_SEP = 75
const FIRED_CROSSHAIR_SEP_STEP = 10
const MAX_CROSSHAIR_SEP = 160
var target_sep = IDLE_CROSSHAIR_SEP

onready var ppsh = $CameraPivotH/CameraPivotV/PPSH
onready var aim_cast: RayCast = $CameraPivotH/CameraPivotV/Camera/AimCast

var adsing: bool = false

var velocity = Vector3.ZERO
var knockback_vel = Vector3.ZERO
var dash_vel = Vector3.ZERO

const HP_MAX: int = 100
var hp: int = HP_MAX
onready var health_bar: ProgressBar = $CameraPivotH/CameraPivotV/Camera/HUD/Health
var iframes: float = 0

const DASH_COUNT: int = 2
const DASH_SPEED: float = 50.0
var dashes_left = DASH_COUNT

onready var dash1_rect: ColorRect = $CameraPivotH/CameraPivotV/Camera/HUD/Dash1
onready var dash2_rect: ColorRect = $CameraPivotH/CameraPivotV/Camera/HUD/Dash2

export var dash_free_color: Color
export var dash_used_color: Color

onready var boss_name: Label = $CameraPivotH/CameraPivotV/Camera/HUD/BossName
onready var boss_health: ProgressBar = $CameraPivotH/CameraPivotV/Camera/HUD/BossHealth
var boss: Boss = null

func _ready():
	aim_cast.add_exception(self)

	update_ammo_display()
	crosshair.set_seperation(target_sep)

	hp_display_update()

func _input(event):
	if is_dead:
		return

	if event is InputEventMouseMotion:
		camera_pivot_h.rotation.y -= event.relative.x*0.001
		camera_verticle_rot = clamp(camera_verticle_rot - event.relative.y*0.001, -deg2rad(90.0), deg2rad(90.0))
		camera_pivot_v.rotation.x = camera_verticle_rot

func _process(delta):
	if is_dead:
		return
	elif iframes > 0:
		iframes -= delta

	if Input.is_action_pressed("ads") and !adsing:
		$AnimationPlayer.play("ads")
		crosshair.visible = false
		adsing = true
	elif !Input.is_action_pressed("ads") and adsing:
		$AnimationPlayer.play_backwards("ads")
		crosshair.visible = true
		adsing = false
	
	crosshair.seperation = lerp(crosshair.seperation, target_sep, .1)
	if !Input.is_action_pressed("shoot"):
		target_sep = lerp(target_sep, IDLE_CROSSHAIR_SEP, .5)
	
	dash1_rect.color = dash_free_color if dashes_left > 0 else dash_used_color
	dash2_rect.color = dash_free_color if dashes_left > 1 else dash_used_color

	if !is_instance_valid(boss):
		var bosses = get_tree().get_nodes_in_group("boss")
		if bosses.size() > 0:
			boss = bosses[0]
			boss_name.text = boss.boss_name
	else:
		boss_health.value = 100*(boss.hp*1.0/boss.hp_max)
	
func _physics_process(delta):
	if is_dead:
		return

	velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer = 5
	else:
		jump_buffer = int(max(0, jump_buffer - 1))

	if jump_buffer > 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var target_velocity = Vector3(0, 0, 0)
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (camera_pivot_h.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		target_velocity.x = direction.x * SPEED
		target_velocity.z = direction.z * SPEED
	
	var y = velocity.y
	velocity = velocity.move_toward(target_velocity, ACCELERATION)
	velocity.y = y
	
	if Input.is_action_just_pressed("dash") and direction and dashes_left > 0:
		if $DashRecharge.is_stopped():
			$DashRecharge.start()

		dashes_left -= 1
		dash_vel = direction*DASH_SPEED
	else:
		dash_vel = lerp(dash_vel, Vector3.ZERO, .1)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	knockback_vel = move_and_slide(knockback_vel, Vector3.UP)
	knockback_vel = lerp(knockback_vel, Vector3.ZERO, 0.1)
	dash_vel = move_and_slide(dash_vel, Vector3.UP)

	if aim_cast.is_colliding():
		$Test.global_transform.origin = aim_cast.get_collision_point()

func damage(amount: int, knockback: float, dir: Vector3):
	if iframes > 0:
		return
	else:
		iframes = .2

	hp -= amount
	if hp <= 0 :
		var second_chance: int = randi()%3 + 2
		if hp + second_chance <= 0:
			is_dead = true
			ppsh.state = ppsh.State.DEACTIVE
			hp = 0
			hp_display_update()
			return
		else:
			hp += second_chance
	
	knockback_vel += dir*knockback

	hp_display_update()

func heal(amount: int):
	hp_display_update()

func hp_display_update():
	health_bar.value = hp

func update_ammo_display():
	var ammo_clip = $CameraPivotH/CameraPivotV/PPSH.ammo_clip
	var ammo_reserve = $CameraPivotH/CameraPivotV/PPSH.ammo_reserve
	$CameraPivotH/CameraPivotV/Camera/HUD/AmmoCount.text = str(ammo_clip) + "/" + str(ammo_reserve)

func _on_PPSH_on_fire():
	update_ammo_display()

	if adsing:
		aim_cast.cast_to.x = 0
		aim_cast.cast_to.y = 0
	else:
		target_sep = min(target_sep + FIRED_CROSSHAIR_SEP_STEP, MAX_CROSSHAIR_SEP)
		var sep = (crosshair.seperation/MAX_CROSSHAIR_SEP)*12
		aim_cast.cast_to.x = -sep/2 + randf()*sep
		aim_cast.cast_to.y = -sep/2 + randf()*sep

	aim_cast.force_raycast_update()
	var colliding_with: Spatial = aim_cast.get_collider()
	if colliding_with != null and colliding_with.is_in_group("hit box"):
		colliding_with.shot(10)

func _on_PPSH_on_reloaded():
	update_ammo_display()

func _on_DashRecharge_timeout():
	dashes_left += 1

	if dashes_left < 2:
		$DashRecharge.start()
