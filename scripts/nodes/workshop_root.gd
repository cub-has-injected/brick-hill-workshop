class_name WorkshopRoot
extends Node
tool 

enum WorkshopMode{
	Edit = 0, 
	Simulate = 1, 
	Play = 2
}

var mode:int = WorkshopMode.Edit
var cached_set_root:SetRoot = null
var sim_set_root = null


func set_simulating(new_simulating:bool)->void :
	var scope = Profiler.scope(self, "set_simulating", [new_simulating])

	if new_simulating:
		set_mode(WorkshopMode.Simulate)
	else :
		set_mode(WorkshopMode.Edit)

func set_playing(new_playing:bool)->void :
	var scope = Profiler.scope(self, "set_playing", [new_playing])

	if new_playing:
		set_mode(WorkshopMode.Play)
	else :
		set_mode(WorkshopMode.Edit)

func set_mode(new_mode:int)->void :
	var scope = Profiler.scope(self, "set_mode", [new_mode])

	if mode != new_mode:
		mode = new_mode
		match mode:
			WorkshopMode.Edit:
				stop_simulate()
			WorkshopMode.Simulate:
				start_simulate()
			WorkshopMode.Play:
				start_simulate(true)


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	WorkshopSignals.wire_signals(true)

	WorkshopDirectory.scene_tree_control().filter_node_func = funcref(self, "filter_node")
	WorkshopDirectory.scene_tree_control().node_is_selected_func = funcref(self, "node_is_selected")
	WorkshopDirectory.scene_tree_control().node_accepts_children_func = funcref(self, "node_accepts_children")

	WorkshopDirectory.bandbox_selector().try_select_node_func = funcref(self, "try_bandbox_select_node")
	WorkshopDirectory.bandbox_selector().try_deselect_node_func = funcref(self, "try_bandbox_deselect_node")

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree")

	WorkshopSignals.wire_signals(false)

func filter_node(node:Node)->bool:
	var scope = Profiler.scope(self, "filter_node", [node])

	var scene_tree_filter = $UIControls / SidebarTabs / WorkspaceTab / VSplitContainer / SceneTreeVBox / Control / SceneTreeSearch.text
	return (node is SetRoot or node is BrickHillObject) and (node.name.to_lower().find(scene_tree_filter.to_lower()) != - 1 or scene_tree_filter.empty())

func node_is_selected(node:Node)->bool:
	var scope = Profiler.scope(self, "node_is_selected", [node])

	var selection_manager = WorkshopDirectory.selected_nodes()
	assert (selection_manager)
	return selection_manager.selected_nodes.find(node) != - 1

func node_accepts_children(node:Node)->bool:
	var scope = Profiler.scope(self, "node_accepts_children", [node])

	var accepts_children = node is SetRoot or node is BrickHillGroup
	return accepts_children

func on_action_do(action:ActionData.Base)->void :
	var scope = Profiler.scope(self, "on_action_do", [action])

	if action is SetGetAction and action.target_ref.get_ref() == WorkshopDirectory.set_root():
		var scene_tree_control = WorkshopDirectory.scene_tree_control()
		assert (scene_tree_control)

		var set_root = WorkshopDirectory.set_root()
		assert (set_root)

		scene_tree_control.root_node = scene_tree_control.get_path_to(set_root)

	if action is SetProperty:
		var selection_manager = WorkshopDirectory.selected_nodes()
		var target = action.target_ref.get_ref()
		if target in selection_manager.selected_nodes:
			WorkshopDirectory.composite_object().update_composite_data(true)

func on_action_undo(action:ActionData.Base)->void :
	var scope = Profiler.scope(self, "on_action_undo", [action])

	if action is CreateNodeAction:
		WorkshopDirectory.selected_nodes().remove_selected_node(action.instance)


onready var enable_disable_nodes: = [
	$UIControls / ToolBar, 
	$UIControls / EditBar, 
	$UIControls / MenuBar, 
	$UIControls / SidebarTabs
]

var _player:Node = null
var _cached_tool_mode:int = ToolMode.ToolMode.None

