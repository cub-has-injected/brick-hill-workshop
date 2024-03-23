class_name PaintColorManager
extends Node

signal active_color_changed(new_active_color)

export (NodePath) var tool_mode_path: = NodePath()
var active_color:Color = Color.white setget set_active_color

func get_tool_mode()->ToolMode:
	var scope = Profiler.scope(self, "get_tool_mode", [])

	return get_node(tool_mode_path) as ToolMode

func set_active_color(new_active_color:Color)->void :
	var scope = Profiler.scope(self, "set_active_color", [new_active_color])

	if active_color != new_active_color:
		active_color = new_active_color
		emit_signal("active_color_changed", active_color)

func is_face_modifier_active()->bool:
	var scope = Profiler.scope(self, "is_face_modifier_active", [])

	return Input.is_key_pressed(KEY_CONTROL) or Input.is_key_pressed(KEY_META)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func is_active()->bool:
	var scope = Profiler.scope(self, "is_active", [])

	return get_tool_mode().tool_mode == ToolMode.ToolMode.PaintColor

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	if not is_active():
		return 

	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			if InterfaceSelectable.is_implementor(node):
				var selection = InterfaceSelectable.get_selection(node)
				var face_idx = - 1
				if is_face_modifier_active():
					if selection is BrickHillBrickObject:
						var shape = selection.shape
						var local_normal = selection.global_transform.basis.orthonormalized().xform_inv(click_normal)
						face_idx = ModelManager.get_brick_mesh_hovered_face_idx(shape, local_normal)

				paint_color(selection)

func paint_color(node:BrickHillBrickObject)->void :
	var scope = Profiler.scope(self, "paint_color", [node])

	if not node:
		return 

	if node.locked:
		return 

	AssignProperty.new(node, "albedo", active_color).execute()

func paint_hovered_node()->void :
	var scope = Profiler.scope(self, "paint_hovered_node", [])

	var hovered_node = WorkshopDirectory.hovered_node()
	var node = hovered_node.hovered_node
	if is_instance_valid(node):
		paint_color(node)
