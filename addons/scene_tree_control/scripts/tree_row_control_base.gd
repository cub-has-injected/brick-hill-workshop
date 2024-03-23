class_name TreeRowBase
extends HBoxContainer
tool 

signal show_rename_line_edit(rect, text, edit_callback)

export (bool) var selected: = false
var node:Node = null setget set_node

func set_node(new_node:Node)->void :
	var scope = Profiler.scope(self, "set_node", [new_node])

	if node != new_node:
		node = new_node
		update()
