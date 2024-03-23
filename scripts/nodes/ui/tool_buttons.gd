class_name ToolButtons
extends HBoxContainer

signal tool_move_drag()
signal tool_move_axis()
signal tool_move_plane()
signal tool_rotate_plane()
signal tool_resize_face()
signal tool_resize_edge()
signal tool_resize_corner()
signal tool_paint_color()
signal tool_paint_surface()
signal tool_paint_material()
signal tool_lock()
signal tool_anchor()

onready var move_drag_button = $MoveDrag
onready var move_axis_button = $MoveAxis
onready var move_plane_button = $MovePlane
onready var rotate_plane_button = $RotatePlane
onready var resize_face_button = $ResizeFace
onready var resize_edge_button = $ResizeEdge
onready var resize_corner_button = $ResizeCorner

onready var color_button = $ColorHBox / ColorTool
onready var surface_button = $SurfaceHBox / SurfaceTool
onready var material_button = $MaterialHBox / MaterialTool

onready var lock_button = $NodeButtons / Lock
onready var anchor_button = $NodeButtons / Anchor

func tool_move_drag()->void :
	var scope = Profiler.scope(self, "tool_move_drag", [])

	move_drag_button.pressed = true
	emit_signal("tool_move_drag")

func tool_move_next()->void :
	var scope = Profiler.scope(self, "tool_move_next", [])

	if move_axis_button.pressed:
		tool_move_plane()
	elif move_plane_button.pressed:
		tool_move_axis()
	else :
		tool_move_axis()

func tool_move_axis()->void :
	var scope = Profiler.scope(self, "tool_move_axis", [])

	move_axis_button.pressed = true
	emit_signal("tool_move_axis")

func tool_move_plane()->void :
	var scope = Profiler.scope(self, "tool_move_plane", [])

	move_plane_button.pressed = true
	emit_signal("tool_move_plane")

func tool_rotate_plane()->void :
	var scope = Profiler.scope(self, "tool_rotate_plane", [])

	rotate_plane_button.pressed = true
	emit_signal("tool_rotate_plane")

func tool_resize_next()->void :
	var scope = Profiler.scope(self, "tool_resize_next", [])

	if resize_face_button.pressed:
		tool_resize_edge()
	elif resize_edge_button.pressed:
		tool_resize_corner()
	elif resize_corner_button.pressed:
		tool_resize_face()
	else :
		tool_resize_face()

func tool_resize_face()->void :
	var scope = Profiler.scope(self, "tool_resize_face", [])

	resize_face_button.pressed = true
	emit_signal("tool_resize_face")

func tool_resize_edge()->void :
	var scope = Profiler.scope(self, "tool_resize_edge", [])

	resize_edge_button.pressed = true
	emit_signal("tool_resize_edge")

func tool_resize_corner()->void :
	var scope = Profiler.scope(self, "tool_resize_corner", [])

	resize_corner_button.pressed = true
	emit_signal("tool_resize_corner")

func tool_paint_color()->void :
	var scope = Profiler.scope(self, "tool_paint_color", [])

	color_button.pressed = true
	emit_signal("tool_paint_color")

func tool_paint_surface()->void :
	var scope = Profiler.scope(self, "tool_paint_surface", [])

	surface_button.pressed = true
	emit_signal("tool_paint_surface")

func tool_paint_material()->void :
	var scope = Profiler.scope(self, "tool_paint_material", [])

	material_button.pressed = true
	emit_signal("tool_paint_material")

func tool_lock()->void :
	var scope = Profiler.scope(self, "tool_lock", [])

	lock_button.pressed = true
	emit_signal("tool_lock")

func tool_anchor()->void :
	var scope = Profiler.scope(self, "tool_anchor", [])

	anchor_button.pressed = true
	emit_signal("tool_anchor")