func set_ui_disabled(disabled:bool)->void :
	var scope = Profiler.scope(self, "set_ui_disabled", [disabled])

	for node in enable_disable_nodes:
		node.set_disabled(disabled)

func start_simulate(play:bool = false)->void :
	var scope = Profiler.scope(self, "start_simulate", [play])

	var set_root_container = WorkshopDirectory.set_root_container()
	if not set_root_container:
		return 

	var set_root = WorkshopDirectory.set_root()
	if not set_root:
		return 

	set_ui_disabled(true)

	WorkshopDirectory.selected_nodes().clear_selected_nodes()
	WorkshopDirectory.hotkey_manager().enabled = false

	var tool_mode = WorkshopDirectory.tool_mode()
	_cached_tool_mode = tool_mode.tool_mode
	tool_mode.tool_mode = ToolMode.ToolMode.None

	cached_set_root = set_root
	set_root.set_block_signals(true)

	set_root_container.remove_child(set_root)
	sim_set_root = set_root.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS)
	sim_set_root.set_workshop(false)
	set_root_container.add_child(sim_set_root)

	WorkshopDirectory.scene_tree_control().rebuild_tree()

	if play:
		WorkshopDirectory.viewport_control().grab_focus()
		_player = preload("res://scenes/testing/character/instanced/player.tscn").instance()
		var player_spawn = sim_set_root.get_workshop_spawn_point()
		if player_spawn:
			_player.global_transform = player_spawn.global_transform
		set_root_container.add_child(_player)

		var rigid_body = InterfaceRigidBody.get_rigid_body(_player)
		rigid_body.gravity_scale = sim_set_root.player_gravity_scale

#		_player.set_avatar_data(SiteSession.get_avatar_data())
		WorkshopDirectory.workshop_camera().clear_input()

func find_player_spawns(candidate:Node)->Array:
	var scope = Profiler.scope(self, "find_player_spawns", [candidate])

	var player_spawns: = []

	if candidate is BrickHillSpawnPoint:
		player_spawns.append(candidate)

	for child in candidate.get_children():
		player_spawns += find_player_spawns(child)

	return player_spawns

func stop_simulate()->void :
	var scope = Profiler.scope(self, "stop_simulate")

	if not sim_set_root:
		return 

	var set_root_container = WorkshopDirectory.set_root_container()
	if not set_root_container:
		return 

	if not cached_set_root:
		return 

	WorkshopDirectory.tool_bar().set_disabled(false)
	WorkshopDirectory.hotkey_manager().enabled = true

	var tool_mode = WorkshopDirectory.tool_mode()
	tool_mode.tool_mode = _cached_tool_mode
	_cached_tool_mode = - 1

	set_ui_disabled(false)

	set_root_container.remove_child(sim_set_root)
	set_root_container.add_child(cached_set_root)
	cached_set_root.set_block_signals(false)
	sim_set_root.queue_free()
	sim_set_root = null

	WorkshopDirectory.selected_nodes().clear_selected_nodes()
	WorkshopDirectory.scene_tree_control().rebuild_tree()

	cached_set_root = null

	if is_instance_valid(_player):
		set_root_container.remove_child(_player)
		_player.queue_free()

func set_world_grid_visible(visible:bool)->void :
	var scope = Profiler.scope(self, "set_world_grid_visible", [visible])

	WorkshopDirectory.main_viewport_root().get_node("WorldGrid").visible = visible

func toggle_world_grid_visible()->void :
	var scope = Profiler.scope(self, "toggle_world_grid_visible")

	var world_grid = WorkshopDirectory.main_viewport_root().get_node("WorldGrid")
	world_grid.visible = not world_grid.visible

func delete_selected_nodes()->void :
	var scope = Profiler.scope(self, "delete_selected_nodes")

	var selection_manager = WorkshopDirectory.selected_nodes()

	var selected_nodes: = []
	for node in selection_manager.selected_nodes:
		if node is BrickHillObject:
			selected_nodes.append(node)

	if selected_nodes.empty():
		return 

	selection_manager.clear_selected_nodes()

	BeginCompositeAction.new().execute()
	for node in selected_nodes:
		MoveChildAction.new(node.get_parent(), node, node.get_index()).execute()
		DestroyNodeAction.new(node).execute()
	EndCompositeAction.new().execute()

