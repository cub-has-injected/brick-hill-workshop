class_name InspectorBrickSurface
extends VBoxContainer
tool 

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _pickers: = []

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	var scope = Profiler.scope(self, "supported_property", [property])

	return property.type == TYPE_RAW_ARRAY and property.name == "surfaces"

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
	rect_min_size = Vector2(184, 196)
	set("custom_constants/separation", 8)

func _process(_delta:float)->void :
	var scope = Profiler.scope(self, "_process", [_delta])

	if not _object:
		return 

	var value = _object.get(_property.name)
	if not value:
		return 

	while _pickers.size() < value.size():
		var picker = SurfacePicker.new()
		picker.set_meta("inspector_surfaces_child", true)
		add_child(picker)
		picker.connect("pressed_enum", self, "surface_picked", [picker.get_index()])
		_pickers.append(picker)

	for i in range(0, _pickers.size()):
		var picker = _pickers[i]
		picker.selected_index = value[i]
		picker.visible = i < value.size()

	var min_size = Vector2(184, (32 * value.size()) + 4)
	if min_size != rect_min_size:
		rect_min_size = min_size

func set_enabled(new_enabled:bool)->void :
	var scope = Profiler.scope(self, "set_enabled", [new_enabled])

	for picker in _pickers:
		picker.set_disabled( not new_enabled)

func surface_picked(material:int, index:int)->void :
	var scope = Profiler.scope(self, "surface_picked", [material, index])

	var value = _object.get(_property.name)
	value[index] = material
	emit_signal("property_change_begin", name)
	emit_signal("property_changed", _property.name, value)
	emit_signal("property_change_end", name)
