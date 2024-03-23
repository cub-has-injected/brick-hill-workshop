class_name PickableCollisionObject
extends CollisionObject

signal input(node, camera, event, click_position, click_normal, shape_idx)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("pickable_collision_object")
	get_tree().call_group("input_manager", "pickable_entered_tree", self)

	var viewport = get_viewport()
	assert (viewport)
	connect("mouse_entered", viewport, "node_hovered", [self])
	connect("mouse_exited", viewport, "node_unhovered", [self])

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	var viewport = get_viewport()
	assert (viewport)
	disconnect("mouse_entered", viewport, "node_hovered")
	disconnect("mouse_exited", viewport, "node_unhovered")

func _input_event(camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "_input_event", [camera, event, click_position, click_normal, shape_idx])

	emit_signal("input", self, camera, event, click_position, click_normal, shape_idx)

	var viewport = get_viewport()
	assert (viewport)
	if viewport.has_method("input_event"):
		viewport.input_event(self, camera, event, click_position, click_normal, shape_idx)
