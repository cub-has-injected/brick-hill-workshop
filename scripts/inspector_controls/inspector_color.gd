class_name InspectorColor
extends Button
tool 

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _border:ColorRect = null
var _active_color:ColorRect = null
var _dropdown_icon:TextureRect = null

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	var scope = Profiler.scope(self, "supported_property", [property])

	return property.type == TYPE_COLOR

func set_data(object:Object, property:Dictionary)->void :
	var scope = Profiler.scope(self, "set_data", [object, property])

	_object = object
	_property = property

func get_orientation()->int:
	var scope = Profiler.scope(self, "get_orientation", [])

	return HORIZONTAL

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END

	toggle_mode = true
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	keep_pressed_outside = true
	rect_min_size = Vector2(44, 34)
	size_flags_vertical = SIZE_SHRINK_CENTER

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		if child.has_meta("inspector_color_child"):
			remove_child(child)
			child.queue_free()

	_border = ColorRect.new()
	_border.set_meta("inspector_color_child", true)

	_active_color = ColorRect.new()
	_active_color.set_meta("_inspector_color_child", true)

	_dropdown_icon = TextureRect.new()
	_dropdown_icon.set_meta("_inspector_color_child", true)

	_border.add_child(_active_color)
	add_child(_border)
	add_child(_dropdown_icon)

	_border.color = Color.black
	_border.anchor_left = 0.0
	_border.anchor_top = 0.5
	_border.anchor_right = 0.0
	_border.anchor_bottom = 0.5
	_border.margin_left = 5
	_border.margin_top = - 12
	_border.margin_right = 24
	_border.margin_bottom = 12
	_border.rect_min_size = Vector2(24, 24)
	_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_border.size_flags_vertical = SIZE_SHRINK_CENTER

	_active_color.rect_position = Vector2(1, 1)
	_active_color.rect_min_size = Vector2(22, 22)
	_active_color.mouse_filter = MOUSE_FILTER_IGNORE

	_dropdown_icon.texture = preload("res://ui/icons/workshop-assets/controls/dropdownOpen.png")
	_dropdown_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_dropdown_icon.rect_position = Vector2(32, 13.5)
	_dropdown_icon.rect_min_size = Vector2(12, 16)
	_dropdown_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta:float)->void :
	var scope = Profiler.scope(self, "_process", [_delta])

	if not is_instance_valid(_object):
		return 

	var value = _object.get(_property.name)
	if not value:
		return 

	_active_color.color = value

func set_enabled(new_enabled:bool)->void :
	var scope = Profiler.scope(self, "set_enabled", [new_enabled])

	disabled = not new_enabled


var pick_face_color_button_target:Control = null
var pick_face_color_object_target:Object = null
var pick_face_color_face_target:int = - 1
func _toggled(button_pressed:bool)->void :
	var scope = Profiler.scope(self, "_toggled", [button_pressed])

	if button_pressed:
		WorkshopDirectory.color_picker_manager().set_picker_color(_active_color.color)
		WorkshopDirectory.color_picker_manager().set_picker_connection(self, "color_picked")

		var candidate = self
		while true:
			var parent = candidate.get_parent()
			if not parent or parent is PanelContainer:
				break
			else :
				candidate = parent
		WorkshopDirectory.color_picker_manager().show_picker_at_control(self, candidate, CORNER_TOP_LEFT, CORNER_TOP_RIGHT)

func color_picked(new_color:Color)->void :
	var scope = Profiler.scope(self, "color_picked", [new_color])

	emit_signal("property_change_begin", name)
	emit_signal("property_changed", name, new_color)
	emit_signal("property_change_end", name)
