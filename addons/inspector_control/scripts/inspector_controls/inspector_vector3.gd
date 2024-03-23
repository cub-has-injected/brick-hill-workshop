class_name InspectorVector3
extends HBoxContainer

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

var _spin_box_x:SpinBox = null
var _spin_box_y:SpinBox = null
var _spin_box_z:SpinBox = null

var _spin_box_theme:Theme = preload("res://ui/themes/workshop_general_spinbox.tres")

func supported_property(property:Dictionary)->bool:
	return property.type == TYPE_VECTOR3

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

func get_orientation()->int:
	return HORIZONTAL

func _init()->void :
	size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END

func _enter_tree()->void :
	for child in get_children():
		if child.has_meta("inspector_vector3_child"):
			remove_child(child)
			child.queue_free()

	_spin_box_x = SpinBox.new()
	_spin_box_x.min_value = - 65536.0
	_spin_box_x.max_value = 65536.0
	_spin_box_x.step = 0.01
	_spin_box_x.size_flags_horizontal = SIZE_EXPAND_FILL
	_spin_box_x.theme = _spin_box_theme
	_spin_box_x.connect("value_changed", self, "x_changed")

	var line_edit_x = _spin_box_x.get_line_edit()
	line_edit_x.connect("focus_entered", line_edit_x, "call_deferred", ["select_all"])
	line_edit_x.connect("focus_exited", line_edit_x, "call_deferred", ["deselect"])
	line_edit_x.connect("text_entered", self, "line_edit_entered")

	add_child(_spin_box_x)

	_spin_box_y = SpinBox.new()
	_spin_box_y.min_value = - 65536.0
	_spin_box_y.max_value = 65536.0
	_spin_box_y.step = 0.01
	_spin_box_y.size_flags_horizontal = SIZE_EXPAND_FILL
	_spin_box_y.theme = _spin_box_theme
	_spin_box_y.connect("value_changed", self, "y_changed")

	var line_edit_y = _spin_box_y.get_line_edit()
	line_edit_y.connect("focus_entered", line_edit_y, "call_deferred", ["select_all"])
	line_edit_y.connect("focus_exited", line_edit_y, "call_deferred", ["deselect"])
	line_edit_y.connect("text_entered", self, "line_edit_entered")

	add_child(_spin_box_y)

	_spin_box_z = SpinBox.new()
	_spin_box_z.min_value = - 65536.0
	_spin_box_z.max_value = 65536.0
	_spin_box_z.step = 0.01
	_spin_box_z.size_flags_horizontal = SIZE_EXPAND_FILL
	_spin_box_z.theme = _spin_box_theme
	_spin_box_z.connect("value_changed", self, "z_changed")

	var line_edit_z = _spin_box_z.get_line_edit()
	line_edit_z.connect("focus_entered", line_edit_z, "call_deferred", ["select_all"])
	line_edit_z.connect("focus_exited", line_edit_z, "call_deferred", ["deselect"])
	line_edit_z.connect("text_entered", self, "line_edit_entered")

	add_child(_spin_box_z)

func _process(_delta:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	var value = _object.get(_property.name)
	if value.x != _spin_box_x.value:
		_spin_box_x.set_block_signals(true)
		_spin_box_x.value = value.x
		_spin_box_x.set_block_signals(false)

	if value.y != _spin_box_y.value:
		_spin_box_y.set_block_signals(true)
		_spin_box_y.value = value.y
		_spin_box_y.set_block_signals(false)

	if value.z != _spin_box_z.value:
		_spin_box_z.set_block_signals(true)
		_spin_box_z.value = value.z
		_spin_box_z.set_block_signals(false)

var mouse_down: = false

func _input(event:InputEvent)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	if not event is InputEventMouseButton:
		return 

	if event.pressed:
		if not get_global_rect().has_point(event.position):
			return 

		mouse_down = true
		emit_signal("property_change_begin", _property.name)
	else :
		if not mouse_down:
			return 

		emit_signal("property_change_end", _property.name)

func line_edit_entered(text:String)->void :
	emit_signal("property_change_begin", _property.name)
	emit_signal("property_change_end", _property.name)

func x_changed(new_x:float)->void :
	var new_value = _object[_property.name]
	new_value.x = new_x
	if _object.get(_property.name) != new_value:
		emit_signal("property_changed", _property.name + "[0]", new_value)

func y_changed(new_y:float)->void :
	var new_value = _object[_property.name]
	new_value.y = new_y
	if _object.get(_property.name) != new_value:
		emit_signal("property_changed", _property.name + "[1]", new_value)

func z_changed(new_z:float)->void :
	var new_value = _object[_property.name]
	new_value.z = new_z
	if _object.get(_property.name) != new_value:
		emit_signal("property_changed", _property.name + "[2]", new_value)

func set_enabled(new_enabled:bool)->void :
	_spin_box_x.editable = new_enabled
	_spin_box_y.editable = new_enabled
	_spin_box_z.editable = new_enabled
