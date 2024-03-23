"\nInterface for fetching local object center\n"

class_name InterfaceLocalCenter
extends Interface
tool 

static func name()->String:
	return "InterfaceLocalCenter"

static func is_implementor(node:Object)->bool:
	return node is Spatial or node.has_method("get_local_center")

static func get_local_center(node:Object)->Vector3:
	if node.has_method("get_local_center"):
		return node.get_local_center()
	elif node is Spatial:
		return Vector3.ZERO

	assert (false, "Node doesn't implement InterfaceLocalCenter")
	return Vector3.ZERO

