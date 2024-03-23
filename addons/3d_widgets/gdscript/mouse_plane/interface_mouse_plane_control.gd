"\nInterface for updating the mouse plane on mouse-over\n"

class_name InterfaceMousePlaneControl
extends Interface
tool 

static func name()->String:
	return "InterfaceMousePlaneControl"

static func is_implementor(node:Object)->bool:
	if not node is CollisionObject:
		return false

	for child in node.get_children():
		if child is MousePlaneControl and not child.has_meta("is_queued_for_remove"):
			return true
	return false

static func get_mouse_plane_control(node:Object)->MousePlaneControl:
	assert (is_implementor(node))
	for child in node.get_children():
		if child is MousePlaneControl:
			return child

	return null
