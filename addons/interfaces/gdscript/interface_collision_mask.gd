"\nInterface for fetching collision layers\n"

class_name InterfaceCollisionMask
extends Interface
tool 

static func name()->String:
	return "InterfaceCollisionMask"

static func is_implementor(node:Object)->bool:
	return node.has_method("get_collision_mask") and node.has_method("set_collision_mask")

static func set_collision_mask(node:Object, new_collision_mask:int):
	assert (is_implementor(node))
	node.set_collision_mask(new_collision_mask)

static func get_collision_mask(node:Object)->int:
	assert (is_implementor(node))
	return node.get_collision_mask()
