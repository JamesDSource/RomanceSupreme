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

var adsing: bool = false

var velocity = Vector3(0, 0, 0)

func _ready():
	camera_pivot = $CameraPivot

func _input(event):
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y -= event.relative.x*0.001
		camera_verticle_rot = clamp(camera_verticle_rot - event.relative.y*0.001, -deg2rad(90.0), deg2rad(90.0))
		camera_pivot.rotation.x = camera_verticle_rot

func _process(_delta):
	if Input.is_action_pressed("shoot"):
		crosshair.set_seperation(min(crosshair.seperation + FIRED_CROSSHAIR_SEP_STEP, MAX_CROSSHAIR_SEP))
	else:
		crosshair.set_seperation(lerp(crosshair.seperation, IDLE_CROSSHAIR_SEP, 0.1))

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
