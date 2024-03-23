class_name InspectorButton
extends Button

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	return true

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

func _process(_delta:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	var value = _object.get(_property.name)
	text = "%s" % [value]

func set_enabled(new_enabled:bool)->void :
	disabled = not new_enabled
