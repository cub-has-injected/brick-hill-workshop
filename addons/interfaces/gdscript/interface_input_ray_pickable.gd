"\nInterface for fetching collision layers\n"

class_name InterfaceInputRayPickable
extends Interface
tool 

static func name()->String:
	return "InterfaceInputRayPickable"

static func is_implementor(node:Object)->bool:
	return node.has_method("is_ray_pickable") and node.has_method("set_ray_pickable")

static func set_input_ray_pickable(node:Object, new_input_ray_pickable:bool):
	assert (is_implementor(node))
	node.set_ray_pickable(new_input_ray_pickable)

static func get_input_ray_pickable(node:Object)->bool:
	assert (is_implementor(node))
	return node.is_ray_pickable()
