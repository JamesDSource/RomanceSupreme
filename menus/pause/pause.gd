extends Control

var is_paused = false

func _ready():
	$Selector.visible = false

func _process(delta):
	if(Input.is_action_just_pressed("pause")):
		toggle_pause()


func _on_ResumeButton_pressed():
	toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	$Selector.visible = is_paused
	get_tree().paused = is_paused
	if(is_paused):
		InputState.mouse_needed += 1
	else:
		InputState.mouse_needed -= 1
