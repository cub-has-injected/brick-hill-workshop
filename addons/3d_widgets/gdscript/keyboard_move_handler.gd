class_name KeyboardMoveHandler
extends Node

const SNAP_TO_GRID_KEY: = KEY_KP_5

export (NodePath) var snap_settings_path: = NodePath()
export (NodePath) var coordinate_space_path: = NodePath()
export (NodePath) var movement_proxy_path: = NodePath()
export (NodePath) var resize_proxy_path: = NodePath()
export (NodePath) var composite_object_path: = NodePath()

var nudge_keys: = {
	KEY_KP_4:Vector3.LEFT, 
	KEY_KP_6:Vector3.RIGHT, 
	KEY_KP_8:Vector3.FORWARD, 
	KEY_KP_2:Vector3.BACK, 
	KEY_KP_7:Vector3.UP, 
	KEY_KP_9:Vector3.DOWN, 
}

func get_snap_settings()->SnapSettings:
	var scope = Profiler.scope(self, "get_snap_settings", [])

	return get_node(snap_settings_path) as SnapSettings

func get_coordinate_space()->CoordinateSpace:
	var scope = Profiler.scope(self, "get_coordinate_space", [])

	return get_node(coordinate_space_path) as CoordinateSpace

func get_movement_proxy()->MovementProxy:
	var scope = Profiler.scope(self, "get_movement_proxy", [])

	return get_node(movement_proxy_path) as MovementProxy

func get_resize_proxy()->ResizeProxy:
	var scope = Profiler.scope(self, "get_resize_proxy", [])

	return get_node(resize_proxy_path) as ResizeProxy

func get_composite_object()->CompositeObject:
	var scope = Profiler.scope(self, "get_composite_object", [])

	return get_node(composite_object_path) as CompositeObject

func _unhandled_key_input(event:InputEventKey)->void :
	var scope = Profiler.scope(self, "_unhandled_key_input", [event])

	if not event.pressed:
		return 

	if event.is_echo():
		return 

	var snap_settings = get_snap_settings()

	if event.scancode == SNAP_TO_GRID_KEY:
		if Input.is_key_pressed(KEY_R):
			get_movement_proxy().snap_rotation(get_snap_settings().snap_rotate_step)
		else :
			get_movement_proxy().snap_origin(get_snap_settings().snap_move_step)
		return 

	if not event.scancode in nudge_keys:
		return 

	var camera = get_viewport().get_camera()
	var camera_euler = camera.rotation_degrees
	var camera_yaw = round(camera_euler.y / 90.0) * 90.0
	var camera_pitch = round(camera_euler.x / 90.0) * 90.0

	var basis = Basis.IDENTITY

	var delta:Vector3 = nudge_keys[event.scancode] * snap_settings.snap_move_step
	delta = delta.rotated(Vector3.UP, deg2rad(camera_yaw))
	delta = delta.rotated(Vector3.RIGHT.rotated(Vector3.UP, deg2rad(camera_yaw)), deg2rad(camera_pitch))

	var movement_proxy = get_movement_proxy()
	movement_proxy.continuous_collision = false

	if Input.is_key_pressed(KEY_R):
		var cached_origin = movement_proxy.origin
		movement_proxy.origin = Vector3.ZERO
		movement_proxy.proxy_rotate_euler(Vector3(delta.z, delta.y, delta.x) * snap_settings.snap_rotate_step)
		movement_proxy.origin = cached_origin
	else :
		var resize_proxy = get_resize_proxy()
		if event.alt:
			resize_proxy.origin = Vector3.ONE
			resize_proxy.nudge_corner(delta)
		elif event.control:
			resize_proxy.origin = - Vector3.ONE
			resize_proxy.nudge_corner(delta)
		else :
			if get_coordinate_space().coordinate_space == CoordinateSpace.CoordinateSpace.Local:
				var composite_object = get_composite_object()
				delta = composite_object.global_transform.basis.xform(delta)
			movement_proxy.proxy_move(delta)
