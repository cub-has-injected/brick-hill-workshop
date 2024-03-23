class_name InspectorPropertyModel
extends Node
tool 

const DEBUG: = false

signal changed()

export (Array, String) var blacklist_paths: = [] setget set_blacklist_paths
export (Array, String) var sculpt_paths: = [] setget set_sculpt_paths
export (String) var property_filter: = "" setget set_property_filter

var _selected_scripts: = {}

var _sculpt_dict: = {}
var _blacklist_dict: = {}
var _property_dict: = {}





func set_blacklist_paths(new_blacklist_paths:Array)->void :
	var scope = Profiler.scope(self, "set_blacklist_paths", [new_blacklist_paths])

	if blacklist_paths != new_blacklist_paths:
		blacklist_paths = new_blacklist_paths
		_blacklist_dict.clear()
		_parse_paths(blacklist_paths, _blacklist_dict)
		if is_inside_tree():
			_rebuild()

func set_sculpt_paths(new_sculpt_paths:Array)->void :
	var scope = Profiler.scope(self, "set_sculpt_paths", [new_sculpt_paths])

	if sculpt_paths != new_sculpt_paths:
		sculpt_paths = new_sculpt_paths
		_sculpt_dict.clear()
		_parse_paths(sculpt_paths, _sculpt_dict)
		if is_inside_tree():
			_rebuild()

func set_property_filter(new_property_filter:String)->void :
	var scope = Profiler.scope(self, "set_property_filter", [new_property_filter])

	if property_filter != new_property_filter:
		property_filter = new_property_filter
		if is_inside_tree():
			_rebuild()





func get_target_objects()->Array:
	var scope = Profiler.scope(self, "get_target_objects", [])

	var target_objects: = []
	for script in _selected_scripts:
		for path in _selected_scripts[script]:
			var object = _get_by_path(path)
			if is_instance_valid(object):
				target_objects.append(object)

	return target_objects

func get_property_dict()->Dictionary:
	var scope = Profiler.scope(self, "get_property_dict", [])

	return _property_dict





func add_target_path(path:NodePath)->void :
	var scope = Profiler.scope(self, "add_target_path", [path])

	var object = _get_by_path(path)
	var script = object.get_script()
	var wants_rebuild: = false
	if not script in _selected_scripts:
		_selected_scripts[script] = []
		wants_rebuild = true
	_selected_scripts[script].append(path)

	if wants_rebuild and is_inside_tree():
		_rebuild()

func remove_target_path(path:NodePath)->void :
	var scope = Profiler.scope(self, "remove_target_path", [path])

	var object = _get_by_path(path)
	var script = object.get_script()
	_selected_scripts[script].erase(path)
	if _selected_scripts[script].size() == 0:
		_selected_scripts.erase(script)
		if is_inside_tree():
			_rebuild()

func add_target_node(node:Node)->void :
	var scope = Profiler.scope(self, "add_target_node", [node])

	var script = node.get_script()
	var wants_rebuild: = false
	if not script in _selected_scripts:
		_selected_scripts[script] = []
		wants_rebuild = true
	_selected_scripts[script].append(get_path_to(node))

	if wants_rebuild and is_inside_tree():
		_rebuild()

func remove_target_node(node:Node)->void :
	var scope = Profiler.scope(self, "remove_target_node", [node])

	var script = node.get_script()
	_selected_scripts[script].erase(get_path_to(node))
	if _selected_scripts[script].size() == 0:
		_selected_scripts.erase(script)
		if is_inside_tree():
			_rebuild()

func clear_selection()->void :
	_selected_scripts.clear()
	_property_dict.clear()
	emit_signal("changed")





func _parse_paths(source:Array, dest:Dictionary)->void :
	var scope = Profiler.scope(self, "_parse_paths", [source, dest])

	for path in source:
		var components = path.split(":")
		assert (components.size() >= 2, "Inspector blacklist path must have a leading :")
		var category = components[1].strip_edges()
		if not category in dest:
			dest[category] = {}
		if components.size() >= 3:
			var group = components[2].strip_edges()
			if not group in dest[category]:
				dest[category][group] = []
			if components.size() >= 4:
				var property = components[3].strip_edges()
				if not property in dest[category][group]:
					dest[category][group].append(property)

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	_rebuild()

func _rebuild()->void :
	var scope = Profiler.scope(self, "rebuild", [])

	var prev_property_dict = _property_dict.duplicate()
	_property_dict.clear()

	var objects: = []
	for script in _selected_scripts:
		objects.append(_get_by_path(_selected_scripts[script][0]))

	if _property_dict != prev_property_dict:
		_populate_properties(objects)
		emit_signal("changed")

