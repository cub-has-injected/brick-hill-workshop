class_name InterfaceInspectorProperty
extends Interface
tool 

static func name()->String:
	return "InterfaceInspectorProperty"

static func is_implementor(object:Object)->bool:
	return object is Control and object.has_method("supported_property") and object.has_method("set_data")

static func supported_property(control:Control, property:Dictionary)->bool:
	assert (is_implementor(control))
	return control.supported_property(property)

static func set_data(control:Control, object:Object, property:Dictionary)->void :
	assert (is_implementor(control))
	control.set_data(object, property)
