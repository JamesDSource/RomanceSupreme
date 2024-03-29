extends KinematicBody
class_name Player3P

const MAX_SPEED = 3.0
const ACCELERATION = 0.2

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum AnimationState {
	Idle,
	Walking
}
var anim_names: Array = [
	"idleanimation",
	"walkcycle"
]
var anim_state = AnimationState.Idle
var current_anim_state = null

var camera_pivot: Spatial
var camera_verticle_rot: float = 0

var velocity = Vector3.ZERO
var dir_angle: float = 0

var lock_movement: bool = false

onready var player_model: Spatial = $PlayerModel
onready var camera: Camera = $CameraPivot/SpringArm/Camera
onready var animation_player: AnimationPlayer = $PlayerModel/AnimationPlayer

var interactable = null

func _ready():
	camera_pivot = $CameraPivot

	if rotation_degrees.y != 0:
		player_model.rotation_degrees.y = rotation_degrees.y
		dir_angle = rotation_degrees.y
		rotation_degrees.y = 0
		camera_pivot.rotation.y = -rotation_degrees.y

	add_to_group("settings_aware", true)
	_settings_changed()

func _settings_changed():
	if(GlobalSettings.open_dyslexia):
		$ViewportContainer/InteractPrompt.add_font_override("font", GlobalSettings.open_dyslexia_menu_font)
	else:
		$ViewportContainer/InteractPrompt.add_font_override("font", null)

func _input(event):
	if event is InputEventMouseMotion and not lock_movement:
		camera_pivot.rotation.y -= event.relative.x*0.001
		camera_verticle_rot = clamp(camera_verticle_rot - event.relative.y*0.001, -.3, .3)
		camera_pivot.rotation.x = camera_verticle_rot

func _process(delta):
	if !lock_movement and interactable != null and Input.is_action_just_pressed("interact"):
		interactable._on_interact()

	if lock_movement:
		anim_state = AnimationState.Idle
	if current_anim_state != anim_state:
		animation_player.play(anim_names[anim_state])
		current_anim_state = anim_state
	
	$ViewportContainer/InteractPrompt.visible = !lock_movement

func _physics_process(delta):

	if(lock_movement):
		anim_state = AnimationState.Idle
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
		anim_state = AnimationState.Walking
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_SPEED)
		velocity.z = move_toward(velocity.z, 0, MAX_SPEED)
		anim_state = AnimationState.Idle

	velocity = move_and_slide(velocity, Vector3.UP)

	var cur_angle = player_model.rotation_degrees.y

	var dif = dir_angle - cur_angle
	var dt = clamp(dif - floor(dif/360)*360, 0, 360)
	var end = cur_angle + (dt - 360 if dt > 180 else dt)
	player_model.rotation_degrees.y += .1 + (end - cur_angle)*.1

func _on_InteractionArea_body_entered(body):
	if body.has_method("_on_interact") and interactable == null:
		interactable = body
		$ViewportContainer/InteractPrompt.text = "Press E: " + body._prompt

func _on_InteractionArea_body_exited(body):
	if body == interactable:
		interactable = null
		$ViewportContainer/InteractPrompt.text = ""
