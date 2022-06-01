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

class SeqStepDialog extends SeqStep:
	var text: String
	var next: SeqStep = null

class SeqStepChoice extends SeqStep:
	var choices: Array
	var choice_steps: Array

class SeqStepSetSpeaker extends SeqStep:
	var id: String
	var next: SeqStep = null

class SeqStepSetCamera extends SeqStep:
	var cam_index: int
	var next: SeqStep = null

class SeqStepSetVar extends SeqStep:
	var name: String
	var value
	var next: SeqStep = null

func parse(json: String) -> Array:
	var data = JSON.parse(json)
	var nodes = data["nodes"]
	var connection = data["connections"]

	var sequences: Array = []
	for node in nodes:
		if(node["type"] == "start"):
			var start = SeqStart.new(node["sequence_name"])
			sequences.append(start)

	return sequences
