class_name PaintSurfaceManager
extends Node

signal active_surface_changed(new_active_surface)

export (NodePath) var tool_mode_path: = NodePath()
var active_surface:int = BrickHillBrickObject.SurfaceType.FLAT setget set_active_surface

func get_tool_mode()->ToolMode:
	var scope = Profiler.scope(self, "get_tool_mode", [])

	return get_node(tool_mode_path) as ToolMode

func set_active_surface(new_active_surface:int)->void :
	var scope = Profiler.scope(self, "set_active_surface", [new_active_surface])

	if active_surface != new_active_surface:
		active_surface = new_active_surface
		emit_signal("active_surface_changed", active_surface)

func is_face_modifier_active()->bool:
	var scope = Profiler.scope(self, "is_face_modifier_active", [])

	return not Input.is_key_pressed(KEY_CONTROL) and not Input.is_key_pressed(KEY_META)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func is_active()->bool:
	var scope = Profiler.scope(self, "is_active", [])

	return get_tool_mode().tool_mode == ToolMode.ToolMode.PaintSurface

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	if not is_active():
		return 

	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			if InterfaceSelectable.is_implementor(node):
				var selection = InterfaceSelectable.get_selection(node)
				var face_idx = get_face_index(selection, click_normal)
				paint_surface(selection, face_idx)

func get_face_index(node:Node, click_normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_face_index", [node, click_normal])

	var face_idx = - 1
	if is_face_modifier_active():
		if node is BrickHillBrickObject:
			var shape = node.shape
			var local_normal = node.global_transform.basis.orthonormalized().xform_inv(click_normal)
			face_idx = ModelManager.get_brick_mesh_hovered_face_idx(shape, local_normal)
	return face_idx

func paint_surface(node:BrickHillBrickObject, face_idx:int)->void :
	var scope = Profiler.scope(self, "paint_surface", [node, face_idx])

	if not node:
		return 

	if node.locked:
		return 

	if face_idx == - 1:
		var wants_paint = false
		for i in range(0, node.surfaces.size()):
			if node.surfaces[i] != active_surface:
				wants_paint = true
				break

		if wants_paint:
			var surfaces: = PoolByteArray()
			for i in range(0, node.surfaces.size()):
				surfaces.append(active_surface)
			AssignProperty.new(node, "surfaces", surfaces).execute()
	else :
		if node.surfaces[face_idx] != active_surface:
			var surfaces: = node.surfaces
			surfaces[face_idx] = active_surface
			AssignProperty.new(node, "surfaces", surfaces).execute()

func paint_hovered_node()->void :
	var scope = Profiler.scope(self, "paint_hovered_node", [])

	var hovered_node = WorkshopDirectory.hovered_node()
	var node = hovered_node.hovered_node
	if is_instance_valid(node):
		var face_idx = get_face_index(node, hovered_node.hover_normal)
		paint_surface(node, face_idx)
