extends CharacterBody3D

const SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera_pivot: Node3D
var camera_verticle_rot: float = 0

func _ready():
	camera_pivot = $CameraPivot

func _input(event):
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y -= event.relative.x*0.001
		camera_verticle_rot = clampf(camera_verticle_rot + event.relative.y*0.001, -.5, .5)
		camera_pivot.rotation.x = camera_verticle_rot

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()