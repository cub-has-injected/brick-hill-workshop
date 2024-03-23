class_name CameraFocusManager
extends Node
tool 

signal focus_camera(position)

func focus_camera_on_selection()->void :
	var scope = Profiler.scope(self, "focus_camera_on_selection", [])

	var position = Vector3.ZERO

	var box_selector = WorkshopDirectory.box_selector()
	if box_selector.active:
		position = box_selector.global_transform.origin
	else :
		var selected_nodes = WorkshopDirectory.selected_nodes().selected_nodes
		if selected_nodes.size() == 0:
			return 

		for selected_node in selected_nodes:
			position += selected_node.global_transform.origin
		position /= selected_nodes.size()

	emit_signal("focus_camera", position)
