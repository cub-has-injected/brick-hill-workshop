class_name BandBoxSelector
extends Area
tool 

signal select_start()
signal select_end()

signal node_selected(node)
signal node_deselected(node)

export (Rect2) var rect:Rect2 setget set_rect
export (NodePath) var bandbox_control_path:NodePath = NodePath()
export (int, "None", "Left", "Right", "Middle") var button_index = 1
export (bool) var use_unhandled_input: = true

var collision_shape:CollisionShape
var selecting: = false




func set_rect(new_rect:Rect2)->void :
	var scope = Profiler.scope(self, "set_rect", [new_rect])

	if rect != new_rect:
		rect = new_rect

		if is_inside_tree():
			update_collision_shape()
			update_bandbox_control()




func get_camera()->Camera:
	var scope = Profiler.scope(self, "get_camera", [])

	return get_viewport().get_camera()

func get_shape()->Shape:
	var scope = Profiler.scope(self, "get_shape", [])

	return collision_shape.shape

func get_bandbox_control()->Control:
	var scope = Profiler.scope(self, "get_bandbox_control", [])

	return get_node_or_null(bandbox_control_path) as Control




var try_select_node_func: = funcref(self, "try_select_node_impl")
func try_select_node(node:Node)->Node:
	var scope = Profiler.scope(self, "try_select_node", [node])

	return try_select_node_func.call_func(node)

func try_select_node_impl(node:Node)->Node:
	var scope = Profiler.scope(self, "try_select_node_impl", [node])

	return node

var try_deselect_node_func: = funcref(self, "try_deselect_node_impl")
func try_deselect_node(node:Node)->Node:
	var scope = Profiler.scope(self, "try_deselect_node", [node])

	return try_deselect_node_func.call_func(node)

func try_deselect_node_impl(node:Node)->Node:
	var scope = Profiler.scope(self, "try_deselect_node_impl", [node])

	return node




func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	monitorable = false
	input_ray_pickable = false

	destroy_transient_children()
	create_transient_children()

	connect("body_entered", self, "body_entered")
	connect("body_exited", self, "body_exited")

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	update_collision_shape()
	update_bandbox_control()

func _process(_delta:float)->void :
	var scope = Profiler.scope(self, "_process", [_delta])

	global_transform = Transform.IDENTITY




func _unhandled_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_unhandled_input", [event])

	if use_unhandled_input:
		handle_input(event)

func handle_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "handle_input", [event])

	if event is InputEventMouse:
		if event is InputEventMouseButton:
			if event.button_index == button_index:
				if event.pressed:
					if not selecting:
						start_selection(event.position)
				else :
					if selecting:
						end_selection()
		elif event is InputEventMouseMotion:
			if selecting:
				var mask:int
				match button_index:
					BUTTON_LEFT:mask = BUTTON_MASK_LEFT
					BUTTON_RIGHT:mask = BUTTON_MASK_RIGHT
					BUTTON_MIDDLE:mask = BUTTON_MASK_MIDDLE
				if event.button_mask & mask:
					var new_rect = rect
					new_rect.end = event.position
					set_rect(new_rect)

func start_selection(mouse_position:Vector2)->void :
	var scope = Profiler.scope(self, "start_selection", [mouse_position])

	assert ( not selecting)
	set_rect(Rect2(mouse_position, Vector2.ZERO))
	selecting = true
	emit_signal("select_start")

func end_selection()->void :
	var scope = Profiler.scope(self, "end_selection", [])

	assert (selecting)
	selecting = false
	emit_signal("select_end")
	set_rect(Rect2())





func create_transient_children()->void :
	var scope = Profiler.scope(self, "create_transient_children", [])

	collision_shape = CollisionShape.new()
	collision_shape.set_meta("band_box_child", null)
	add_child(collision_shape)

	var shape = ConvexPolygonShape.new()
	shape.points.resize(8)
	collision_shape.shape = shape

func destroy_transient_children()->void :
	var scope = Profiler.scope(self, "destroy_transient_children", [])

	for child in get_children():
		if child.has_meta("band_box_child"):
			remove_child(child)
			child.queue_free()

	collision_shape = null




func update_collision_shape()->void :
	var scope = Profiler.scope(self, "update_collision_shape", [])

	assert (collision_shape != null)
	collision_shape.transform = Transform.IDENTITY

	var shape = get_shape() as ConvexPolygonShape
	assert (shape != null)

	if rect.size == Vector2.ZERO:
		collision_shape.disabled = true
		shape.points = PoolVector3Array()
		return 
	else :
		collision_shape.disabled = false

	
	var camera: = get_camera()
	assert (camera != null)

	var viewport = camera.get_viewport()
	assert (viewport != null)

	var viewport_size = viewport.size

	var v0 = rect.position
	var v1 = rect.position + Vector2(rect.size.x, 0)
	var v2 = rect.position + rect.size
	var v3 = rect.position + Vector2(0, rect.size.y)

	var v0_normal = camera.project_ray_normal(v0)
	var v1_normal = camera.project_ray_normal(v1)
	var v2_normal = camera.project_ray_normal(v2)
	var v3_normal = camera.project_ray_normal(v3)

	shape.points = PoolVector3Array([
		camera.global_transform.origin + v0_normal * camera.near, 
		camera.global_transform.origin + v1_normal * camera.near, 
		camera.global_transform.origin + v2_normal * camera.near, 
		camera.global_transform.origin + v3_normal * camera.near, 

		camera.global_transform.origin + v0_normal * camera.far, 
		camera.global_transform.origin + v1_normal * camera.far, 
		camera.global_transform.origin + v2_normal * camera.far, 
		camera.global_transform.origin + v3_normal * camera.far, 
	])




func update_bandbox_control()->void :
	var scope = Profiler.scope(self, "update_bandbox_control", [])

	var color_rect: = get_bandbox_control()
	if color_rect:
		var position: = Vector2.ZERO
		var size: = Vector2.ZERO

		if rect.size.x >= 0:
			position.x = rect.position.x
			size.x = rect.size.x
		else :
			position.x = rect.position.x + rect.size.x
			size.x = abs(rect.size.x)

		if rect.size.y >= 0:
			position.y = rect.position.y
			size.y = rect.size.y
		else :
			position.y = rect.position.y + rect.size.y
			size.y = abs(rect.size.y)

		color_rect.rect_position = position
		color_rect.rect_size = size




func body_entered(node:Node)->void :
	var scope = Profiler.scope(self, "body_entered", [node])

	if selecting:
		var result: = try_select_node(node)
		if result != null:
			emit_signal("node_selected", result)

func body_exited(node:Node)->void :
	var scope = Profiler.scope(self, "body_exited", [node])

	if selecting:
		var result: = try_deselect_node(node)
		if result != null:
			emit_signal("node_deselected", result)

