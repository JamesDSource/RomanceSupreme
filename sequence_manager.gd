extends Node

class SeqStart:
	var name: String
	var next: SeqStep = null

	func _init(name_: String):
		name = name_

class SeqStep:
	func _init():
		pass

class SeqStepJump extends SeqStep:
	var name: String

	func _init(name_: String):
		name = name_

class SeqStepDialog extends SeqStep:
	var text: String
	var next: SeqStep = null

	func _init(text_: String):
		text = text_

class SeqStepChoice extends SeqStep:
	var choices: Array
	var choice_steps: Array

	func _init():
		choices = []
		choice_steps = []

class SeqStepSetSpeaker extends SeqStep:
	var id: String
	var next: SeqStep = null

	func _init(id_: String):
		id = id_

class SeqStepSetCamera extends SeqStep:
	var cam_index: int
	var next: SeqStep = null

	func _init(cam_index_: int):
		cam_index = cam_index_

class SeqStepSetVar extends SeqStep:
	var name: String
	var value
	var next: SeqStep = null

	func _init(name_: String, value_):
		name = name_
		value = value_

var current_sequences: Array = []
var current_step: SeqStep = null
var current_cameras: Array

var player_3p = null
var original_cam: Camera = null
var on_finished_callback: FuncRef

var custom_vars: Dictionary

var profiles: Dictionary = {}
const DEFAULT_TEXT_BOX: String = "default_textbox.png"
const DEFAULT_FONT: String = "lemon_tea.tres"

func _ready():
	var file = File.new()
	file.open("res://data/character_profiles.json", File.READ)
	var json = file.get_as_text()
	file.close()

	var data = JSON.parse(json).result

	for profile in data["profiles"]:
		var new_char_profile = TextBoxController.CharacterProfile.new(
			profile["name"], 
			profile["text_box"] if profile.has("text_box") else DEFAULT_TEXT_BOX,
			profile["talk_sounds"] if profile.has("talk_sounds") else [],
			profile["font"] if profile.has("font") else DEFAULT_FONT)
		match(profile["talk_type"]):
			"none":
				pass
			"talk":
				new_char_profile.talk_type = TextBox.CharacterTalkType.Talk
			"grunt":
				new_char_profile.talk_type = TextBox.CharacterTalkType.Grunt
		profiles[profile["id"]] = new_char_profile

func start_seq(name: String, cameras: Array, on_finished: FuncRef):
	var file = File.new()
	file.open("res://data/" + name + ".json", File.READ)
	var json = file.get_as_text()
	file.close()

	var players = get_tree().get_nodes_in_group("player3p")
	if(players.size() > 0):
		player_3p = players[0]

	current_cameras = cameras.duplicate()
	if(cameras.size() > 0):
		original_cam = player_3p.camera
		cameras[0].current = true

	on_finished_callback = on_finished
	custom_vars = {}

	var initial_profile = TextBoxController.CharacterProfile.new(
		"",
		DEFAULT_TEXT_BOX,
		[],
		DEFAULT_FONT
	)
	TextBoxController.set_text_box_profile(initial_profile)

	current_sequences = parse(json)
	var found: bool = false
	for sequence in current_sequences:
		if(sequence.name == "[root]"):
			play_step(sequence.next)
			found = true
			break
	
	if(found):
		player_3p.lock_movement = true
	else:
		player_3p = null
		original_cam = null

