class_name InspectorBrickMaterial
extends Control
tool 

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _picker:MaterialPicker = null

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	var scope = Profiler.scope(self, "supported_property", [property])

	return property.type == TYPE_INT and property.name == "material"

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
	rect_min_size = Vector2(216, 40)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		if child.has_meta("inspector_color_child"):
			remove_child(child)
			child.queue_free()

	_picker = MaterialPicker.new()
	_picker.connect("pressed_enum", self, "material_picked")
	_picker.set_meta("inspector_color_child", true)

	add_child(_picker)

func _process(_delta:float)->void :
	var scope = Profiler.scope(self, "_process", [_delta])

	if not _object:
		return 

	var value = _object.get(_property.name)
	_picker.selected_index = value

func set_enabled(new_enabled:bool)->void :
	var scope = Profiler.scope(self, "set_enabled", [new_enabled])

	_picker.disabled = not new_enabled

func material_picked(material:int)->void :
	var scope = Profiler.scope(self, "material_picked", [material])

	emit_signal("property_change_begin", name)
	emit_signal("property_changed", _property.name, material)
	emit_signal("property_change_end", name)
