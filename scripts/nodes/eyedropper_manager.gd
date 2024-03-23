class_name EyedropperManager
extends Node

signal hovered_color_changed()

var hovered_color: = Color.white

func clear()->void :
	var scope = Profiler.scope(self, "clear", [])

	hovered_color = Color.white

func update_hovered_color()->void :
	var scope = Profiler.scope(self, "update_hovered_color", [])

	var hovered_node = WorkshopDirectory.hovered_node()
	var node = hovered_node.hovered_node

	if not node:
		clear()
		return 

	hovered_color = node.albedo
	emit_signal("hovered_color_changed")
