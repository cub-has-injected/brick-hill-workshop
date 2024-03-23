class_name InspectorPropertyTreeView
extends Tree
tool 



export (NodePath) var model_path: = NodePath() setget set_model_path

export (Script) var category_label_control = preload("res://addons/inspector_control/scripts/inspector_controls/inspector_label.gd")
export (Script) var group_label_control = preload("res://addons/inspector_control/scripts/inspector_controls/inspector_label.gd")
export (Script) var property_label_control = preload("res://addons/inspector_control/scripts/inspector_controls/inspector_label.gd")

export (Array, Script) var property_controls: = [] setget set_property_controls

export (bool) var use_actions: = true

var _property_control_cdos: = {}
var _title_item:TreeItem = null

var sculpt_dict: = {}
var blacklist_dict: = {}
var property_dict: = {}





func set_model_path(new_model_path:NodePath)->void :
	Profiler.scope(self, "set_model_path", [new_model_path])

	if model_path != new_model_path:
		var old_model = get_model()
		if old_model:
			old_model.disconnect("changed", self, "populate_tree")

		model_path = new_model_path

		var new_model = get_model()
		if new_model:
			try_connect_signals()
			populate_tree()

func set_property_controls(new_property_controls:Array)->void :
	Profiler.scope(self, "set_property_controls", [new_property_controls])

	if property_controls != new_property_controls:
		_property_control_cdos.clear()

		for i in range(0, new_property_controls.size()):
			if new_property_controls[i] != null:
				var cdo = new_property_controls[i].new()
				if InterfaceInspectorProperty.is_implementor(cdo):
					_property_control_cdos[new_property_controls[i]] = cdo
				else :
					new_property_controls[i] = null

		property_controls = new_property_controls

		property_list_changed_notify()





func get_model()->InspectorPropertyModel:
	Profiler.scope(self, "get_model")

	return get_node_or_null(model_path) as InspectorPropertyModel





func _enter_tree()->void :
	Profiler.scope(self, "_enter_tree")

	try_connect_signals()
	populate_tree()

func try_connect_signals()->void :
	Profiler.scope(self, "try_connect_signals")

	var model = get_model()
	if not model.is_connected("changed", self, "populate_tree"):
		model.connect("changed", self, "populate_tree")

	var tree = get_tree()
	if not tree.is_connected("node_renamed", self, "on_scene_tree_node_renamed"):
		get_tree().connect("node_renamed", self, "on_scene_tree_node_renamed")

func on_scene_tree_node_renamed(node:Node)->void :
	Profiler.scope(self, "on_scene_tree_node_renamed", [node])

	if node in get_model().get_target_objects():
		update_title_item()

func populate_tree()->void :
	Profiler.scope(self, "populate_tree")

	clear()

	for child in get_children():
		if child.has_meta("inspector_property_tree_view_child"):
			remove_child(child)
			child.queue_free()

	var model = get_model()
	assert (model != null, "InspectorPropertyTreeView: Invalid model")

	var property_dict = model.get_property_dict()

	_title_item = create_item()
	_title_item.set_selectable(0, false)
	update_title_item()

	populate_tree_impl(_title_item, property_dict)

func update_title_item()->void :
	Profiler.scope(self, "update_title_item")

	var target_objects = get_model().get_target_objects()
	match target_objects.size():
		0:
			return 
		1:
			_title_item.set_text(0, target_objects[0].get_name())
		_:
			_title_item.set_text(0, "[Multi]")

