extends Node
tool 

var mouse_sensitivity: = Vector2(0.0025, 0.0025)
var pad_sensitivity: = Vector2(5.0, 5.0)
var pad_camera_curve: = Vector2(1.5, 1.5)

func _get_property_list()->Array:
	var property_list: = []

	property_list.append({
		"name":"mouse_sensitivity", 
		"type":TYPE_VECTOR2
	})

	property_list.append({
		"name":"pad_sensitivity", 
		"type":TYPE_VECTOR2
	})

	property_list.append({
		"name":"pad_curve", 
		"type":TYPE_VECTOR2
	})

	return property_list
