extends NinePatchRect

export var speed: float = 20

var text_node: RichTextLabel

func _ready():
	text_node = $RichTextLabel
	TextBoxController.set_text_box_node(self)

func _process(delta):
	if(text_node.percent_visible < 1 and text_node.text.length() > 0):
		text_node.percent_visible += (1.0/text_node.text.length())*speed*delta
