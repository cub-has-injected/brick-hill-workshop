"\nInterface for fetching Shape data\n\nData is returned as a dictionary of world-space Transform -> Shape pairs\n"

class_name InterfaceShapes
extends Interface
tool 

class Shapes:
	var _data: = {}

	func add_shape(transform:Transform, shape:Shape)->void :
		if not transform in _data:
			_data[transform] = []
		_data[transform].append(shape)

	func get_shapes()->Dictionary:
		return _data

static func name()->String:
	return "InterfaceShapes"

static func is_implementor(node:Object)->bool:
	return node.has_method("get_shapes")

static func get_shapes(node:Object)->Shapes:
	assert (is_implementor(node))
	return node.get_shapes()
