extends NinePatchRect
class_name TextBox

export(float) var speed: float = 20

const DIALOG_ANCHOR_LEFT: float = 0.1
const DIALOG_ANCHOR_TOP: float = 0.7
const DIALOG_ANCHOR_RIGHT: float = 0.9
const DIALOG_ANCHOR_BOTTOM: float = 0.9

const CHOICE_ANCHOR_LEFT: float = 0.35
const CHOICE_ANCHOR_TOP: float = 0.4
const CHOICE_ANCHOR_RIGHT: float = 0.65
const CHOICE_ANCHOR_BOTTOM: float = 0.9

var choice_index: int = -1

enum TextBoxMode {
	Dialog,
	Choice
}

var text_node: RichTextLabel
var choices_container: VBoxContainer

func _ready():
	text_node = $DialogText
	choices_container = $ChoicesContainer
	TextBoxController.set_text_box_node(self)

func _process(delta):
	if(text_node.percent_visible < 1 and text_node.text.length() > 0):
		text_node.percent_visible += (1.0/text_node.text.length())*speed*delta

func set_mode(mode):
	match(mode):
		TextBoxMode.Dialog:
			anchor_left = DIALOG_ANCHOR_LEFT
			anchor_top = DIALOG_ANCHOR_TOP
			anchor_right = DIALOG_ANCHOR_RIGHT
			anchor_bottom = DIALOG_ANCHOR_BOTTOM
			text_node.visible = true
			choices_container.visible = false
		TextBoxMode.Choice:
			anchor_left = CHOICE_ANCHOR_LEFT
			anchor_top = CHOICE_ANCHOR_TOP
			anchor_right = CHOICE_ANCHOR_RIGHT
			anchor_bottom = CHOICE_ANCHOR_BOTTOM
			choices_container.visible = true
			text_node.visible = false

func set_choice_index(index):
	var children = choices_container.get_children()
	if(choice_index != -1):
		children[choice_index].add_color_override("font_color", Color.white)
	children[index].add_color_override("font_color", Color.yellow)
	choice_index = index
