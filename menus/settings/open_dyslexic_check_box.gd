extends CheckBox

func _ready():
	pressed = GlobalSettings.open_dyslexia

func _on_OpenDyslexicCheckbox_pressed():
	GlobalSettings.open_dyslexia = pressed
	GlobalSettings.notify()
