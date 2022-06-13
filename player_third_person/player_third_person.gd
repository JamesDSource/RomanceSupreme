extends KinematicBody

const MAX_SPEED = 3.0
const ACCELERATION = 0.2

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera_pivot: Spatial
var camera_verticle_rot: float = 0

var velocity = Vector3(0, 0, 0)
var dir_angle: float = 0

var lock_movement: bool = false

onready var player_model: Spatial = $PlayerModel

func _ready():
	add_to_group("player3p")
	camera_pivot = $CameraPivot

func _input(event):
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y -= event.relative.x*0.001
		camera_verticle_rot = clamp(camera_verticle_rot - event.relative.y*0.001, -.5, .5)
		camera_pivot.rotation.x = camera_verticle_rot

func _physics_process(delta):
	if(lock_movement):
		return

	# Add the gravity.
	if(!is_on_floor()):
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		dir_angle = rad2deg(atan2(-direction.z, direction.x))
		velocity.x = direction.x * MAX_SPEED
		velocity.z = direction.z * MAX_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_SPEED)
		velocity.z = move_toward(velocity.z, 0, MAX_SPEED)

	velocity = move_and_slide(velocity, Vector3.UP)

	var cur_angle = player_model.rotation_degrees.y

	var dif1 = dir_angle - cur_angle
	var dif2 = -cur_angle - (360 - dir_angle)
	var best_dif = dif1 if abs(dif1) < abs(dif2) else dif2
	player_model.rotation_degrees.y += best_dif/10
