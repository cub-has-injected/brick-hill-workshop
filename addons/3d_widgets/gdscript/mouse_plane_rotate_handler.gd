class_name MousePlaneRotateHandler
extends Node

enum DragState{
	None, 
	Pressed, 
	Dragging, 
}

signal drag_state_changed(drag_state)

export (NodePath) var tool_mode_path: = NodePath()
export (NodePath) var snap_settings_path: = NodePath()
export (NodePath) var mouse_plane_path: = NodePath()
export (NodePath) var movement_proxy_path: = NodePath()
export (NodePath) var composite_object_path: = NodePath()
export (bool) var disable: = false

var _drag_state:int = DragState.None setget set_drag_state
var _snap_accumulator: = 0.0
var _jump_accumulator: = 0.0

func set_drag_state(new_drag_state:int)->void :
	var scope = Profiler.scope(self, "set_drag_state", [new_drag_state])

	if _drag_state != new_drag_state:
		_drag_state = new_drag_state
		emit_signal("drag_state_changed", _drag_state)

func get_tool_mode()->ToolMode:
	var scope = Profiler.scope(self, "get_tool_mode", [])

	return get_node(tool_mode_path) as ToolMode

func get_snap_settings()->SnapSettings:
	var scope = Profiler.scope(self, "get_snap_settings", [])

	return get_node(snap_settings_path) as SnapSettings

func get_mouse_plane()->MousePlane:
	var scope = Profiler.scope(self, "get_mouse_plane", [])

	return get_node(mouse_plane_path) as MousePlane

func get_movement_proxy()->MovementProxy:
	var scope = Profiler.scope(self, "get_movement_proxy", [])

	return get_node(movement_proxy_path) as MovementProxy

func get_composite_object()->CompositeObject:
	var scope = Profiler.scope(self, "get_composite_object", [])

	return get_node(composite_object_path) as CompositeObject

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	var mouse_plane = get_mouse_plane()
	mouse_plane.connect("plane_event", self, "on_mouse_plane_event")

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var mouse_plane = get_mouse_plane()
	var basis = mouse_plane.global_transform.basis
	var offset = Basis(basis.z, _snap_accumulator + _jump_accumulator)

	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		_snap_accumulator = lerp(_snap_accumulator, 0.0, 0.2)
		_jump_accumulator = 0.0

func is_active()->bool:
	var scope = Profiler.scope(self, "is_active", [])

	return (
		 not disable
		 and get_tool_mode().tool_mode == ToolMode.ToolMode.RotatePlane
		 and not Input.is_key_pressed(KEY_ALT)
	)

func on_mouse_plane_event(plane:MousePlane, event:MousePlane.EventPlane)->void :
	var scope = Profiler.scope(self, "on_mouse_plane_event", [plane, event])

	if not is_active():
		return 

	if event is MousePlane.EventPlaneButton:
		if event.pressed:
			match event.button_index:
				BUTTON_LEFT:
					set_drag_state(DragState.Pressed)
		else :
			match event.button_index:
				BUTTON_LEFT:
					set_drag_state(DragState.None)

	if event is MousePlane.EventPlaneMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			mouse_plane_rotate_input(plane, event)

func mouse_plane_rotate_input(plane:MousePlane, event:MousePlane.EventPlaneMotion)->void :
	var scope = Profiler.scope(self, "mouse_plane_rotate_input", [plane, event])

	set_drag_state(DragState.Dragging)

	if get_tool_mode().tool_mode != ToolMode.ToolMode.RotatePlane:
		return 

	if event.relative == Vector3.ZERO:
		return 

	var a = event.origin - event.relative
	var b = event.origin

	var movement_proxy = get_movement_proxy()

	var proxy_trx = movement_proxy.global_transform
	var local_a = proxy_trx.origin - a
	var local_b = proxy_trx.origin - b

	var plane_basis = plane.global_transform.basis
	var local_basis = Basis(local_a.cross(plane_basis.z).normalized(), local_a.normalized(), plane_basis.z)
	local_a = local_basis.xform_inv(local_a)
	local_b = local_basis.xform_inv(local_b)

	var rad_a = atan2(local_a.y, local_a.x)
	var rad_b = atan2(local_b.y, local_b.x)
	var delta = rad_b - rad_a

	var snap_settings = get_snap_settings()
	if snap_settings.snap_rotate:
		var rad = deg2rad(snap_settings.snap_rotate_step)
		if abs(_snap_accumulator) < rad:
			_snap_accumulator += delta
			delta = 0
		else :
			var sgn = sign(_snap_accumulator)
			delta = rad * sgn
			_snap_accumulator -= rad * sgn

	if delta != 0:
		var result = movement_proxy.proxy_rotate(plane.global_transform.basis.z, delta)
		if result != null:
			delta -= result
		_jump_accumulator += delta

		var jump_result = movement_proxy.proxy_rotate(plane.global_transform.basis.z, _jump_accumulator)
		if jump_result != null:
			_jump_accumulator -= jump_result
