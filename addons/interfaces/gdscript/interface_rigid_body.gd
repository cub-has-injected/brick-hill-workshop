"\nInterface for fetching a RigidBody from an object\n"

class_name InterfaceRigidBody
extends Interface
tool 

static func name()->String:
	return "InterfaceRigidBody"

static func is_implementor(node:Object)->bool:
	return node is RigidBody or node.has_method("get_rigid_body")

static func get_rigid_body(node:Object)->RigidBody:
	assert (is_implementor(node))
	if node is RigidBody:
		return node as RigidBody
	else :
		return node.get_rigid_body()