func populate_tree_impl(root:TreeItem, property_dict:Dictionary)->void :
	Profiler.scope(self, "populate_tree_impl", [root, property_dict])

	assert (root != null, "Invalid root TreeItem")

	var target_objects = get_model().get_target_objects()
	if target_objects.size() == 0:
		return 

	
	var category_keys = property_dict.keys()
	if "" in category_keys:
		category_keys.erase("")
		category_keys.push_front("")

	for category in category_keys:
		var category_item:TreeItem

		if category.empty():
			
			category_item = root
		else :
			
			category_item = create_item(root)
			populate_label_item(category_item, category, category_label_control)

		
		var group_keys = property_dict[category].keys()
		if "" in group_keys:
			group_keys.erase("")
			group_keys.push_front("")

		for group in group_keys:
			var group_item:TreeItem

			if group.empty():
				
				group_item = category_item
			else :
				
				var is_group_property: = true
				var group_property:String
				for node in target_objects:
					if not node.has_method("get_group_properties"):
						is_group_property = false
						break

					
					var properties = node.get_group_properties()

					
					if not group in properties:
						is_group_property = false
						break

					group_property = properties[group]


				if is_group_property:
					
					var group_property_dict = property_dict[category][group][group_property]
					group_item = create_item(category_item)
					var label = Label.new()
					label.text = group
					label.add_font_override("font", BrickHillResources.FONTS.regular)
					populate_property_item(group_item, target_objects[0], group_property_dict, group, group_label_control, HORIZONTAL)
				if not is_group_property:
					
					group_item = create_item(category_item)
					populate_label_item(group_item, group, group_label_control)

			
			for property in property_dict[category][group]:
				var is_group_property: = true
				for node in target_objects:
					if not node.has_method("get_group_properties"):
						is_group_property = false
						break

					var group_properties = node.get_group_properties()
					if not property in group_properties.values():
						is_group_property = false
						break

				if is_group_property:
					continue

				var pd = property_dict[category][group][property]
				var property_value = create_item(group_item)
				populate_property_item(property_value, target_objects[0], pd, selective_capitalize(pd.display_name), property_label_control, VERTICAL)

func populate_label_item(item:TreeItem, name:String, script:Script)->void :
	Profiler.scope(self, "populate_label_item", [item, name, script])

	var control_path: = NodePath("./" + name)
	var control = get_node_or_null(control_path)
	if not control:
		control = script.new()
		control.text = name
		control.set_meta("inspector_property_tree_view_child", true)
		add_child(control)
		control.set_name(name)

	item.set_metadata(0, name)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_draw(0, self, "draw_label_item")
	item.set_selectable(0, false)
	item.custom_minimum_height = control.rect_size.y

func populate_property_item(item:TreeItem, object:Object, property:Dictionary, name:String, label_script:Script, orientation:int)->void :
	Profiler.scope(self, "populate_property_item", [item, object, property, name, label_script, orientation])

	var control_path: = NodePath("./" + property.name)
	var wrap: = get_node_or_null(control_path) as Control
	var control:Control
	if wrap:
		control = wrap.get_node_or_null(control_path)
	else :
		control = create_control(property)
		control.set_name(property.name)

		var label = label_script.new()
		label.text = name

		if control.has_method("get_orientation"):
			orientation = control.get_orientation()

		if orientation == HORIZONTAL:
			wrap = HBoxContainer.new()
			wrap.set("custom_constants/separation", 8)
		else :
			wrap = VBoxContainer.new()

		wrap.set_meta("inspector_property_tree_view_child", true)
		wrap.set_name(property.name)

		wrap.add_child(label)
		wrap.add_child(control)

		add_child(wrap)

		wrap.rect_min_size.y = control.rect_min_size.y

	InterfaceInspectorProperty.set_data(control, object, property)

	item.set_meta("object", object)
	item.set_metadata(0, property.name)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_draw(0, self, "draw_property_item")
	item.set_selectable(0, false)
	item.custom_minimum_height = wrap.rect_min_size.y

func selective_capitalize(string:String)->String:
	Profiler.scope(self, "selective_capitalize", [string])

	if string == string.to_lower():
		string = string.capitalize()
	return string

func create_label(property:Dictionary)->Label:
	Profiler.scope(self, "create_label", [property])

	var label = Label.new()
	label.text = selective_capitalize(property.display_name)
	return label

