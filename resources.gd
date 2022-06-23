extends Node

func get_resources_in_dir(dir_path: String):
	var out = []

	if dir_path.ends_with("/"):
		dir_path = dir_path.substr(0, dir_path.length() - 1)
	var dir = Directory.new()
	dir.open(dir_path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif !file.ends_with(".import") and !file.begins_with("."):
			var resource = load(dir_path + "/" + file)
			if resource != null:
				out.append(resource)
	
	return out
