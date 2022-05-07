extends Button

export(String) var redirect_to = ""
var selector: Control

func _ready():
	selector = get_parent().get_parent()

func _on_RedirectButton_pressed():
	selector.redirect(redirect_to)
