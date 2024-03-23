class_name PaintMaterialManager
extends Node

signal active_material_changed(new_active_material)

export (NodePath) var tool_mode_path: = NodePath()
var active_material:int = BrickHillBrickObject.MaterialType.PLASTIC setget set_active_material

func get_tool_mode()->ToolMode:
	var scope = Profiler.scope(self, "get_tool_mode", [])

	return get_node(tool_mode_path) as ToolMode

func set_active_material(new_active_material:int)->void :
	var scope = Profiler.scope(self, "set_active_material", [new_active_material])

	if active_material != new_active_material:
		active_material = new_active_material
		emit_signal("active_material_changed", active_material)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func is_active()->bool:
	var scope = Profiler.scope(self, "is_active", [])

	return get_tool_mode().tool_mode == ToolMode.ToolMode.PaintMaterial

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	if not is_active():
		return 

	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			if InterfaceSelectable.is_implementor(node):
				var selection = InterfaceSelectable.get_selection(node)
				paint_material(selection)

func paint_material(node:BrickHillBrickObject)->void :
	var scope = Profiler.scope(self, "paint_material", [node])

	if not node:
		return 

	if node.locked:
		return 

	if node.material != active_material:
		AssignProperty.new(node, "material", active_material).execute()

func paint_hovered_node()->void :
	var scope = Profiler.scope(self, "paint_hovered_node", [])

	var hovered_node = WorkshopDirectory.hovered_node()
	var node = hovered_node.hovered_node
	if is_instance_valid(node):
		paint_material(node)
