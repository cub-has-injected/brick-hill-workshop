"\nInterface for fetching collision layers\n"

class_name InterfaceCollisionLayer
extends Interface
tool 

static func name()->String:
	return "InterfaceCollisionLayer"

static func is_implementor(node:Object)->bool:
	return node.has_method("get_collision_layer") and node.has_method("set_collision_layer")

static func set_collision_layer(node:Object, new_collision_layer:int):
	assert (is_implementor(node))
	node.set_collision_layer(new_collision_layer)

static func get_collision_layer(node:Object)->int:
	assert (is_implementor(node))
	return node.get_collision_layer()
