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

enum CharacterTalkType {
	None,
	Talk,
	Grunt
}
var talk_type: int = CharacterTalkType.None
var talk_sounds: Array = []

onready var text_node: RichTextLabel = $DialogText
onready var choices_node: Control = $Choices
onready var choices_container: VBoxContainer = $Choices/ChoicesContainer
onready var choices_header: Label = $Choices/Header
onready var dialog_audio: AudioStreamPlayer = $DialogAudioPlayer

var dialog_text_box: Texture = preload("res://assets/text_boxes/default_textbox.png")
var choice_text_box: Texture = preload("res://assets/text_boxes/default_textbox.png")

var dialog_font: DynamicFont = preload("res://assets/fonts/lemon_tea.tres")
var choice_font: DynamicFont = preload("res://assets/fonts/lemon_tea.tres")

func _ready():
	visible = false
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
			choices_node.visible = false

			set_text_box(dialog_text_box)
			$DialogText.theme.set_default_font(dialog_font)
		TextBoxMode.Choice:
			anchor_left = CHOICE_ANCHOR_LEFT
			anchor_top = CHOICE_ANCHOR_TOP
			anchor_right = CHOICE_ANCHOR_RIGHT
			anchor_bottom = CHOICE_ANCHOR_BOTTOM
			choices_node.visible = true
			text_node.visible = false

			set_text_box(choice_text_box)
			text_node.theme.set_default_font(choice_font)

func set_text_box(tex: Texture):
	texture = tex

	var w_div_3 = floor(tex.get_width()/3.0)
	region_rect = Rect2(0, 0, tex.get_width(), tex.get_height())
	patch_margin_top = w_div_3
	patch_margin_left = w_div_3
	patch_margin_right = w_div_3
	patch_margin_bottom = w_div_3

func set_choice_index(index):
	var children = choices_container.get_children()
	if(choice_index != -1):
		children[choice_index].add_color_override("font_color", Color.white)
	children[index].add_color_override("font_color", Color.yellow)
	choice_index = index

func _on_DialogAudioPlayer_finished():
	if talk_type == CharacterTalkType.Talk and text_node.percent_visible < 1:
		dialog_audio.pitch_scale = 1.0 + rand_range(-0.2, 0.2)
		dialog_audio.stream = talk_sounds[randi()%talk_sounds.size()]
		dialog_audio.play()
