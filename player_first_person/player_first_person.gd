extends KinematicBody

const SPEED = 6.0
const ACCELERATION = 0.8
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

onready var camera_pivot: Spatial = $CameraPivot
var camera_verticle_rot: float = 0

onready var crosshair: Crosshair = $CameraPivot/Camera/HUD/Crosshair
const IDLE_CROSSHAIR_SEP = 75
const FIRED_CROSSHAIR_SEP_STEP = 10
const MAX_CROSSHAIR_SEP = 160

onready var gun_anim: AnimationPlayer = $CameraPivot/PPSH/AnimationPlayer

var adsing: bool = false
var reloading: bool = false
const FIRE_DELAY: float = .12
var fire_timer: float = FIRE_DELAY

const AMMO_CLIP_MAX = 70
const AMMO_RESERVE_MAX = 210
var ammo_clip = AMMO_CLIP_MAX
var ammo_reserve = AMMO_RESERVE_MAX

var velocity = Vector3(0, 0, 0)

func _ready():
	gun_anim.play("firing")

func _input(event):
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y -= event.relative.x*0.001
		camera_verticle_rot = clamp(camera_verticle_rot - event.relative.y*0.001, -deg2rad(90.0), deg2rad(90.0))
		camera_pivot.rotation.x = camera_verticle_rot

func _process(delta):
	fire_timer = max(0, fire_timer - delta)

	if Input.is_action_pressed("shoot") and fire_timer <= 0 and ammo_clip > 0 and !reloading:
		gun_anim.play("firing")
		ammo_clip -= 1
		update_ammo_display()
		fire_timer = FIRE_DELAY
	elif ammo_clip < AMMO_CLIP_MAX and Input.is_action_just_pressed("reload") and !reloading:
		gun_anim.play("reload")
		reloading = true
	elif reloading and !gun_anim.is_playing():
		var ammo_needed = AMMO_CLIP_MAX - ammo_clip
		ammo_clip += min(ammo_needed, ammo_reserve)
		ammo_reserve = max(0, ammo_reserve - ammo_needed)
		update_ammo_display()
		reloading = false

	if Input.is_action_pressed("ads") and !adsing:
		$AnimationPlayer.play("ads")
		crosshair.visible = false
		adsing = true
	elif !Input.is_action_pressed("ads") and adsing:
		$AnimationPlayer.play_backwards("ads")
		crosshair.visible = true
		adsing = false

func _physics_process(delta):
	velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var target_velocity = Vector3(0, 0, 0)
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		target_velocity.x = direction.x * SPEED
		target_velocity.z = direction.z * SPEED
	
	var y = velocity.y
	velocity = velocity.move_toward(target_velocity, ACCELERATION)
	velocity.y = y
	
	velocity = move_and_slide(velocity, Vector3.UP)

func update_ammo_display():
	$CameraPivot/Camera/HUD/AmmoCount.text = str(ammo_clip) + "/" + str(ammo_reserve)
