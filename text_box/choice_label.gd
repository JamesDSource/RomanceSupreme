extends Label

func _ready():
	add_to_group("settings_aware")
	
	_settings_changed()

func _settings_changed():
	if(GlobalSettings.open_dyslexia):
		add_font_override("font", GlobalSettings.open_dyslexia_menu_font)
	else:
		add_font_override("font", null)
