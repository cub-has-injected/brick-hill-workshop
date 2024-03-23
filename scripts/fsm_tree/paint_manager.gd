class_name PaintManager
extends ViewportInputManagerTree

enum Mode{
	COLOR, 
	SURFACE, 
	MATERIAL
}

export (Mode) var mode = Mode.COLOR

func get_modal_state_impl(modal:Node)->Node:
	var scope = Profiler.scope(self, "get_modal_state_impl", [modal])

	match mode:
		Mode.COLOR:
			return modal.get_node_or_null("PaintColorManager")
		Mode.SURFACE:
			return modal.get_node_or_null("PaintSurfaceManager")
		Mode.MATERIAL:
			return modal.get_node_or_null("PaintMaterialManager")
	return null
