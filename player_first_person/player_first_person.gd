extends KinematicBody

const SPEED = 6.0
const ACCELERATION = 0.8
const JUMP_VELOCITY = 4.5

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

var velocity = Vector3(0, 0, 0)

func _ready():
	aim_cast.add_exception(self)

	update_ammo_display()
	crosshair.set_seperation(target_sep)

func _input(event):
	if event is InputEventMouseMotion:
		camera_pivot_h.rotation.y -= event.relative.x*0.001
		camera_verticle_rot = clamp(camera_verticle_rot - event.relative.y*0.001, -deg2rad(90.0), deg2rad(90.0))
		camera_pivot_v.rotation.x = camera_verticle_rot

func _process(delta):
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
	
func _physics_process(delta):
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
	
	velocity = move_and_slide(velocity, Vector3.UP)

	if aim_cast.is_colliding():
		$Test.global_transform.origin = aim_cast.get_collision_point()

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
	var colliding_with = aim_cast.get_collider()
	if colliding_with != null:
		print("Hit ", colliding_with)

func _on_PPSH_on_reloaded():
	update_ammo_display()
