class_name TransformDragGizmo
extends BaseGizmo3D

signal gizmo_drag_started(mouse_position)
signal gizmo_drag(mouse_position)
signal gizmo_drag_finished(mouse_position)

func handle_drag_start():
	var scope = Profiler.scope(self, "handle_drag_start", [])

	.handle_drag_start()

	var mouse_position = viewport_control.get_local_mouse_position()

	emit_signal("gizmo_drag_started", mouse_position)

func handle_drag_end():
	var scope = Profiler.scope(self, "handle_drag_end", [])

	.handle_drag_end()

	var mouse_position = viewport_control.get_local_mouse_position()

	emit_signal("gizmo_drag_finished", mouse_position)

func handle_drag():
	var scope = Profiler.scope(self, "handle_drag", [])

	.handle_drag()

	var mouse_position = viewport_control.get_local_mouse_position()

	emit_signal("gizmo_drag", mouse_position)