func _get_by_path(path:NodePath)->Object:
	var object = get_node_or_null(path)
	if is_instance_valid(object):
		if path.get_subname_count() > 0:
			object = object.get_indexed(path.get_concatenated_subnames())
		return object
	return null

func _read_category_property(category_property:Dictionary, property_dict:Dictionary)->String:
	var scope = Profiler.scope(self, "read_category_property", [category_property, property_dict])

	var category_head = category_property.name
	property_dict[category_head] = {
		"":{}
	}
	return category_head

func _read_group_property(category_head:String, group_property:Dictionary, property_dict:Dictionary)->String:
	var scope = Profiler.scope(self, "read_group_property", [category_head, group_property, property_dict])

	if not category_head in property_dict:
		property_dict[category_head] = {
			"":{}
		}

	var group_head = group_property.name
	property_dict[category_head][group_head] = {}
	return group_head

func _read_editor_property(category_head:String, group_head:String, editor_property:Dictionary, property_dict:Dictionary):
	var scope = Profiler.scope(self, "read_editor_property", [category_head, group_head, editor_property, property_dict])

	if not property_filter.empty() and editor_property.name.to_lower().replace("_", " ").find(property_filter.to_lower()) == - 1:
		return 

	if not group_head in property_dict[category_head]:
		property_dict[category_head][group_head] = {}

	property_dict[category_head][group_head][editor_property.name] = editor_property

func _object_has_property(object:Object, property_name:String, usage_flags:int = 0)->bool:
	var scope = Profiler.scope(self, "object_has_property", [object, property_name, usage_flags])

	var object_properties = object.get_property_list()
	for property in object_properties:
		if usage_flags == 0 or property.usage & usage_flags:
			if property.name == property_name:
				return true
	return false

func _objects_have_property(objects:Array, property_name:String, usage_flags:int = 0)->bool:
	var scope = Profiler.scope(self, "objects_have_property", [objects, property_name, usage_flags])

	for object in objects:
		if not _object_has_property(object, property_name, usage_flags):
			return false
	return true

func _filter_multi_select(objects:Array, property_dict:Dictionary):
	var scope = Profiler.scope(self, "filter_multi_select", [objects, property_dict])

	for category in property_dict.keys():
		if category.empty():
			continue

		if not _objects_have_property(objects, category, PROPERTY_USAGE_CATEGORY):
			property_dict.erase(category)
		else :
			for group in property_dict[category].keys():
				if not group.empty() and not _objects_have_property(objects, group, PROPERTY_USAGE_GROUP):
					property_dict[category].erase(group)
				else :
					for property in property_dict[category][group].keys():
						if not _objects_have_property(objects, property, PROPERTY_USAGE_EDITOR):
							property_dict[category][group].erase(property)

func _sculpt_property_dict(property_dict:Dictionary)->Dictionary:
	var scope = Profiler.scope(self, "_sculpt_property_dict", [property_dict])

	if _sculpt_dict.empty():
		return property_dict

	var sculpted: = {
		"":{
			"":{}
		}
	}

	for category in _sculpt_dict:
		if _sculpt_dict[category].empty():
			if category in property_dict:
				for group in property_dict[category]:
					for property in property_dict[category][group]:
						sculpted[""][group][property] = property_dict[category][group][property]
		else :
			for group in _sculpt_dict[category]:
				if category in property_dict:
					if group in property_dict[category]:
						for property in property_dict[category][group]:
							sculpted[""][""][property] = property_dict[category][group][property]

	return sculpted

func _filter_blacklist(property_dict:Dictionary, blacklist_dict:Dictionary):
	var scope = Profiler.scope(self, "_filter_blacklist", [property_dict, blacklist_dict])

	for category in blacklist_dict:
		if blacklist_dict[category].empty():
			if category in property_dict:
				property_dict.erase(category)
		else :
			for group in blacklist_dict[category]:
				if blacklist_dict[category].empty():
					if category in property_dict:
						if group in property_dict[category]:
							property_dict[category].erase(group)
				else :
					for property in blacklist_dict[category][group]:
						if category in property_dict:
							if group in property_dict[category]:
								if property in property_dict[category][group]:
									property_dict[category][group].erase(property)

func _filter_empty_groups(property_dict:Dictionary):
	var scope = Profiler.scope(self, "_filter_empty_groups", [property_dict])

	for category in property_dict.keys():
		for group in property_dict[category].keys():
			if property_dict[category][group].empty():
				property_dict[category].erase(group)

