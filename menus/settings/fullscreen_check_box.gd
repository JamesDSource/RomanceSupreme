extends CheckBox

func _ready():
	add_to_group("settings_aware", true)
	pressed = OS.window_fullscreen

func _on_FullscreenCheckBox_pressed():
	OS.window_fullscreen = pressed

func _settings_changed():
	if(GlobalSettings.open_dyslexia):
		add_font_override("font", GlobalSettings.open_dyslexia_menu_font)
	else:
		add_font_override("font", null)
