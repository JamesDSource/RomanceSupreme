extends Node

var node = null

func set_text_box_node(node):
	self.node = node

func set_text(text: String):
	node.text_node.text = text
	node.text_node.percent_visible = 0

func set_text_box_visible(is_visible: bool):
	node.visible = is_visible
