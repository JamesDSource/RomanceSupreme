extends Node

var open_dyslexia: bool = false
var open_dyslexia_font: Font = null
var open_dyslexia_menu_font: Font = null

func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS)
	open_dyslexia_font = load("res://assets/fonts/open_dyslexic.tres")
	open_dyslexia_menu_font = load("res://assets/fonts/open_dyslexic_menu.tres")
	OS.window_fullscreen = false

func notify():
	var aware_nodes: Array = get_tree().get_nodes_in_group("settings_aware")
	for node in aware_nodes:
		if(node.has_method("_settings_changed")):
			node._settings_changed()
