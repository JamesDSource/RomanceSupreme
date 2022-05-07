extends Control

func _ready():
	var file = File.new()
	file.open("res://data/credits.json", File.READ)
	var json = file.get_as_text()
	file.close()
	
	var json_list = JSON.parse(json)
	if(json_list.error != 0):
		print("Error in credits.json")
	
	var credits_label: RichTextLabel = $Content
	for result in json_list.result:
		credits_label.text += result["name"] + "\n" 
		for role in result["roles"]:
			credits_label.text += "\t-" + role + "\n"
		credits_label.text += "\n"
