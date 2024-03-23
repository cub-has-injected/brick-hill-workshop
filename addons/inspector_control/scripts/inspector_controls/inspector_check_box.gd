class_name InspectorCheckBox
extends CheckBox

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	return property.type == TYPE_BOOL

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

func get_orientation()->int:
	return HORIZONTAL

func _init()->void :
	size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END

func _process(_delta:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	var value = _object.get(_property.name)
	if pressed != value:
		pressed = value

func _toggled(button_pressed:bool)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	if _object.get(name) != button_pressed:
		emit_signal("property_change_begin", name)
		emit_signal("property_changed", name, button_pressed)
		emit_signal("property_change_end", name)

func set_enabled(new_enabled:bool)->void :
	disabled = not new_enabled
