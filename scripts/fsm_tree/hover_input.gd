class_name HoverInput
extends Node

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	var hover_manager = WorkshopDirectory.hovered_node()

	if event is InputEventMouseMotion:
		if InterfaceSelectable.is_implementor(node):
			var selection = InterfaceSelectable.get_selection(node)
			hover_manager.set_hovered_node(selection)
			hover_manager.set_hover_normal(click_normal)
		else :
			hover_manager.set_hovered_node(null)
			hover_manager.set_hover_normal(Vector3.ZERO)
