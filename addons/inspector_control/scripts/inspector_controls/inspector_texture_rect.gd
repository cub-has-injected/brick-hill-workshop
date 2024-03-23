class_name InspectorTextureRect
extends TextureRect

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	return property.type == TYPE_OBJECT and property.hint_string == "Texture"

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

func _process(_delta:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	texture = _object.get(_property.name)
