"\nInterface for fetching Mesh data\n\nData is returned as a dictionary of world-space Transform -> Mesh pairs\n"

class_name InterfaceMeshes
extends Interface
tool 

class Meshes:
	var _data: = []

	func add_mesh(transform:Transform, mesh)->void :
		_data.append([transform, mesh])

	func get_meshes()->Array:
		return _data

static func name()->String:
	return "InterfaceMeshes"

static func is_implementor(node:Object)->bool:
	return node.has_method("get_meshes")

static func get_meshes(node:Object)->Meshes:
	assert (is_implementor(node))
	return node.get_meshes()
