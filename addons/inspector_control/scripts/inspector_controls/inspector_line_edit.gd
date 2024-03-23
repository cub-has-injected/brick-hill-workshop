class_name InspectorLineEdit
extends LineEdit

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	return property.type == TYPE_STRING

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

func _init()->void :
	connect("text_entered", self, "text_entered")

func _process(_delta:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	if has_focus():
		return 

	text = _object.get(_property.name)

func text_entered(new_text:String)->void :
	if not _object:
		return 

	if not _property.name in _object:
		return 

	if _object.get(_property.name) != new_text:
		emit_signal("property_change_begin", _property.name)
		emit_signal("property_changed", _property.name, new_text)
		emit_signal("property_change_end", _property.name)

func set_enabled(new_enabled:bool)->void :
	editable = new_enabled