func create_control(property:Dictionary)->Control:
	Profiler.scope(self, "create_control", [property])

	var control = null

	for property_control in _property_control_cdos.values():
		if InterfaceInspectorProperty.supported_property(property_control, property):
			control = property_control.duplicate()
			break

	if control != null:
		if control.has_signal("property_changed"):
			control.connect("property_change_begin", self, "on_control_property_change_begin")
			control.connect("property_changed", self, "on_control_property_changed")
			control.connect("property_change_end", self, "on_control_property_change_end")

	return control

var property_begin_values: = {}

func on_control_property_change_begin(name:String)->void :
	Profiler.scope(self, "on_control_property_change_begin", [name])

	if not use_actions:
		return 

	var target_objects = get_model().get_target_objects()
	for node in target_objects:
		if name in node:
			if not node in property_begin_values:
				property_begin_values[node] = {}
			var value = node.get(name)
			if value is Array:
				value = value.duplicate()
			property_begin_values[node][name] = value


func on_control_property_changed(name:String, value)->void :
	Profiler.scope(self, "on_control_property_changed", [name, value])

	var target_objects = get_model().get_target_objects()

	
	var index = - 1
	var parts = name.split("[", false, 1)
	if parts.size() > 1:
		name = parts[0]
		var after = parts[1]
		parts = after.split("]", false, 1)
		if parts.size() > 0:
			index = parts[0].to_int()

	for node in target_objects:
		if name in node:
			var out_val = value
			
			if index >= 0:
				out_val = node.get(name)
				out_val[index] = value[index]
			node.set(name, out_val)

	
	if value is bool:
		update()

func on_control_property_change_end(name:String)->void :
	Profiler.scope(self, "on_control_property_change_end", [name])

	if not use_actions:
		return 

	BeginCompositeAction.new().execute()

	for node in property_begin_values:
		for property in property_begin_values[node]:
			var action = SetProperty.new(node, name, node.get(name))
			action.from_value = property_begin_values[node][property]
			action.execute()

	EndCompositeAction.new().execute()

	property_begin_values.clear()

var drawing: = false setget set_drawing
func set_drawing(new_drawing:bool)->void :
	Profiler.scope(self, "set_drawing", [new_drawing])

	if drawing != new_drawing:
		drawing = new_drawing
		if drawing:
			draw_start()
		else :
			draw_end()

func draw_start()->void :
	Profiler.scope(self, "draw_start")

	for child in get_children():
		if child.has_meta("inspector_property_tree_view_child"):
			child.visible = false

func draw_end()->void :
	Profiler.scope(self, "draw_end")
	pass

func draw_label_item(item:TreeItem, rect:Rect2)->void :
	Profiler.scope(self, "draw_label_item", [item, rect])

	if not drawing:
		set_drawing(true)

	var control_name = item.get_metadata(0)
	var control_path: = NodePath("./" + control_name)
	var control: = get_node_or_null(control_path) as Control
	if not control:
		return 

	var separation = Vector2(get_constant("hseparation"), get_constant("vseparation"))
	control.rect_position = rect.position + separation
	control.rect_size = rect.size - separation * 2
	control.visible = true

	control.update()

func draw_property_item(item:TreeItem, rect:Rect2)->void :
	Profiler.scope(self, "draw_property_item", [item, rect])

	if not drawing:
		set_drawing(true)

	var property = item.get_metadata(0)
	var control_path: = NodePath("./" + property)
	var control: = get_node_or_null(control_path) as Control
	if not control:
		return 

	var separation = Vector2(get_constant("hseparation"), get_constant("vseparation"))
	control.rect_position = rect.position + separation
	control.rect_size = rect.size - separation * 2
	control.visible = true

	var sub_control = control.get_node_or_null(control_path)
	if sub_control:
		if sub_control.rect_min_size.y > 0:
			item.custom_minimum_height = sub_control.rect_min_size.y

	var object = item.get_meta("object")
	if not is_instance_valid(object):
		return 

	if object.has_method("get_property_enabled"):
		control.propagate_call("set_enabled", [object.get_property_enabled(property)], true)

	control.update()

func _draw()->void :
	Profiler.scope(self, "_draw")

	if drawing:
		set_drawing(false)
	else :
		
		set_drawing(true)
		set_drawing(false)
