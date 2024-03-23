class_name BrickData
extends Resource
tool 


func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	if resource_name == "":
		resource_name = "Brick Data"