func copy_selected_nodes(cut:bool)->void :
	var scope = Profiler.scope(self, "copy_selected_nodes", [cut])

	var selected_nodes: = []
	for node in WorkshopDirectory.selected_nodes().selected_nodes:
		if node is BrickHillObject:
			selected_nodes.append(node)

	if selected_nodes.empty():
		return 

	var copy_buffer = WorkshopDirectory.copy_buffer()
	copy_buffer.copy(selected_nodes)

	if cut:
		delete_selected_nodes()

func duplicate_selected_nodes()->void :
	var scope = Profiler.scope(self, "duplicate_selected_nodes")

	BeginCompositeAction.new().execute()

	var nodes: = []
	for copy_node in WorkshopDirectory.selected_nodes().selected_nodes:
		var node = copy_node.duplicate()
		node.name = copy_node.name
		CreateNodeAction.new(node, get_paste_parent()).execute()
		nodes.append(node)

	EndCompositeAction.new().execute()

func get_paste_parent()->Node:
	var scope = Profiler.scope(self, "get_paste_parent")

	var active_group = WorkshopDirectory.group_manager().active_group
	var parent:Node
	if active_group:
		parent = active_group
	else :
		parent = WorkshopDirectory.set_root()
	return parent

func paste()->void :
	var scope = Profiler.scope(self, "paste")

	var copy_buffer = WorkshopDirectory.copy_buffer()
	var parent = get_paste_parent()
	copy_buffer.paste(parent)

func try_ungroup_nodes(group:bool)->bool:
	var scope = Profiler.scope(self, "try_ungroup_nodes", [group])

	var selected_nodes = WorkshopDirectory.selected_nodes().selected_nodes
	if selected_nodes.size() == 1:
		var selected_node = selected_nodes[0]
		if group:
			if selected_node is BrickHillGlue:
				ungroup_nodes(selected_node)
				return true
		else :
			if selected_node is BrickHillGroup and not selected_node is BrickHillGlue:
				ungroup_nodes(selected_node)
				return true

	return false

func group_selection()->void :
	var scope = Profiler.scope(self, "group_selection")

	if try_ungroup_nodes(false):
		return 

	group_nodes(BrickHillGroup.new())


func glue_selection()->void :
	var scope = Profiler.scope(self, "glue_selection")

	if try_ungroup_nodes(true):
		return 

	group_nodes(BrickHillGlue.new())

func group_nodes(group:BrickHillGroup)->void :
	var scope = Profiler.scope(self, "group_nodes", [group])

	var selected_nodes = WorkshopDirectory.selected_nodes().selected_nodes.duplicate()
	if selected_nodes.size() == 0:
		return 

	WorkshopDirectory.selected_nodes().clear_selected_nodes()

	var origin = Vector3.ZERO
	var index = - 1
	var parent = null
	for selected_node in selected_nodes:
		origin += selected_node.global_transform.origin

		if index == - 1:
			index = selected_node.get_index()
		else :
			index = min(index, selected_node.get_index())

		var candidate_parent = selected_node.get_parent()
		if not parent:
			parent = candidate_parent

		assert (parent == candidate_parent, "Can't group nodes from different parents")

	origin /= selected_nodes.size()
	group.transform.origin = origin

	BeginCompositeAction.new().execute()
	CreateNodeAction.new(group, parent).execute()
	MoveChildAction.new(parent, group, index).execute()

	var parents: = []
	var indices: = []
	for i in range(0, selected_nodes.size()):
		parents.append(group)
		indices.append(i)

	for node in selected_nodes:
		ReparentChildAction.new(node.get_parent(), group, node, ["global_transform"]).execute()

	EndCompositeAction.new().execute()

	group.update_collision()

	WorkshopDirectory.selected_nodes().set_selected_nodes([group])
	group.update_origin()

