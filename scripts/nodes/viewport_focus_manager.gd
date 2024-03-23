class_name ViewportFocusManager
extends Node
tool 

signal focus_camera(position)

func _unhandled_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_unhandled_input", [event])

	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			var workshop_root = WorkshopDirectory.workshop_root()
			if workshop_root.mode != 0:
				var viewport_control = WorkshopDirectory.viewport_control()
				WorkshopDirectory.ui().grab_focus()
