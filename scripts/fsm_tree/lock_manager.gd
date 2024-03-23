class_name LockManager
extends Node

export (NodePath) var tool_mode_path: = NodePath()

func get_tool_mode()->ToolMode:
	var scope = Profiler.scope(self, "get_tool_mode", [])

	return get_node(tool_mode_path) as ToolMode

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func is_active()->bool:
	var scope = Profiler.scope(self, "is_active", [])

	return get_tool_mode().tool_mode == ToolMode.ToolMode.Lock

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	if not is_active():
		return 

	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if InterfaceSelectable.is_implementor(node):
					var selection = InterfaceSelectable.get_selection(node)
					if selection is BrickHillObject:
						var group_ancestor = WorkshopDirectory.group_manager().find_group_ancestor(selection, true, true)
						if group_ancestor:
							toggle_lock(group_ancestor)
						else :
							toggle_lock(selection)

func toggle_lock(node:Node)->void :
	var scope = Profiler.scope(self, "toggle_lock", [node])

	if "locked" in node:
		AssignProperty.new(node, "locked", not node.locked).execute()
