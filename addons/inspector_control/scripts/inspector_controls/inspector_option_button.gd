class_name InspectorOptionButton
extends OptionButton

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	return property.type == TYPE_INT and property.hint == PROPERTY_HINT_ENUM

func set_data(object:Object, property:Dictionary)->void :
	_object = object
	_property = property

	clear()
	for option in property.hint_string.split(","):
		add_item(option)

func get_orientation()->int:
	return HORIZONTAL

func _init()->void :
	size_flags_horizontal = SIZE_EXPAND | SIZE_SHRINK_END
	connect("item_selected", self, "item_selected")

func _process(_delta:float)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	var value = _object.get(_property.name)
	selected = value

	var popup = get_popup()
	if not popup.visible:
		get_popup().visible = true
		rect_min_size.x = get_popup().rect_size.x
		get_popup().visible = false
	else :
		rect_min_size.x = get_popup().rect_size.x

func item_selected(index:int)->void :
	if not is_instance_valid(_object):
		return 

	if not _property.name in _object:
		return 

	if _object.get(_property.name) != index:
		emit_signal("property_change_begin", _property.name)
		emit_signal("property_changed", _property.name, index)
		emit_signal("property_change_end", _property.name)

func set_enabled(new_enabled:bool)->void :
	disabled = not new_enabled
