extends CheckBox

func _on_OpenDyslexicCheckbox_pressed():
	GlobalSettings.open_dyslexia = pressed
	GlobalSettings.notify()
