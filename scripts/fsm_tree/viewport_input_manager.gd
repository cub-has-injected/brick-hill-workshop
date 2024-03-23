class_name ViewportInputManager
extends ViewportInputManagerTree

signal mode_changed()

enum Mode{
	NONE, 
	DRAG, 
	PAINT, 
	LOCK_ANCHOR
}

export (Mode) var mode: = Mode.DRAG setget set_mode

func set_mode(new_mode:int)->void :
	var scope = Profiler.scope(self, "set_mode", [new_mode])

	if mode != new_mode:
		mode = new_mode

		match mode:
			Mode.DRAG:
				get_tree().call_group("brick_hill_physics_object", "set_input_capture_on_drag", true)
			Mode.PAINT:
				get_tree().call_group("brick_hill_physics_object", "set_input_capture_on_drag", false)
			Mode.LOCK_ANCHOR:
				get_tree().call_group("brick_hill_physics_object", "set_input_capture_on_drag", true)

		emit_signal("mode_changed")

func get_global_states_impl()->Array:
	var scope = Profiler.scope(self, "get_global_states_impl", [])

	if mode == Mode.NONE:
		return []
	else :
		return .get_global_states_impl()

func get_modal_state_impl(modal:Node)->Node:
	var scope = Profiler.scope(self, "get_modal_state_impl", [modal])

	match mode:
		Mode.DRAG:
			return modal.get_node_or_null("DragManager")
		Mode.PAINT:
			return modal.get_node_or_null("PaintManager")
		Mode.LOCK_ANCHOR:
			return modal.get_node_or_null("LockAnchorManager")
	return null


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("input_manager")

func pickable_entered_tree(pickable:Node)->void :
	var scope = Profiler.scope(self, "pickable_entered_tree", [pickable])

	pickable.connect("input", self, "pickable_input")