func _filter_empty_categories(property_dict:Dictionary):
	var scope = Profiler.scope(self, "_filter_empty_categories", [property_dict])

	for category in property_dict.keys():
		if property_dict[category].empty():
			property_dict.erase(category)

func _fetch_custom_categories(objects:Array)->Dictionary:
	var scope = Profiler.scope(self, "_fetch_custom_categories", [objects])

	var custom_categories: = {}

	for object in objects:
		if not object.has_method("get_custom_categories"):
			custom_categories = {}
			break

		var object_categories = object.get_custom_categories()
		for category in object_categories:
			if not category in custom_categories:
				custom_categories[category] = {}
			for group in object_categories[category]:
				if not group in custom_categories[category]:
					custom_categories[category][group] = []
				for property in object_categories[category][group]:
					custom_categories[category][group].append(property)

	return custom_categories

func _fetch_custom_property_names(objects:Array)->Dictionary:
	var scope = Profiler.scope(self, "_fetch_custom_property_names", [objects])

	var custom_property_names: = {}

	for object in objects:
		if not object.has_method("_get_custom_property_names"):
			custom_property_names = {}
			break

		var object_custom_property_names = object.get_custom_property_names()
		for property in object_custom_property_names:
			custom_property_names[property] = object_custom_property_names[property]

	return custom_property_names

func _populate_properties(objects:Array)->void :
	var scope = Profiler.scope(self, "_populate_properties", [objects])

	_property_dict = {
		"":{
			"":{}
		}
	}

	
	for object in objects:
		var category_head: = ""
		var group_head: = ""
		var properties = object.get_property_list()
		for property in properties:
			if property.name == "global_transform" or property.name == "rotation" or property.name == "scale":
				_read_editor_property(category_head, group_head, property, _property_dict)
			elif property.usage & PROPERTY_USAGE_CATEGORY:
				category_head = _read_category_property(property, _property_dict)
			elif property.usage & PROPERTY_USAGE_GROUP:
				group_head = _read_group_property(category_head, property, _property_dict)
			elif property.usage & PROPERTY_USAGE_EDITOR:
				_read_editor_property(category_head, group_head, property, _property_dict)
			elif property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				pass
			else :
				category_head = ""
				group_head = ""

	
	_filter_multi_select(objects, _property_dict)

	
	var blacklist_dict = _blacklist_dict.duplicate(true)

	for object in objects:
		if object.has_method("get_blacklist_paths"):
			_parse_paths(object.get_blacklist_paths(), blacklist_dict)

	_filter_blacklist(_property_dict, blacklist_dict)

	
	_property_dict = _sculpt_property_dict(_property_dict)

	
	var custom_categories: = _fetch_custom_categories(objects)

	var erase_categories: = []
	var erase_groups: = []
	var erase_properties: = []
	if not custom_categories.empty():
		
		for category in custom_categories.keys():
			for group in custom_categories[category].keys():
				if not category in custom_categories:
					continue

				if not group in custom_categories[category]:
					continue

				for property in custom_categories[category][group]:
					for object in objects:
						var object_categories = object.get_custom_categories()
						if not category in object_categories:
							custom_categories.erase(category)
							break

						if not group in object_categories[category]:
							custom_categories[category].erase(group)
							break

						if not property in object_categories[category][group]:
							custom_categories[category][group].erase(property)
							break

		
		for category in custom_categories.keys():
			if not category in _property_dict:
				_property_dict[category] = {}
			for group in custom_categories[category].keys():
				if not group in _property_dict[category]:
					_property_dict[category][group] = {}
				for property in custom_categories[category][group]:
					for dict_property in _property_dict[""][""].keys():
						if property == dict_property:
							if category != "":
								_property_dict[category][group][property] = _property_dict[""][""][property]
								_property_dict[""][""].erase(property)
							break

	
	_filter_empty_groups(_property_dict)

	
	_filter_empty_categories(_property_dict)

	
	var custom_property_names: = _fetch_custom_property_names(objects)

	for category in _property_dict.keys():
		for group in _property_dict[category].keys():
			for property in _property_dict[category][group].keys():
				if property in custom_property_names:
					_property_dict[category][group][property].display_name = custom_property_names[property]
				else :
					_property_dict[category][group][property].display_name = property

	if DEBUG:
		print(custom_property_names)
		for category in _property_dict:
			print(category)
			for group in _property_dict[category]:
				print("    " + group)
				for property in _property_dict[category][group]:
					print("        " + property)
