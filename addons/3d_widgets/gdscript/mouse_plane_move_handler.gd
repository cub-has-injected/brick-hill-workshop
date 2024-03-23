class_name MousePlaneMoveHandler
extends Node

enum DragState{
	None, 
	Pressed, 
	Dragging, 
}

signal drag_state_changed(drag_state)

export (NodePath) var tool_mode_path: = NodePath()
export (NodePath) var snap_settings_path: = NodePath()
export (NodePath) var coordinate_space_path: = NodePath()
export (NodePath) var mouse_plane_path: = NodePath()
export (NodePath) var movement_proxy_path: = NodePath()
export (NodePath) var resize_proxy_path: = NodePath()
export (NodePath) var composite_object_path: = NodePath()
export (NodePath) var widgets_path: = NodePath()
export (bool) var use_jump: = false
export (bool) var disable: = false

var _drag_state:int = DragState.None setget set_drag_state

var _snap_accumulator: = Vector3.ZERO
var _jump_accumulator: = Vector3.ZERO

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

func get_coordinate_space()->CoordinateSpace:
	var scope = Profiler.scope(self, "get_coordinate_space", [])

	return get_node(coordinate_space_path) as CoordinateSpace

func get_mouse_plane()->MousePlane:
	var scope = Profiler.scope(self, "get_mouse_plane", [])

	return get_node(mouse_plane_path) as MousePlane

func get_movement_proxy()->MovementProxy:
	var scope = Profiler.scope(self, "get_movement_proxy", [])

	return get_node(movement_proxy_path) as MovementProxy

func get_resize_proxy()->ResizeProxy:
	var scope = Profiler.scope(self, "get_resize_proxy", [])

	return get_node(resize_proxy_path) as ResizeProxy

func get_composite_object()->CompositeObject:
	var scope = Profiler.scope(self, "get_composite_object", [])

	return get_node(composite_object_path) as CompositeObject

func get_widgets()->Widgets:
	var scope = Profiler.scope(self, "get_widgets", [])

	return get_node(widgets_path) as Widgets

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	var mouse_plane = get_mouse_plane()
	mouse_plane.connect("plane_event", self, "on_mouse_plane_event")

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var offset: = Vector3.ZERO
	if not is_resize():
		offset = _snap_accumulator + _jump_accumulator

	var widgets = get_widgets()
	var composite_object = get_composite_object()

	if get_coordinate_space().coordinate_space == CoordinateSpace.CoordinateSpace.Global:
		widgets.origin_offset = offset
	elif get_coordinate_space().coordinate_space == CoordinateSpace.CoordinateSpace.Local:
		offset = composite_object.global_transform.basis.xform_inv(offset)
		widgets.origin_offset = offset

	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		_snap_accumulator = lerp(_snap_accumulator, Vector3.ZERO, 0.2)
		_jump_accumulator = Vector3.ZERO

func is_active()->bool:
	var scope = Profiler.scope(self, "is_active", [])

	return (
		 not disable
		 and get_tool_mode().tool_mode != ToolMode.ToolMode.RotatePlane
		 and not Input.is_key_pressed(KEY_ALT)
	)

func is_move()->bool:
	var scope = Profiler.scope(self, "is_move", [])

	var tool_mode = get_tool_mode().tool_mode
	match tool_mode:
		ToolMode.ToolMode.MoveDrag:
			return true
		ToolMode.ToolMode.MoveAxis:
			return true
		ToolMode.ToolMode.MovePlane:
			return true
		ToolMode.ToolMode.ResizeFace:
			return true
		ToolMode.ToolMode.ResizeEdge:
			return true
		ToolMode.ToolMode.ResizeCorner:
			return true
	return false

func is_resize()->bool:
	var scope = Profiler.scope(self, "is_resize", [])

	var tool_mode = get_tool_mode().tool_mode
	match tool_mode:
		ToolMode.ToolMode.ResizeFace:
			return true
		ToolMode.ToolMode.ResizeEdge:
			return true
		ToolMode.ToolMode.ResizeCorner:
			return true
	return false

func on_mouse_plane_event(plane:MousePlane, event:MousePlane.EventPlane)->void :
	var scope = Profiler.scope(self, "on_mouse_plane_event", [plane, event])

	if not is_active():
		return 

	var movement_proxy = get_movement_proxy()
	movement_proxy.continuous_collision = false

	var snap_settings = get_snap_settings()
	if is_move():
		if event is MousePlane.EventPlaneButton:
			if event.pressed:
				match event.button_index:
					BUTTON_WHEEL_UP:
						if Input.is_mouse_button_pressed(BUTTON_LEFT):
							mouse_plane_move_input( - plane.global_transform.basis.z * snap_settings.snap_move_step)
					BUTTON_WHEEL_DOWN:
						if Input.is_mouse_button_pressed(BUTTON_LEFT):
							mouse_plane_move_input(plane.global_transform.basis.z * snap_settings.snap_move_step)
					BUTTON_LEFT:
						set_drag_state(DragState.Pressed)
			else :
				match event.button_index:
					BUTTON_LEFT:
						set_drag_state(DragState.None)
		elif event is MousePlane.EventPlaneMotion:
			if Input.is_mouse_button_pressed(BUTTON_LEFT):
				mouse_plane_move_input(event.relative)

func mouse_plane_move_input(delta:Vector3)->void :
	var scope = Profiler.scope(self, "mouse_plane_move_input", [delta])

	set_drag_state(DragState.Dragging)

	var snap_settings = get_snap_settings()
	if snap_settings.snap_move:
		if abs(_snap_accumulator.x) < snap_settings.snap_move_step:
			_snap_accumulator.x += delta.x
			delta.x = 0

		if abs(_snap_accumulator.x) >= snap_settings.snap_move_step:
			var sgn = sign(_snap_accumulator.x)
			delta.x = snap_settings.snap_move_step * sgn
			_snap_accumulator.x -= snap_settings.snap_move_step * sgn

		if abs(_snap_accumulator.y) < snap_settings.snap_move_step:
			_snap_accumulator.y += delta.y
			delta.y = 0

		if abs(_snap_accumulator.y) >= snap_settings.snap_move_step:
			var sgn = sign(_snap_accumulator.y)
			delta.y = snap_settings.snap_move_step * sgn
			_snap_accumulator.y -= snap_settings.snap_move_step * sgn

		if abs(_snap_accumulator.z) < snap_settings.snap_move_step:
			_snap_accumulator.z += delta.z
			delta.z = 0

		if abs(_snap_accumulator.z) >= snap_settings.snap_move_step:
			var sgn = sign(_snap_accumulator.z)
			delta.z = snap_settings.snap_move_step * sgn
			_snap_accumulator.z -= snap_settings.snap_move_step * sgn

	var movement_proxy = get_movement_proxy()
	movement_proxy.continuous_collision = not snap_settings.snap_move

	if delta == Vector3.ZERO:
		return 

	if is_resize():
		get_resize_proxy().nudge_corner(delta)
	else :
		var result = get_movement_proxy().proxy_move_3(delta)
		if result != null:
			delta -= result

		if use_jump:
			_jump_accumulator += delta

			var jump_result = get_movement_proxy().proxy_move_3(_jump_accumulator)
			if jump_result != null:
				_jump_accumulator -= jump_result
