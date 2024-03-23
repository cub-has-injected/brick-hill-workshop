class_name InspectorSkybox
extends OptionButton

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

func supported_property(property:Dictionary)->bool:
	var scope = Profiler.scope(self, "supported_property", [property])

	return property.name == "skybox_asset_id" and property.type == TYPE_INT

func set_data(object:Object, property:Dictionary)->void :
	var scope = Profiler.scope(self, "set_data", [object, property])

	_object = object
	_property = property

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	expand_icon = true
	rect_min_size.y = 72
	get_popup().rect_size.x = 128
	size_flags_horizontal = SIZE_EXPAND_FILL
	add_icon_item(preload("res://resources/texture/environment/procedural_sky_icon.png"), "Procedural")
	for i in range(0, BuiltInAssets.SKYBOXES.values().size()):
		var key = BuiltInAssets.SKYBOXES.keys()[i]
		var asset = BuiltInAssets.SKYBOXES.values()[i]
#		var icon = yield (asset.get_asset(), "completed").icon
#		add_icon_item(icon, key.capitalize())
		set_item_metadata(i + 1, asset.get_id())

	connect("item_selected", self, "item_selected")

func _process(_delta:float)->void :
	var scope = Profiler.scope(self, "_process", [_delta])

	if not is_instance_valid(_object):
		return 

	var asset_id = _object.skybox_asset_id

	for i in range(0, BuiltInAssets.SKYBOXES.values().size()):
		var asset = BuiltInAssets.SKYBOXES.values()[i]
		if asset.get_id() == asset_id:
			selected = i + 1
			break

func item_selected(index:int)->void :
	var scope = Profiler.scope(self, "item_selected", [index])

	if not is_instance_valid(_object):
		return 

	if index == 0:
		_object.set(_property.name, - 1)
	else :
		_object.set(_property.name, get_item_metadata(index))

func set_enabled(new_enabled:bool)->void :
	var scope = Profiler.scope(self, "set_enabled", [new_enabled])

	disabled = not new_enabled
