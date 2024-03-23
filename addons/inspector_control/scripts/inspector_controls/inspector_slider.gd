class_name InspectorSlider
extends HSlider

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	return property.type == TYPE_REAL

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

	set_block_signals(true)

	if not _property.name in _object:
		return 

	value = _object.get(_property.name)

	if not _property.hint_string.empty():
		var parts = _property.hint_string.split(",")
		min_value = float(parts[0])
		max_value = float(parts[1])
		step = float(parts[2])
		allow_lesser = false
		allow_greater = false
	else :
		step = 0
		allow_lesser = true
		allow_greater = true

	set_block_signals(false)

func _init()->void :
	size_flags_horizontal = SIZE_EXPAND_FILL
	scrollable = false

	connect("value_changed", self, "value_changed")

func _process(_delta:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	var object_value = _object.get(_property.name)
	if value != object_value:
		set_block_signals(true)
		value = object_value
		set_block_signals(false)

func value_changed(new_value:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	if _object.get(_property.name) != new_value:
		emit_signal("property_changed", _property.name, new_value)

func _gui_input(event:InputEvent)->void :
	if event is InputEventMouseButton:
		if not is_instance_valid(_object):
			return 

		if not _property.name in _object:
			return 

		if event.pressed:
			emit_signal("property_change_begin", _property.name)
		else :
			emit_signal("property_change_end", _property.name)

func set_enabled(new_enabled:bool)->void :
	editable = new_enabled
