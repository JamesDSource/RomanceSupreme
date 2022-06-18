extends Node

class CharacterProfile:
	var name: String
	var text_box_tex: Texture

	var talk_type: int = TextBox.CharacterTalkType.None
	var talk_sounds: Array

	var font: DynamicFont

	func _init(name_: String, text_box_name: String, talk_sound_names: Array, font_name: String):
		name = name_

		text_box_tex = load("res://assets/text_boxes/" + text_box_name)
		for sound_name in talk_sound_names:
			var sound = load("res://assets/sounds/talk_sounds/" + sound_name)
			sound.loop = false
			talk_sounds.append(sound)

		font = load("res://assets/fonts/" + font_name)


const CHOICE_LABEL = preload("res://text_box/choice_label.tscn")
var node: TextBox = null

func set_text_box_node(node_: TextBox):
	node = node_

func set_text(text: String):
	node.set_mode(TextBox.TextBoxMode.Dialog)
	node.text_node.text = text
	node.text_node.percent_visible = 0

	if node.talk_sounds.size() > 0 and node.talk_type != TextBox.CharacterTalkType.None:
		node.dialog_audio.pitch_scale = 1
		node.dialog_audio.stream = node.talk_sounds[randi()%node.talk_sounds.size()]
		node.dialog_audio.play()


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

func set_text_box_profile(profile: CharacterProfile):
	node.get_node("DialogText/Speaker").text = profile.name

	node.dialog_text_box = profile.text_box_tex
	node.talk_type = profile.talk_type
	node.talk_sounds = profile.talk_sounds
	node.dialog_font = profile.font
