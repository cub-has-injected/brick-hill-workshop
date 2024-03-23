"\nInterface indicating an object can be selected\n"

class_name InterfaceSelectable
extends Interface
tool 

static func name()->String:
	return "InterfaceSelectable"

static func is_implementor(node:Object)->bool:
	if not node is CollisionObject:
		return false

	for child in node.get_children():
		if child is Selectable and not child.has_meta("is_queued_for_remove"):
			return true

	return false

static func get_selection(node:Object)->Node:
	assert (is_implementor(node))
	for child in node.get_children():
		if child is Selectable and not child.has_meta("is_queued_for_remove"):
			return child.get_node(child.selection_path)
	return null
