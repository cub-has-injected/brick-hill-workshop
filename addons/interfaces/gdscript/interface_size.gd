"\nInterface for fetching local object size\n"

class_name InterfaceSize
extends Interface
tool 

static func name()->String:
	return "InterfaceSize"

static func is_implementor(node:Object)->bool:
	return node.has_method("get_size") and node.has_method("set_size")

static func set_size(node:Object, new_size:Vector3):
	assert (is_implementor(node))
	node.set_size(new_size)

static func get_size(node:Object)->Vector3:
	assert (is_implementor(node))
	return node.get_size()

static func offset_aabb_size(node:Object, offset:Vector3)->void :
	assert (is_implementor(node))
	set_size(node, get_size(node) + offset)