func play_step(node: SeqStep):
	if node == null:
		if player_3p != null:
			player_3p.lock_movement = false
			player_3p = null

		if original_cam != null:
			original_cam.current = true
			original_cam = null

		on_finished_callback.call_func(custom_vars)
	elif(node is SeqStepJump):
		for seq in current_sequences:
			if(seq.name == node.name):
				play_step(seq.next)
	elif(node is SeqStepDialog):
		TextBoxController.set_text_box_visible(true)
		TextBoxController.set_text(node.text)
		current_step = node
	elif(node is SeqStepChoice):
		TextBoxController.set_text_box_visible(true)
		TextBoxController.set_choices(node.choices)
		current_step = node
	elif(node is SeqStepSetSpeaker):
		if profiles.has(node.id):
			TextBoxController.set_text_box_profile(profiles[node.id])
		else:
			var profile = TextBoxController.CharacterProfile.new(
				node.id,
				DEFAULT_TEXT_BOX,
				[],
				DEFAULT_FONT
			)
			TextBoxController.set_text_box_profile(profile)
		play_step(node.next)
	elif(node is SeqStepSetCamera):
		current_cameras[node.cam_index].current = true	
		play_step(node.next)
	elif(node is SeqStepSetVar):
		custom_vars[node.name] = node.value
		play_step(node.next)

func _process(_delta):
	if(current_step != null):
		if(current_step is SeqStepDialog and Input.is_action_just_pressed("dialog_next")):
			if(TextBoxController.node.text_node.percent_visible < 1):
				TextBoxController.node.text_node.percent_visible = 1
			else:
				TextBoxController.set_text_box_visible(false)
				play_step(current_step.next)
		elif(current_step is SeqStepChoice):
			if(Input.is_action_just_pressed("dialog_next")):
				var selected: int = TextBoxController.choice_select()
				TextBoxController.set_text_box_visible(false)

				play_step(current_step.choice_steps[selected])
			elif(Input.is_action_just_pressed("dialog_choice_up")):
				TextBoxController.choice_move_up()
			elif(Input.is_action_just_pressed("dialog_choice_down")):
				TextBoxController.choice_move_down()

func parse(json: String) -> Array:
	var data = JSON.parse(json).result
	var nodes = data["nodes"]
	var connections = data["connections"]

	var sequences: Array = []
	for i in range(0, nodes.size()):
		var node = nodes[i]
		if(node["type"] == "start"):
			var start = SeqStart.new(node["sequence_name"])
			sequences.append(start)

			for connection in connections:
				if(connection["node_idx"] == i and connection["outputs"].size() > 0):
					start.next = fill_node(nodes, connection["outputs"][0], connections)

	return sequences

func fill_node(nodes: Array, node_index: int, connections: Array) -> SeqStep:
	var node = nodes[node_index]

	var node_connection = null
	for connection in connections:
		if(connection["node_idx"] == node_index):
			node_connection = connection
			break
	var first_not_null: bool = (
		node_connection != null and node_connection["outputs"].size() > 0 and node_connection["outputs"][0] != null)
	
	match(node["type"]):
		"jump":
			var name = node["sequence_name"]
			var jump = SeqStepJump.new(name)
			return jump
		"dialog":
			var text = node["dialog_text"]
			var dialog = SeqStepDialog.new(text)
			if(first_not_null):
				dialog.next = fill_node(nodes, node_connection["outputs"][0], connections)
			return dialog
		"choice":
			var choice = SeqStepChoice.new()
			for i in range(0, node["choices"].size()):
				choice.choices.append(node["choices"][i])
				if(node_connection["outputs"].size() > i and node_connection["outputs"][i] != null):
					choice.choice_steps.append(fill_node(nodes, node_connection["outputs"][i], connections))
				else:
					choice.choice_steps.append(null)
			return choice
		"setter":
			var next: SeqStep = null
			if(first_not_null):
				next = fill_node(nodes, node_connection["outputs"][0], connections)

			match(node["value_type"]):
				"Speaker":
					var speaker_id: String = node["speaker_id"]
					var speaker = SeqStepSetSpeaker.new(speaker_id)
					speaker.next = next
					return speaker
				"Camera Angle":
					var cam_index: int = node["cam_index"]
					var cam = SeqStepSetCamera.new(cam_index)
					cam.next = next
					return cam
				"Custom Variable":
					var var_name: String = node["var_name"]	
					var var_value = node["var_value"]
					var custom = SeqStepSetVar.new(var_name, var_value)
					custom.next = next
					return custom
	return null