"\nInterface indicating an object can be selected\n"

class_name InterfaceBlockSelection
extends Interface
tool 

static func name()->String:
	return "InterfaceBlockSelection"

static func is_implementor(node:Object)->bool:
	if not node is CollisionObject:
		return false

	for child in node.get_children():
		if child is BlockSelection and not child.has_meta("is_queued_for_remove"):
			return true
	return false
