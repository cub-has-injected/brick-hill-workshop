class_name GroupManager
extends Node

var hovered_group:BrickHillGroup = null setget set_hovered_group
var selected_group:BrickHillGroup = null setget set_selected_group
var active_group:BrickHillGroup = null setget set_active_group

func set_hovered_group(new_hovered_group:BrickHillGroup)->void :
	var scope = Profiler.scope(self, "set_hovered_group", [new_hovered_group])

	if hovered_group != new_hovered_group:
		if is_instance_valid(hovered_group):
			hovered_group.unhovered()
		hovered_group = new_hovered_group
		if is_instance_valid(hovered_group):
			hovered_group.hovered()

func set_selected_group(new_selected_group:BrickHillGroup)->void :
	var scope = Profiler.scope(self, "set_selected_group", [new_selected_group])

	if selected_group != new_selected_group:
		selected_group = new_selected_group

func set_active_group(new_active_group:BrickHillGroup)->void :
	var scope = Profiler.scope(self, "set_active_group", [new_active_group])

	if active_group != new_active_group:
		if is_instance_valid(active_group):
			active_group.set_active(false)
		active_group = new_active_group
		if is_instance_valid(active_group):
			active_group.set_active(true)

func find_group_ancestor(node:Node, filter_active_group_parent:bool, filter_active_group_siblings:bool)->BrickHillGroup:
	var scope = Profiler.scope(self, "find_group_ancestor", [node, filter_active_group_parent, filter_active_group_siblings])

	if not node:
		return null

	var candidate = null
	var current = node
	while true:
		var parent = current.get_parent()
		if not is_instance_valid(parent):
			break

		if parent is BrickHillGroup:
			if filter_active_group_parent and parent == active_group:
				break
			if filter_active_group_siblings and active_group in parent.get_children():
				break
			candidate = parent

		current = parent

	return candidate

func hovered_node_changed()->void :
	var scope = Profiler.scope(self, "hovered_node_changed", [])

	var hovered_node = WorkshopDirectory.hovered_node().hovered_node
	if not is_instance_valid(hovered_node):
		set_hovered_group(null)
		return 

	set_hovered_group(find_group_ancestor(hovered_node, true, true))

func selected_nodes_changed()->void :
	var scope = Profiler.scope(self, "selected_nodes_changed", [])

	var selected_nodes = WorkshopDirectory.selected_nodes().selected_nodes
	if selected_nodes.size() != 1:
		set_selected_group(null)
		return 

	var selected_node = selected_nodes[0]
	if not selected_node is BrickHillGroup:
		set_selected_group(null)
		return 

	set_selected_group(selected_node)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.doubleclick:
			if InterfaceSelectable.is_implementor(node):
				scope_in()
			else :
				scope_out()

func scope_in():
	var scope = Profiler.scope(self, "scope_in", [])

	set_active_group(selected_group)
	WorkshopDirectory.selected_nodes().clear_selected_nodes()

func scope_out():
	var scope = Profiler.scope(self, "scope_out", [])

	set_active_group(find_group_ancestor(active_group, false, false))
	WorkshopDirectory.selected_nodes().clear_selected_nodes()
