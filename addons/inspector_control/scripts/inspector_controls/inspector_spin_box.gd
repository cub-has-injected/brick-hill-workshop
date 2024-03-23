class_name InspectorSpinBox
extends SpinBox

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	return property.type == TYPE_INT

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

	if not _property.name in _object:
		return 

	set_block_signals(true)

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

func get_orientation()->int:
	return HORIZONTAL

func _init()->void :
	size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END

	connect("value_changed", self, "value_changed")

	var line_edit = get_line_edit()
	line_edit.connect("focus_entered", line_edit, "call_deferred", ["select_all"])
	line_edit.connect("focus_exited", line_edit, "call_deferred", ["deselect"])
	line_edit.connect("text_entered", self, "line_edit_entered")

	theme = preload("res://ui/themes/workshop_general_spinbox.tres")

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

func line_edit_entered(text:String)->void :
	emit_signal("property_change_begin", _property.name)
	emit_signal("property_change_end", _property.name)

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