func ungroup_nodes(group:BrickHillGroup)->void :
	var scope = Profiler.scope(self, "ungroup_nodes", [group])

	WorkshopDirectory.selected_nodes().clear_selected_nodes()

	var children: = []
	for child in group.get_children():
		if child is BrickHillObject:
			children.append(child)

	BeginCompositeAction.new().execute()

	for child in children:
		MoveChildAction.new(child.get_parent(), child, child.get_index()).execute()
		ReparentChildAction.new(group, group.get_parent(), child, ["global_transform"]).execute()
		MoveChildAction.new(group.get_parent(), child, group.get_index()).execute()

	MoveChildAction.new(group.get_parent(), group, group.get_index()).execute()
	DestroyNodeAction.new(group).execute()

	EndCompositeAction.new().execute()

	WorkshopDirectory.selected_nodes().set_selected_nodes(children)

func capture_mouse()->void :
	var scope = Profiler.scope(self, "capture_mouse")

	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func release_mouse()->void :
	var scope = Profiler.scope(self, "release_mouse")

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var viewport_control = WorkshopDirectory.viewport_control()
		assert (viewport_control)
		viewport_control.warp_mouse(viewport_control.rect_size * 0.5)

func undo()->void :
	var scope = Profiler.scope(self, "undo")
	ActionManager.undo()

func redo()->void :
	var scope = Profiler.scope(self, "redo")
	ActionManager.redo()

func scene_load_started()->void :
	var scope = Profiler.scope(self, "scene_load_started")

	var scene_tree_control = WorkshopDirectory.scene_tree_control()
	assert (scene_tree_control)

	scene_tree_control.root_node = NodePath()
	WorkshopDirectory.selected_nodes().clear_selected_nodes()
	ActionManager.clear()
	set_ui_disabled(true)

func scene_load_finished()->void :
	var scope = Profiler.scope(self, "scene_load_finished")

	var scene_tree_control = WorkshopDirectory.scene_tree_control()
	assert (scene_tree_control)

	var set_root = WorkshopDirectory.set_root()
	assert (set_root)

	print("Loaded set root with UUID: %s" % [set_root.uuid])

	scene_tree_control.root_node = scene_tree_control.get_path_to(set_root)

	var environment = set_root.get_node_or_null("BrickHillEnvironment")

	
	if not is_instance_valid(environment):
		print("Warning: Environment node not present. Recreating...")
		environment = BrickHillEnvironmentGen.new()
		set_root.add_child(environment)
		set_root.move_child(environment, 0)
		environment.set_name("BrickHillEnvironment")
		environment.set_owner(set_root)

	var inspector_model = WorkshopDirectory.environment_inspector_model()
	inspector_model.clear_selection()
	inspector_model.add_target_node(environment)
	set_ui_disabled(false)

func scene_tree_filter_changed(new_filter:String)->void :
	var scope = Profiler.scope(self, "scene_tree_filter_changed")

	WorkshopDirectory.scene_tree_control().rebuild_tree()

func try_bandbox_select_node(node:Node)->Node:
	var scope = Profiler.scope(self, "try_bandbox_select_node", [node])

	var object_parent = node.get_parent()
	if not object_parent is BrickHillObject:
		return null

	var group_ancestor = WorkshopDirectory.group_manager().find_group_ancestor(object_parent, true, true)
	if group_ancestor:
		if group_ancestor in WorkshopDirectory.selected_nodes().selected_nodes:
			return null
		else :
			return group_ancestor
	else :
		return object_parent

func try_bandbox_deselect_node(node:Node)->Node:
	var scope = Profiler.scope(self, "try_bandbox_deselect_node", [node])

	var object_parent = node.get_parent()
	if not object_parent is BrickHillObject:
		return null

	var group_ancestor = WorkshopDirectory.group_manager().find_group_ancestor(object_parent, true, true)
	if group_ancestor:
		if not group_ancestor in WorkshopDirectory.selected_nodes().selected_nodes:
			return null
		else :
			for child in group_ancestor.get_children():
				if not child is BrickHillPhysicsObject:
					continue

				var rigid_body = child.get_rigid_body()
				if rigid_body == node:
					continue
				if rigid_body in WorkshopDirectory.bandbox_selector().get_overlapping_bodies():
					return null

			return group_ancestor
	else :
		return object_parent

