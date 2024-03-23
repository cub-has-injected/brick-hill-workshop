class_name SelectionInput
extends Node

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

func is_multi_select_active()->bool:
	var scope = Profiler.scope(self, "is_multi_select_active", [])

	return Input.is_key_pressed(KEY_CONTROL) or Input.is_key_pressed(KEY_META)

func is_sweep_select_active()->bool:
	var scope = Profiler.scope(self, "is_sweep_select_active", [])

	return Input.is_key_pressed(KEY_SHIFT)

func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func is_active()->bool:
	var scope = Profiler.scope(self, "is_active", [])

	if WorkshopDirectory.box_selector().active:
		return false

	match WorkshopDirectory.tool_mode().tool_mode:
		ToolMode.ToolMode.MoveDrag:
			return true
		ToolMode.ToolMode.MoveAxis:
			return true
		ToolMode.ToolMode.MovePlane:
			return true
		ToolMode.ToolMode.RotatePlane:
			return true
		ToolMode.ToolMode.ResizeFace:
			return true
		ToolMode.ToolMode.ResizeEdge:
			return true
		ToolMode.ToolMode.ResizeCorner:
			return true

	return false

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	if not is_active():
		return 

	var selection_manager = WorkshopDirectory.selected_nodes()

	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if InterfaceSelectable.is_implementor(node):
					var selection = InterfaceSelectable.get_selection(node)
					if selection is BrickHillObject:
						var group_ancestor = WorkshopDirectory.group_manager().find_group_ancestor(selection, true, true)
						if is_sweep_select_active():
							var target:Node
							
							if group_ancestor:
								target = group_ancestor
							else :
								target = selection

							if selection_manager.selected_nodes.size() == 1:
								var selected_node = selection_manager.selected_nodes[0]

								var from_center = InterfaceLocalCenter.get_local_center(selected_node)
								var from_pos = selected_node.global_transform.origin + from_center
								var from_size = InterfaceSize.get_size(selected_node)
								var from_half_size = from_size * 0.5

								var to_center = InterfaceLocalCenter.get_local_center(target)
								var to_pos = target.global_transform.origin + to_center
								var to_size = InterfaceSize.get_size(target)
								var to_half_size = to_size * 0.5

								var s = 0.99

								var sweep_hull = ConvexPolygonShape.new()
								sweep_hull.points = PoolVector3Array([
									from_pos + from_half_size * Vector3(1, 1, 1) * s, 
									from_pos + from_half_size * Vector3( - 1, 1, 1) * s, 
									from_pos + from_half_size * Vector3( - 1, - 1, 1) * s, 
									from_pos + from_half_size * Vector3(1, - 1, 1) * s, 

									from_pos + from_half_size * Vector3(1, 1, - 1) * s, 
									from_pos + from_half_size * Vector3( - 1, 1, - 1) * s, 
									from_pos + from_half_size * Vector3( - 1, - 1, - 1) * s, 
									from_pos + from_half_size * Vector3(1, - 1, - 1) * s, 

									to_pos + to_half_size * Vector3(1, 1, 1) * s, 
									to_pos + to_half_size * Vector3( - 1, 1, 1) * s, 
									to_pos + to_half_size * Vector3( - 1, - 1, 1) * s, 
									to_pos + to_half_size * Vector3(1, - 1, 1) * s, 

									to_pos + to_half_size * Vector3(1, 1, - 1) * s, 
									to_pos + to_half_size * Vector3( - 1, 1, - 1) * s, 
									to_pos + to_half_size * Vector3( - 1, - 1, - 1) * s, 
									to_pos + to_half_size * Vector3(1, - 1, - 1) * s, 
								])
								sweep_hull.margin = 0

								var query = PhysicsShapeQueryParameters.new()
								query.set_shape(sweep_hull)

								var space_state = get_tree().root.world.direct_space_state
								var results = space_state.intersect_shape(query, 10240)

								for result in results:
									var collider = result.collider
									if InterfaceSelectable.is_implementor(collider):
										var sweep_selection = InterfaceSelectable.get_selection(collider)
										var sweep_group_ancestor = WorkshopDirectory.group_manager().find_group_ancestor(sweep_selection, true, true)
										if sweep_group_ancestor:
											selection_manager.add_selected_node(sweep_group_ancestor)
										else :
											selection_manager.add_selected_node(sweep_selection)

						elif is_multi_select_active():
							
							if group_ancestor:
								selection_manager.add_selected_node(group_ancestor)
							else :
								selection_manager.add_selected_node(selection)
						else :
							
							if group_ancestor:
								if not group_ancestor in selection_manager.selected_nodes:
									selection_manager.set_selected_nodes([group_ancestor])
							else :
								if not selection in selection_manager.selected_nodes:
									selection_manager.set_selected_nodes([selection])
				elif not InterfaceBlockSelection.is_implementor(node):
					if not is_multi_select_active():
						selection_manager.clear_selected_nodes()
