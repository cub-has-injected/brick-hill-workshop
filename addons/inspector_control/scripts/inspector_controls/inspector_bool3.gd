class_name InspectoBool3
extends HBoxContainer

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

var _label_x:Label = null
var _label_y:Label = null
var _label_z:Label = null

var _checkbox_x:CheckBox = null
var _checkbox_y:CheckBox = null
var _checkbox_z:CheckBox = null

func supported_property(property:Dictionary)->bool:
	return (
		property.type == TYPE_ARRAY and 
		property.hint == PropertyUtil.PROPERTY_HINT_TYPE_STRING and 
		property.hint_string.to_int() == TYPE_BOOL
	)

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

func get_orientation()->int:
	return HORIZONTAL

func _init()->void :
	size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END

func _enter_tree()->void :
	for child in get_children():
		if child.has_meta("inspector_bool3_child"):
			remove_child(child)
			child.queue_free()

	_label_x = Label.new()
	_label_x.size_flags_horizontal = SIZE_EXPAND_FILL
	_label_x.text = "X"
	_label_x.set_meta("inspector_bool3_child", true)
	add_child(_label_x)

	_checkbox_x = CheckBox.new()
	_checkbox_x.size_flags_horizontal = SIZE_EXPAND_FILL
	_checkbox_x.connect("toggled", self, "x_changed")
	_checkbox_x.set_meta("inspector_bool3_child", true)

	add_child(_checkbox_x)

	_label_y = Label.new()
	_label_y.size_flags_horizontal = SIZE_EXPAND_FILL
	_label_y.text = "Y"
	_label_y.set_meta("inspector_bool3_child", true)
	add_child(_label_y)

	_checkbox_y = CheckBox.new()
	_checkbox_y.size_flags_horizontal = SIZE_EXPAND_FILL
	_checkbox_y.connect("toggled", self, "y_changed")
	_checkbox_y.set_meta("inspector_bool3_child", true)

	add_child(_checkbox_y)

	_label_z = Label.new()
	_label_z.size_flags_horizontal = SIZE_EXPAND_FILL
	_label_z.text = "Z"
	_label_z.set_meta("inspector_bool3_child", true)
	add_child(_label_z)

	_checkbox_z = CheckBox.new()
	_checkbox_z.size_flags_horizontal = SIZE_EXPAND_FILL
	_checkbox_z.connect("toggled", self, "z_changed")
	_checkbox_z.set_meta("inspector_bool3_child", true)

	add_child(_checkbox_z)

func _process(_delta:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	var value = _object.get(_property.name)
	if value[0] != _checkbox_x.pressed:
		_checkbox_x.set_block_signals(true)
		_checkbox_x.pressed = value[0]
		_checkbox_x.set_block_signals(false)

	if value[1] != _checkbox_y.pressed:
		_checkbox_y.set_block_signals(true)
		_checkbox_y.pressed = value[1]
		_checkbox_y.set_block_signals(false)

	if value[2] != _checkbox_z.pressed:
		_checkbox_z.set_block_signals(true)
		_checkbox_z.pressed = value[2]
		_checkbox_z.set_block_signals(false)

func x_changed(new_x:bool)->void :
	var old_value = _object.get(_property.name)
	var new_value = old_value.duplicate()
	new_value[0] = new_x
	if old_value != new_value:
		emit_signal("property_change_begin", _property.name)
		emit_signal("property_changed", _property.name + "[0]", new_value)
		emit_signal("property_change_end", _property.name)

func y_changed(new_y:bool)->void :
	var old_value = _object.get(_property.name)
	var new_value = old_value.duplicate()
	new_value[1] = new_y
	if old_value != new_value:
		emit_signal("property_change_begin", _property.name)
		emit_signal("property_changed", _property.name + "[1]", new_value)
		emit_signal("property_change_end", _property.name)

func z_changed(new_z:bool)->void :
	var old_value = _object.get(_property.name)
	var new_value = old_value.duplicate()
	new_value[2] = new_z
	if old_value != new_value:
		emit_signal("property_change_begin", _property.name)
		emit_signal("property_changed", _property.name + "[2]", new_value)
		emit_signal("property_change_end", _property.name)

func set_enabled(new_enabled:bool)->void :
	_checkbox_x.disabled = not new_enabled
	_checkbox_y.disabled = not new_enabled
	_checkbox_z.disabled = not new_enabled
