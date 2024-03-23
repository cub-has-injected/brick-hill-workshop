"\nInterface for fetching group origin\n"

class_name InterfaceGroupOrigin
extends Interface
tool 

static func name()->String:
	return "InterfaceGroupOrigin"

static func is_implementor(node:Object)->bool:
	return node is BrickHillGroup or node.has_method("get_group_origin")

static func get_group_origin(node:Object)->Vector3:
	if node.has_method("get_group_origin"):
		return node.get_group_origin()
	elif node is BrickHillGroup:
		return node.origin

	assert (false, "Node doesn't implement InterfaceGroupOrigin")
	return Vector3.ZERO

