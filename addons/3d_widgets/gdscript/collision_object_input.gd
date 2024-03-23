class_name CollisionObjectInput
extends Node

signal collision_object_mouse_entered(node)
signal collision_object_mouse_exited(node)
signal collision_object_input_event(node, camera, event, click_position, click_normal, shape_idx)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "collision_object_input_events", "on_collision_object_input_enter_tree", self)

	var parent = get_parent()
	assert (parent is CollisionObject)
	parent.connect("mouse_entered", self, "on_mouse_entered")
	parent.connect("mouse_exited", self, "on_mouse_exited")
	parent.connect("input_event", self, "on_input_event")

func on_input_event(camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_input_event", [camera, event, click_position, click_normal, shape_idx])

	emit_signal("collision_object_input_event", get_parent(), camera, event, click_position, click_normal, shape_idx)

func on_mouse_entered()->void :
	var scope = Profiler.scope(self, "on_mouse_entered", [])

	emit_signal("collision_object_mouse_entered", get_parent())

func on_mouse_exited()->void :
	var scope = Profiler.scope(self, "on_mouse_exited", [])

	emit_signal("collision_object_mouse_exited", get_parent())
