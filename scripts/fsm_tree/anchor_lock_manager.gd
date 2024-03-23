class_name LockAnchorManager
extends ViewportInputManagerTree

enum Mode{
	LOCK, 
	ANCHOR
}

export (Mode) var mode: = Mode.LOCK

func get_modal_state_impl(modal:Node)->Node:
	var scope = Profiler.scope(self, "get_modal_state_impl", [modal])

	match mode:
		Mode.LOCK:
			return modal.get_node_or_null("LockManager")
		Mode.ANCHOR:
			return modal.get_node_or_null("AnchorManager")
	return null