func band_box_node_selected(node:Node)->void :
	var scope = Profiler.scope(self, "band_box_node_selected", [node])

	var selection_manager = WorkshopDirectory.selected_nodes()
	selection_manager.add_selected_node(node)

func band_box_node_deselected(node:Node)->void :
	var scope = Profiler.scope(self, "band_box_node_deselected", [node])

	var selection_manager = WorkshopDirectory.selected_nodes()
	selection_manager.remove_selected_node(node)

func selection_manager_selected_nodes_changed()->void :
	var scope = Profiler.scope(self, "selection_manager_selected_nodes_changed")

	update_widget_visibility()

	var paths: = []
	var composite_object = WorkshopDirectory.composite_object()
	for selected_node in WorkshopDirectory.selected_nodes().selected_nodes:
		paths.append(composite_object.get_path_to(selected_node))

	var movement_proxy = WorkshopDirectory.movement_proxy()
	if not composite_object.is_connected("rebuild_complete", movement_proxy, "target_changed"):
		composite_object.connect("rebuild_complete", movement_proxy, "target_changed", [], CONNECT_ONESHOT)

func update_widget_visibility()->void :
	var scope = Profiler.scope(self, "update_widget_visibility")

	var tool_mode = WorkshopDirectory.tool_mode().tool_mode

	var widgets_visible:bool

	if WorkshopDirectory.box_selector().active:
		widgets_visible = true
	else :
		widgets_visible = WorkshopDirectory.selected_nodes().selected_nodes.size() > 0

		if tool_mode == ToolMode.ToolMode.None:
			widgets_visible = false

		if tool_mode == ToolMode.ToolMode.ResizeFace or tool_mode == ToolMode.ToolMode.ResizeEdge or tool_mode == ToolMode.ToolMode.ResizeCorner:
			var selected_nodes = WorkshopDirectory.selected_nodes().selected_nodes
			if selected_nodes.size() != 1:
				widgets_visible = false
			else :
				for node in WorkshopDirectory.selected_nodes().selected_nodes:
					if node is BrickHillGroup:
						widgets_visible = false
						break

	WorkshopDirectory.widgets().visible = widgets_visible
	WorkshopDirectory.origin_dot().visible = widgets_visible

func on_tool_mode_changed(new_tool_mode:int)->void :
	var scope = Profiler.scope(self, "on_tool_mode_changed", [new_tool_mode])

	if new_tool_mode == ToolMode.ToolMode.RotatePlane:
		WorkshopDirectory.widgets_remote_transform().position_mode = WidgetsRemoteTransform.PositionMode.GroupOrigin
	else :
		WorkshopDirectory.widgets_remote_transform().position_mode = WidgetsRemoteTransform.PositionMode.TransformOrigin

	WorkshopDirectory.mouse_plane_move_handler().use_jump = new_tool_mode != ToolMode.ToolMode.MoveDrag

	match new_tool_mode:
		ToolMode.ToolMode.MoveDrag:
			pass
		ToolMode.ToolMode.MoveAxis:
			pass
		ToolMode.ToolMode.MovePlane:
			pass
		ToolMode.ToolMode.RotatePlane:
			pass
		ToolMode.ToolMode.ResizeFace:
			pass
		ToolMode.ToolMode.ResizeEdge:
			pass
		ToolMode.ToolMode.ResizeCorner:
			pass
		_:
			WorkshopDirectory.selected_nodes().clear_selected_nodes()

	match new_tool_mode:
		ToolMode.ToolMode.Lock:
			WorkshopDirectory.texture_property_overlay().visible = true
		ToolMode.ToolMode.Anchor:
			WorkshopDirectory.texture_property_overlay().visible = true
		_:
			WorkshopDirectory.texture_property_overlay().visible = false

	update_widget_visibility()

var cached_object_move_actions: = []

