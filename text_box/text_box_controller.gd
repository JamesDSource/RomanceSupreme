extends Node

const CHOICE_LABEL = preload("res://text_box/choice_label.tscn")
var node: TextBox = null

func set_text_box_node(node_: TextBox):
	node = node_

func set_text(text: String):
	node.set_mode(TextBox.TextBoxMode.Dialog)
	node.text_node.text = text
	node.text_node.percent_visible = 0

func set_choices(choices: Array):
	node.set_mode(TextBox.TextBoxMode.Choice)
	var existing_children = node.choices_container.get_children()
	for child in existing_children:
		node.choices_container.remove_child(child)
		child.queue_free()
	
	for choice in choices:
		var inst = CHOICE_LABEL.instance()
		node.choices_container.add_child(inst)
		inst.text = choice
	
	node.choice_index = -1
	node.set_choice_index(0)

func choice_move_up():
	if(node.choice_index - 1 < 0):
		node.set_choice_index(node.choices_container.get_child_count() - 1)
	else:
		node.set_choice_index(node.choice_index - 1)

func choice_move_down():
	if(node.choice_index + 1 >= node.choices_container.get_child_count()):
		node.set_choice_index(0)
	else:
		node.set_choice_index(node.choice_index + 1)

func choice_select() -> int:
	return node.choice_index

func set_text_box_visible(is_visible: bool):
	node.visible = is_visible
