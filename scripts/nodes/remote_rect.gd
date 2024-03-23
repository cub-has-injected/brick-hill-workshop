class_name RemoteRect
extends Control
tool 

export (NodePath) var remote_path setget set_remote_path
export (bool) var use_global_coordinates: = true

func set_remote_path(new_remote_path:NodePath)->void :
	var scope = Profiler.scope(self, "set_remote_path", [new_remote_path])

	if remote_path != new_remote_path:
		remote_path = new_remote_path

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var remote_control = get_node_or_null(remote_path) as Control
	if remote_control:
		if use_global_coordinates:
			remote_control.rect_global_position = rect_global_position
		else :
			remote_control.rect_position = rect_position

		remote_control.rect_size = rect_size

func _get_configuration_warning()->String:
	var scope = Profiler.scope(self, "_get_configuration_warning", [])

	var remote_control = get_node_or_null(remote_path) as Control
	if not remote_control:
		return "Path property must point to a valid Control node to work"

	return ""
