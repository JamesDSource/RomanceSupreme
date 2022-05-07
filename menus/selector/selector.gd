extends Control

export(NodePath) var default = null
var current_open: Control = null

func _ready():
	var children = get_children()
	for child in children:
		child.visible = false
	
	if(default != null):
		var default_node = get_node(default)
		default_node.visible = true
		current_open = default_node

func redirect(redirect_to: String):
	if(current_open != null):
		current_open.visible = false
		current_open = null
	
	var children = get_children()
	for child in children:
		if(child.name == redirect_to):
			child.visible = true
			current_open = child
			break
