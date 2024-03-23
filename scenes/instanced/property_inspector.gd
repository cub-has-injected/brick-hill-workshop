extends Control

func _ready()->void :
	var editor_build = false
	for property in get_property_list():
		if property.name == "Script" and property.usage == PROPERTY_USAGE_GROUP:
			editor_build = true

	if editor_build:
		$InspectorPropertyModel.sculpt_paths = [":Spatial:Transform", ":Script Variables:Script"]
	else :
		$InspectorPropertyModel.sculpt_paths = [":Spatial:Transform", ":Script Variables"]
