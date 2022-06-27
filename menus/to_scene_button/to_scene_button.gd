extends "res://menus/menu_button.gd"

export(String, FILE) var scene

func _on_ToSceneButton_pressed():
	InputState.mouse_needed = 0
	get_tree().change_scene(scene)
