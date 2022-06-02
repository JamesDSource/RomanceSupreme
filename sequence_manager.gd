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

func _ready():
	var file = File.new()
	file.open("res://data/test.json", File.READ)
	var json = file.get_as_text()
	file.close()

	var parsed = parse(json)
	print(parsed)

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
	
	match(node["type"]):
		"jump":
			var name = node["sequence_name"]
			var jump = SeqStepJump.new(name)
			return jump
		"dialog":
			var text = node["dialog_text"]
			var dialog = SeqStepDialog.new(text)
			if(
			node_connection != null and 
			node_connection["outputs"].size() > 0 and
			node_connection["outputs"][0] != null):
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
			if(
			node_connection != null and 
			node_connection["outputs"].size() > 0 and
			node_connection["outputs"][0] != null):
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
					cam.next = cam
					return cam
				"Custom Variable":
					var var_name: String = node["var_name"]	
					var var_value = node["var_value"]
					var custom = SeqStepSetVar.new(var_name, var_value)
					custom.next = next
					return custom
	return null
