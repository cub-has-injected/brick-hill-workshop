class_name WorkshopHotkeyManager
extends Node

signal hotkey_shape_next()
signal hotkey_shape_prev()
signal hotkey_add_brick()

signal hotkey_undo()
signal hotkey_redo()
signal hotkey_cut()
signal hotkey_copy()
signal hotkey_paste()
signal hotkey_duplicate()
signal hotkey_delete()

signal hotkey_tool_move_drag()
signal hotkey_tool_move()
signal hotkey_tool_rotate_plane()
signal hotkey_tool_resize()

signal hotkey_select_paint()
signal hotkey_select_surface()
signal hotkey_select_material()

signal hotkey_select_lock()
signal hotkey_select_anchor()

signal hotkey_toggle_collision()
signal hotkey_toggle_grid()
signal hotkey_toggle_box_select()

signal hotkey_shift_object(delta)
signal hotkey_snap_to_face()

signal hotkey_group()
signal hotkey_glue()

signal hotkey_group_scope_out()
signal hotkey_group_scope_in()

signal hotkey_bake_gi()
signal hotkey_clear_gi()

signal hotkey_camera_speed_up()
signal hotkey_camera_speed_down()
signal hotkey_camera_focus()

signal hotkey_new_scene()
signal hotkey_open_scene()
signal hotkey_save_scene()
signal hotkey_save_scene_as()

signal hotkey_apply_color()
signal hotkey_apply_surface()
signal hotkey_apply_material()

signal hotkey_scope_in()
signal hotkey_scope_out()

signal hotkey_flip(x, y, z)

signal hotkey_toggle_profiler_active()
signal hotkey_toggle_profiler_clear_on_process()

enum State{
	None, 
	Flip
}

export (bool) var enabled: = true

var _state:int = State.None

func _unhandled_input(event:InputEvent):
	var scope = Profiler.scope(self, "_unhandled_input", [event])

	if not enabled:
		return 

	if event is InputEventKey:
		if not event.pressed:
			return 

		match _state:
			State.None:
				_unhandled_input_none(event)
			State.Flip:
				_unhandled_input_flip(event)

func _unhandled_input_none(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_unhandled_input_none", [event])

	var move_delta = 1.0
	if event.control:
		move_delta *= 0.5
	if event.alt:
		move_delta *= 0.5

	var move_basis = Basis.IDENTITY

	match event.scancode:
		KEY_F:
			if event.control:
				_state = State.Flip
			else :
				emit_signal("hotkey_camera_focus")
		KEY_R:
			emit_signal("hotkey_snap_to_face")
		KEY_Z:
			if event.control:
				if event.shift:
					emit_signal("hotkey_redo")
				else :
					emit_signal("hotkey_undo")
			else :
				if event.shift:
					emit_signal("hotkey_shape_prev")
				else :
					emit_signal("hotkey_shape_next")
		KEY_G:
			if event.control:
				emit_signal("hotkey_glue")
		KEY_M:
			if event.control:
				emit_signal("hotkey_group")

		KEY_TAB:
			if event.shift:
				emit_signal("hotkey_group_scope_out")
			else :
				emit_signal("hotkey_group_scope_in")

		KEY_D:
			if event.control:
				emit_signal("hotkey_duplicate")
		KEY_X:
			if event.control:
				emit_signal("hotkey_cut")
			else :
				emit_signal("hotkey_add_brick")
		KEY_C:
			if event.control:
				emit_signal("hotkey_copy")
			else :
				emit_signal("hotkey_apply_color")
		KEY_V:
			if event.control:
				emit_signal("hotkey_paste")
			else :
				emit_signal("hotkey_apply_surface")
		KEY_B:
			emit_signal("hotkey_apply_material")

		KEY_N:
			if event.control:
				emit_signal("hotkey_new_scene")
		KEY_O:
			if event.control:
				emit_signal("hotkey_open_scene")
		KEY_S:
			if event.control:
				if event.shift:
					emit_signal("hotkey_save_scene_as")
				else :
					emit_signal("hotkey_save_scene")

		KEY_DELETE:
			emit_signal("hotkey_delete")

		KEY_1:
			emit_signal("hotkey_tool_move_drag")
		KEY_2:
			emit_signal("hotkey_tool_move")
		KEY_3:
			emit_signal("hotkey_tool_rotate_plane")
		KEY_4:
			emit_signal("hotkey_tool_resize")
		KEY_5:
			emit_signal("hotkey_select_paint")
		KEY_6:
			emit_signal("hotkey_select_surface")
		KEY_7:
			emit_signal("hotkey_select_material")
		KEY_8:
			emit_signal("hotkey_select_lock")
		KEY_9:
			emit_signal("hotkey_select_anchor")

		KEY_MINUS:
			emit_signal("hotkey_toggle_collision")
		KEY_EQUAL:
			emit_signal("hotkey_toggle_grid")
		KEY_BACKSPACE:
			emit_signal("hotkey_toggle_box_select")

		KEY_KP_8:
			emit_signal("hotkey_shift_object", - move_basis.z * move_delta)
		KEY_KP_5:
			emit_signal("hotkey_shift_object", move_basis.z * move_delta)
		KEY_KP_4:
			emit_signal("hotkey_shift_object", - move_basis.x * move_delta)
		KEY_KP_6:
			emit_signal("hotkey_shift_object", move_basis.x * move_delta)
		KEY_KP_7:
			emit_signal("hotkey_shift_object", move_basis.y * move_delta)
		KEY_KP_9:
			emit_signal("hotkey_shift_object", - move_basis.y * move_delta)

		KEY_B:
			if event.shift:
				emit_signal("hotkey_bake_gi")
			elif event.control:
				emit_signal("hotkey_clear_gi")

		KEY_KP_ADD:
			emit_signal("hotkey_camera_speed_up")
		KEY_KP_SUBTRACT:
			emit_signal("hotkey_camera_speed_down")

		KEY_COMMA:
			emit_signal("hotkey_scope_out")
		KEY_PERIOD:
			emit_signal("hotkey_scope_in")

		KEY_P:
			if event.control:
				emit_signal("hotkey_toggle_profiler_clear_on_process")
			else :
				emit_signal("hotkey_toggle_profiler_active")

func _unhandled_input_flip(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_unhandled_input_flip", [event])

	match event.scancode:
		KEY_X:
			emit_signal("hotkey_flip", true, false, false)
		KEY_Y:
			emit_signal("hotkey_flip", false, true, false)
		KEY_Z:
			emit_signal("hotkey_flip", false, false, true)

	_state = State.None
