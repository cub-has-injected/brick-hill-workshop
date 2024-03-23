class_name ToolMode
extends Node

signal mode_changed(new_tool_mode)

enum ToolMode{
	None, 
	MoveDrag, 
	MoveAxis, 
	MovePlane, 
	RotatePlane, 
	ResizeFace, 
	ResizeEdge, 
	ResizeCorner, 
	PaintColor, 
	PaintSurface, 
	PaintMaterial, 
	Lock, 
	Anchor
}

export (ToolMode) var tool_mode: = ToolMode.MoveDrag setget set_tool_mode

func set_tool_mode(new_tool_mode:int)->void :
	var scope = Profiler.scope(self, "set_tool_mode", [new_tool_mode])

	if tool_mode != new_tool_mode:
		tool_mode = new_tool_mode
		if is_inside_tree():
			update_mode()

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	update_mode()

func update_mode()->void :
	var scope = Profiler.scope(self, "update_mode", [])

	emit_signal("mode_changed", tool_mode)

func tool_none()->void :
	var scope = Profiler.scope(self, "tool_none", [])

	set_tool_mode(ToolMode.None)

func tool_move_drag()->void :
	var scope = Profiler.scope(self, "tool_move_drag", [])

	set_tool_mode(ToolMode.MoveDrag)

func tool_move_axis()->void :
	var scope = Profiler.scope(self, "tool_move_axis", [])

	set_tool_mode(ToolMode.MoveAxis)

func tool_move_plane()->void :
	var scope = Profiler.scope(self, "tool_move_plane", [])

	set_tool_mode(ToolMode.MovePlane)

func tool_rotate_plane()->void :
	var scope = Profiler.scope(self, "tool_rotate_plane", [])

	set_tool_mode(ToolMode.RotatePlane)

func tool_resize_face()->void :
	var scope = Profiler.scope(self, "tool_resize_face", [])

	set_tool_mode(ToolMode.ResizeFace)

func tool_resize_edge()->void :
	var scope = Profiler.scope(self, "tool_resize_edge", [])

	set_tool_mode(ToolMode.ResizeEdge)

func tool_resize_corner()->void :
	var scope = Profiler.scope(self, "tool_resize_corner", [])

	set_tool_mode(ToolMode.ResizeCorner)

func tool_paint_color()->void :
	var scope = Profiler.scope(self, "tool_paint_color", [])

	set_tool_mode(ToolMode.PaintColor)

func tool_paint_surface()->void :
	var scope = Profiler.scope(self, "tool_paint_surface", [])

	set_tool_mode(ToolMode.PaintSurface)

func tool_paint_material()->void :
	var scope = Profiler.scope(self, "tool_paint_material", [])

	set_tool_mode(ToolMode.PaintMaterial)

func tool_lock()->void :
	var scope = Profiler.scope(self, "tool_lock", [])

	set_tool_mode(ToolMode.Lock)

func tool_anchor()->void :
	var scope = Profiler.scope(self, "tool_anchor", [])

	set_tool_mode(ToolMode.Anchor)