func begin_object_move()->void :
	var scope = Profiler.scope(self, "begin_object_move")

	for target_node in WorkshopDirectory.selected_nodes().selected_nodes:
		if target_node is SetRoot:
			cached_object_move_actions.append([])
			continue

		cached_object_move_actions.append([
			AssignProperty.new(target_node, "transform", target_node.transform), 
			AssignProperty.new(target_node, "size", target_node.size)
		])

func end_object_move()->void :
	var scope = Profiler.scope(self, "end_object_move")

	BeginCompositeAction.new().execute()

	var selected_nodes = WorkshopDirectory.selected_nodes().selected_nodes
	for i in range(0, selected_nodes.size()):
		var target_node = selected_nodes[i]

		if target_node is SetRoot:
			continue

		var actions = cached_object_move_actions[i]
		if target_node.transform != actions[0].from_value:
			actions[0].execute(target_node.transform)

		if target_node.size != actions[1].from_value:
			actions[1].execute(target_node.size)

	EndCompositeAction.new().execute()

	cached_object_move_actions.clear()

var pending_actions: = {}

func on_drag_state_changed(drag_state:int)->void :
	var scope = Profiler.scope(self, "on_drag_state_changed", [drag_state])

	var target_nodes = WorkshopDirectory.selected_nodes().selected_nodes
	match drag_state:
		MousePlaneMoveHandler.DragState.Dragging:
			pending_actions.clear()
			for target_node in target_nodes:
				if target_node is SetRoot:
					continue

				if "size" in target_node:
					pending_actions[target_node] = [AssignProperty.new(target_node, "transform", target_node.transform), AssignProperty.new(target_node, "size", target_node.size)]
				else :
					pending_actions[target_node] = [AssignProperty.new(target_node, "transform", target_node.transform), null]
		MousePlaneMoveHandler.DragState.None:
			for target_node in pending_actions:
				if target_node is SetRoot:
					continue

				var actions = pending_actions[target_node]
				var exec_actions = []

				if target_node.transform == actions[0].from_value and target_node.size == actions[1].from_value:
					continue

				BeginCompositeAction.new().execute()

				if target_node.transform != actions[0].from_value:
					actions[0].execute(target_node.transform)

				if actions[1] != null and target_node.size != actions[1].from_value:
					actions[1].execute(target_node.size)

				EndCompositeAction.new().execute()

			pending_actions.clear()

func on_box_selector_active_changed(active:bool)->void :
	var scope = Profiler.scope(self, "on_box_selector_active_changed", [active])

	var widgets = WorkshopDirectory.widgets()
	var movement_proxy = WorkshopDirectory.movement_proxy()
	var widgets_remote_transform = WorkshopDirectory.widgets_remote_transform()

	if active:
		var box_selector = WorkshopDirectory.box_selector()
		widgets.target = widgets.get_path_to(box_selector)
		movement_proxy.target = movement_proxy.get_path_to(box_selector)
		widgets_remote_transform.source = widgets_remote_transform.get_path_to(box_selector)

		var composite_object = WorkshopDirectory.composite_object()
		if composite_object.count() > 0:
			box_selector.global_transform.origin = composite_object.global_transform.origin
			box_selector.set_size(InterfaceSize.get_size(composite_object))
		else :
			var workshop_camera = WorkshopDirectory.workshop_camera()
			box_selector.global_transform.origin = workshop_camera.global_transform.origin - workshop_camera.global_transform.basis.z * workshop_camera.zoom
			box_selector.set_size(Vector3.ONE * 4)
	else :
		var composite_object = WorkshopDirectory.composite_object()
		widgets.target = widgets.get_path_to(composite_object)
		movement_proxy.target = movement_proxy.get_path_to(composite_object)
		widgets_remote_transform.source = widgets_remote_transform.get_path_to(composite_object)

	update_widget_visibility()

func flip_selection(x:bool, y:bool, z:bool)->void :
	var scope = Profiler.scope(self, "flip_selection", [x, y, z])

	var selection_manager = WorkshopDirectory.selected_nodes()
	for node in selection_manager.selected_nodes:
		if node.has_method("toggle_flip"):
			CallMethod.new(node, "toggle_flip", "toggle_flip", [x, y, z], [x, y, z]).execute()
